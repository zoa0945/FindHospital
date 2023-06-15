//
//  KLDocument.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/15.
//

import Foundation

struct KLDocument: Codable {
    let placeName: String
    let categoryName: String
    let addressName: String
    let roadAddressName: String
    let x: String
    let y: String
    let distance: String
    
    enum CodingKeys: String, CodingKey {
        case x, y, distance
        case placeName = "place_name"
        case categoryName = "category_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
    }
}
