//
//  HPInfoViewController.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/13.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

class HPInfoViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    let mapView = MTMapView()
    let currentLocationButton = UIButton()
    let detailList = UITableView()
    let detailListBackgroundView = DetailListBackgroundView()
    let viewModel = HPInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        bind(viewModel)
        attribute()
        layout()
    }
    
    func bind(_ viewModel: HPInfoViewModel) {
        detailListBackgroundView.bind(viewModel.detailListBackgroundViewModel)
        
        // currentLocationButton이 눌러졌을 때의 이벤트
        currentLocationButton.rx.tap
            .bind(to: viewModel.currentLocationButtonTapped)
            .disposed(by: disposeBag)
        
        // MapView의 MapCenterPoint로 이동
        viewModel.setMapCenter
            .emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .emit(to: self.rx.presentAlert)
            .disposed(by: disposeBag)
        
        // cellData를 detailList에 표현
        viewModel.detailListCellData
            .drive(detailList.rx.items) { tv, row, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailListCell", for: IndexPath(row: row, section: 0)) as? DetailListCell else { return UITableViewCell() }
                
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)
        
        // cellData를 mapView에 redPin으로 표현
        viewModel.detailListCellData
            .map { $0.compactMap { $0.point } }
            .drive(self.rx.addPOIItems)
            .disposed(by: disposeBag)
        
        detailList.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.detailListItemSeleted)
            .disposed(by: disposeBag)
        
        viewModel.scrollToSelectedLocation
            .emit(to: self.rx.showSelectedLocation)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        title = "내 주변 병원 찾기"
        view.backgroundColor = .systemBackground
        
        // currentLocationTrackingMode: 현위치 트래킹 모드 및 나침반 모드 설정
        mapView.currentLocationTrackingMode = .onWithoutHeadingWithoutMapMoving
        
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.backgroundColor = .systemBackground
        currentLocationButton.layer.cornerRadius = 20
        
        detailList.register(DetailListCell.self, forCellReuseIdentifier: "DetailListCell")
        detailList.separatorStyle = .none
        detailList.backgroundView = detailListBackgroundView
    }
    
    private func layout() {
        [
            mapView,
            currentLocationButton,
            detailList
        ].forEach {
            view.addSubview($0)
        }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(mapView.snp.bottom).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
        }
        
        detailList.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
}

extension HPInfoViewController: CLLocationManagerDelegate {
    // 사용자의 위치정보 제공에 대한 승인 상태
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        // 위치정보를 항상 제공하거나, 사용 중일때만 제공하거나, 별도의 설정이 없을 때
        case .authorizedAlways,
             .authorizedWhenInUse,
             .notDetermined:
            return
        default:
            viewModel.mapViewError.accept(MTMapViewError.locationAuthorizationDenied.errorDescription)
            return
        }
    }
}

extension HPInfoViewController: MTMapViewDelegate {
    // 현재 위치를 갱신
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        // 시뮬레이터에서 사용 할 때: 임의의 현재위치를 설정 해주어야 함
        #if DEBUG
        let lat = 37.394225
        let lon = 127.110341
        viewModel.currentLocation.accept(MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat, longitude: lon)))
        
        // 일반 기기에서 사용할 때: 현재 위치를 그대로 받을 수 있도록 설정
        #else
        viewModel.currentLocation.accept(location)
        
        #endif
    }
    
    // 지도를 드래그해서 위치를 설정하는 행위가 끝났을 때의 centerpoint를 전달
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    
    // pin표시 된 item을 선택 할 때마다 MTMapPOIItme을 전달
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        viewModel.selectedPOIItem.accept(poiItem)
        return false
    }
    
    // 제대로된 현재 위치를 받아오지 못했을 때 에러를 발생
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        viewModel.mapViewError.accept(error.localizedDescription)
    }
}

extension Reactive where Base: MTMapView {
    var setMapCenterPoint: Binder<MTMapPoint> {
        return Binder(base) { base, point in
            base.setMapCenter(point, animated: true)
        }
    }
}

extension Reactive where Base: HPInfoViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(title: "문제가 발생했습니다.", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            
            alertController.addAction(action)
            
            base.present(alertController, animated: true)
        }
    }
    
    var showSelectedLocation: Binder<Int> {
        return Binder(base) { base, row in
            let indexPath = IndexPath(row: row, section: 0)
            base.detailList.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    
    var addPOIItems: Binder<[MTMapPoint]> {
        return Binder(base) { base, point in
            let items = point
                .enumerated()
                .map { offset, point -> MTMapPOIItem in
                    let mapPOIItem = MTMapPOIItem()
                    
                    mapPOIItem.mapPoint = point
                    mapPOIItem.markerType = .redPin
                    mapPOIItem.showAnimationType = .springFromGround
                    mapPOIItem.tag = offset
                    
                    return mapPOIItem
                }
            
            base.mapView.removeAllPOIItems()
            base.mapView.addPOIItems(items)
        }
    }
}
