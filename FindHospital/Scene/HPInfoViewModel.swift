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
    
    // viewModel에서 view로 전달 되는 이벤트
    let setMapCenter: Signal<MTMapPoint>
    let errorMessage: Signal<String>
    
    // view에서 viewModel로 전달 되는 이벤트
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectedPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    
    let currentLocationButtonTapped = PublishRelay<Void>()
    
    init() {
        // MARK: - 지도 중심점 설정
        // mapCenter로 이동되어야 하는 경우
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(currentLocation)
        
        let currentMapCenter = Observable
            .merge(
                currentLocation.take(1),
                moveToCurrentLocation
            )
        
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        errorMessage = mapViewError.asObservable()
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
    }
}
