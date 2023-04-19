//
//  Ubike_Station+CoreDataProperties.swift
//  UBike
//
//  Created by Vince on 2023/4/19.
//
//

import Foundation
import CoreData


extension Ubike_Station {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ubike_Station> {
        return NSFetchRequest<Ubike_Station>(entityName: "Ubike_Station")
    }

    @NSManaged public var id: String?
    @NSManaged public var name_ch: String?
    @NSManaged public var name_en: String?
    @NSManaged public var area_en: String?
    @NSManaged public var area_ch: String?
    @NSManaged public var address_en: String?
    @NSManaged public var address_ch: String?
    @NSManaged public var updated_date: Date?
    @NSManaged public var empty_parking_number: Int16
    @NSManaged public var bike_number: Int16
    @NSManaged public var total_parking_number: Int16
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension Ubike_Station : Identifiable {

}
