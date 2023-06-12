//
//  HPInfoViewController.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/13.
//

import UIKit
import RxSwift
import RxCocoa

class HPInfoViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        attribute()
        layout()
    }
    
    func bind() {
        
    }
    
    private func attribute() {
        title = "내 주변 병원 찾기"
        view.backgroundColor = .systemBackground
    }
    
    private func layout() {
        
    }
}
