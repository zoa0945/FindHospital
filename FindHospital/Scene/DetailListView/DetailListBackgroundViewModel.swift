//
//  DetailListBackgroundViewModel.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/20.
//

import RxSwift
import RxCocoa

class DetailListBackgroundViewModel {
    let isStatusLabelHidden: Signal<Bool>
    
    let shouldHideStatusLabel = PublishSubject<Bool>()
    
    init() {
        isStatusLabelHidden = shouldHideStatusLabel
            .asSignal(onErrorJustReturn: true)
    }
}
