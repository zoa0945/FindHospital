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
        // currentLocationButton이 눌러졌을 때의 이벤트
        currentLocationButton.rx.tap
            .bind(to: viewModel.currentLocationButtonTapped)
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
            // viewModel.mapViewError.accept()
            return
        }
    }
}

extension HPInfoViewController: MTMapViewDelegate {
    // 현재 위치를 갱신
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        // 시뮬레이터에서 사용 할 때: 임의의 현재위치를 설정 해주어야 함
        #if DEBUG
        // viewModel.currentLocation.accept()
        
        // 일반 기기에서 사용할 때: 현재 위치를 그대로 받을 수 있도록 설정
        #else
        // viewModel.currentLocation.accept(location)
        
        #endif
    }
    
    // 지도를 드래그해서 위치를 설정하는 행위가 끝났을 때의 centerpoint를 전달
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        // viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    
    // pin표시 된 item을 선택 할 때마다 MTMapPOIItme을 전달
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        // viewModel.selectPOIItem.accept(poiItem)
        return false
    }
    
    // 제대로된 현재 위치를 받아오지 못했을 때 에러를 발생
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        // viewModel.mapViewError.accept(error.localizedDescription)
    }
}
