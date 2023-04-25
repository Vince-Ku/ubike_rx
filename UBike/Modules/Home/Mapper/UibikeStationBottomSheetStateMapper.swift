//
//  UibikeStationBottomSheetStateMapper.swift
//  UBike
//
//  Created by Vince on 2023/4/22.
//

import Foundation

class UibikeStationBottomSheetStateMapper {
    
    func transform(ubikeStation: UbikeStation) -> UibikeStationBottomSheetState {
        .regular(UibikeStationBottomSheetState.ViewObject(id: ubikeStation.id,
                                                          nameText: ubikeStation.name.chinese))
    }
    
//bikeSpaceText: String(ubikeStation.parkingSpace.bike),
//emptySpaceText: String(ubikeStation.parkingSpace.empty),
//isFavorite: ubikeStation.isFavorite)
}
