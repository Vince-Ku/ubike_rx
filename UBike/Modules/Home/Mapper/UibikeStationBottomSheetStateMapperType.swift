//
//  UibikeStationBottomSheetStateMapperType.swift
//  UBike
//
//  Created by Vince on 2023/4/27.
//

import MapKit

protocol UibikeStationBottomSheetStateMapperType {
    func getNavigationText(route: MKRoute) -> String
}
