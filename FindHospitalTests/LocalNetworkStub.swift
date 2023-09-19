//
//  LocalNetworkStub.swift
//  FindHospitalTests
//
//  Created by Nam Hoon Jeong on 2023/08/31.
//

import Foundation
import RxSwift
import Stubber

@testable import FindHospital

class LocalNetworkStub: LocalNetwork {
    override func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        <#code#>
    }
}
