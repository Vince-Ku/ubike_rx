//
//  UibikeStationBottomSheetStateMapper.swift
//  UBike
//
//  Created by Vince on 2023/4/22.
//

import Foundation
import MapKit

class UibikeStationBottomSheetStateMapper {
    
    func transform(ubikeStation: UbikeStation) -> UibikeStationBottomSheetState {
        .regular(UibikeStationBottomSheetState.ViewObject(id: ubikeStation.id,
                                                          nameText: ubikeStation.name.chinese))
    }
    
    func getNavigationText(route: MKRoute) -> String {
        let hours = Int(route.expectedTravelTime / 3600)
        let minutes = Int(route.expectedTravelTime.truncatingRemainder(dividingBy: 3600) / 60)
        let transportTypeText = getTransportTypeText(transportType: route.transportType)

        switch (hours, minutes) {
        case (0, 0): // less then one minute
            return "\(transportTypeText) 1 分鐘以內"
            
        case (0, _): // less then one hour
            return "\(transportTypeText) \(minutes) 分鐘"
            
        default :
            return "\(transportTypeText) \(hours) 小時 \(minutes) 分鐘"
        }
    }
    
    private func getTransportTypeText(transportType: MKDirectionsTransportType) -> String {
        switch transportType {
        case .walking:
            return "步行"
        case .automobile:
            return "開車"
        default:
            return "導航"
        }
    }
}
