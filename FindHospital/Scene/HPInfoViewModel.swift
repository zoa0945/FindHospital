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
    let currentLocationButtonTapped = PublishRelay<Void>()
}
