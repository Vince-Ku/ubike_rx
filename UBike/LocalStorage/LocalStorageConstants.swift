//
//  LocalStorageConstants.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import Foundation

struct LocalStorageConstants {
    // MARK: UserDefaults
    struct UserDefaults {
        static let ubikeStationsData = "userdefaults.ubike.stations"
        static let favoriteUbikeStationsData = "userdefaults.favorite.ubike.stations"
    }
    
    // MARK: CoreData
    struct CoreData {
        struct RelationShip {
            static let favorite = "favorite"
        }
    }
}
