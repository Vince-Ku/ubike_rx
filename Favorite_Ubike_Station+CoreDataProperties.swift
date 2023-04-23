//
//  Favorite_Ubike_Station+CoreDataProperties.swift
//  UBike
//
//  Created by Vince on 2023/4/23.
//
//

import Foundation
import CoreData


extension Favorite_Ubike_Station {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite_Ubike_Station> {
        return NSFetchRequest<Favorite_Ubike_Station>(entityName: "Favorite_Ubike_Station")
    }

    @NSManaged public var id: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var ubike_station: Ubike_Station?

}

extension Favorite_Ubike_Station : Identifiable {

}
