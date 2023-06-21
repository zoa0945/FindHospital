//
//  HPInfoViewModel.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/15.
//

import RxSwift
import RxCocoa

class HPInfoViewModel {
    let disposeBag = DisposeBag()
    
    // subViewModel 연결
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    // viewModel에서 view로 전달 되는 이벤트
    let setMapCenter: Signal<MTMapPoint>
    let errorMessage: Signal<String>
    let detailListCellData: Driver<[DetailListCellData]>
    let scrollToSelectedLocation: Signal<Int>
    
    // view에서 viewModel로 전달 되는 이벤트
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectedPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLocationButtonTapped = PublishRelay<Void>()
    let detailListItemSeleted = PublishRelay<Int>()
    
    let documentData = PublishSubject<[KLDocument]>()
    
    init(model: HPInfoModel = HPInfoModel()) {
        // MARK: - 네트워크 통신으로 데이터 불러오기
        // mapCenterPoint를 받을 때마다 Network통신
        let HPLocationDataResult = mapCenterPoint
            .flatMapLatest(model.getLocation)
            .share()
        
        let HPLocationDataValue = HPLocationDataResult
            .compactMap { result -> LocationData? in
                guard case let .success(value) = result else {
                    return nil
                }
                return value
            }
        
        let HPLocationDataError = HPLocationDataResult
            .compactMap { result -> String? in
                switch result {
                case let .success(result) where result.documents.isEmpty:
                    return "500m내에 이용 가능한 병원이 없습니다."
                case let .failure(error):
                    return error.localizedDescription
                default:
                    return nil
                }
            }
        
        HPLocationDataValue
            .map { data in
                return data.documents
            }
            .bind(to: documentData)
            .disposed(by: disposeBag)
        
        // MARK: - 지도 중심점 설정
        // 선택된 Item이 중심으로 오도록 이동해야 하는 경우
        let selectDetailListItem = detailListItemSeleted
            .withLatestFrom(documentData) { row, document in
                return document[row]
            }
            .map { data -> MTMapPoint in
                guard let lon = Double(data.x),
                      let lat = Double(data.y) else {
                    return MTMapPoint()
                }
                let geoCoord = MTMapPointGeo(latitude: lat, longitude: lon)
                return MTMapPoint(geoCoord: geoCoord)
            }
        
        // mapCenter로 이동되어야 하는 경우
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(currentLocation)
        
        let currentMapCenter = Observable
            .merge(
                selectDetailListItem,
                currentLocation.take(1),
                moveToCurrentLocation
            )
        
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        errorMessage = Observable
            .merge(
                HPLocationDataError,
                mapViewError.asObservable()
            )
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
        
        detailListCellData = documentData
            .map(model.documentToCellData(_:))
            .asDriver(onErrorDriveWith: .empty())
        
        // documentData에 값이 있는지 없는지 DetailListBackgroundView에 전달
        documentData
            .map{ !$0.isEmpty }
            .bind(to: detailListBackgroundViewModel.shouldHideStatusLabel)
            .disposed(by: disposeBag)
        
        scrollToSelectedLocation = selectedPOIItem
            .map({ poiItem in
                return poiItem.tag
            })
            .asSignal(onErrorJustReturn: 0)
    }
}
