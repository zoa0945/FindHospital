//
//  MTMapViewError.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/15.
//

import Foundation

enum MTMapViewError: Error {
    case failedUpdatingCurrentLocation
    case locationAuthorizationDenied
    
    var errorDescription: String {
        switch self {
        case .failedUpdatingCurrentLocation:
            return "현재 위치를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요."
        case .locationAuthorizationDenied:
            return "위치 정보 제공을 비활성화하면 사용자의 현재 위치를 알 수 없습니다."
        }
    }
}
