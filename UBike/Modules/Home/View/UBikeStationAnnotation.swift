//
//  UBikeStationAnnotation.swift
//  UBike
//
//  Created by Vince on 2021/5/14.
//

import MapKit

class UBikeStationAnnotation: MKPointAnnotation {
    let ubikeStation: UbikeStation
    
    init(ubikeStation: UbikeStation) {
        self.ubikeStation = ubikeStation
        
        super.init()
        coordinate = CLLocationCoordinate2D(latitude: ubikeStation.coordinate.latitude,
                                            longitude: ubikeStation.coordinate.longitude)
    }
}
