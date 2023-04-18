//
//  UbikeStation.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import Foundation

struct UbikeStation: Codable {
    
    struct Name: Codable {
        let english: String
        let chinese: String
    }
    
    struct Area: Codable {
        let english: String
        let chinese: String
    }
    
    struct Coordinate: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    struct Address: Codable {
        let english: String
        let chinese: String
    }
    
    struct ParkingSpace: Codable {
        let total: Int  // 所有停車格數量
        let bike: Int   // 有停車的停車格數量
        let empty: Int  // 空停車格數量
    }
    
    let id: String                          // 站點代號
    let name: Name                          // 場站中文名稱
    let area: Area                          // 場站區域
    let coordinator: Coordinate?            // 場站座標
    let address: Address                    // 地址 (中、英文)
    let parkingSpace: ParkingSpace          // 場站停車格
    let updatedDate: Date?                  // 資料更新時間
}
