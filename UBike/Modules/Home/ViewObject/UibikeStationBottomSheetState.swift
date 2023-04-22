//
//  UibikeStationBottomSheetState.swift
//  UBike
//
//  Created by Vince on 2023/4/22.
//

enum UibikeStationBottomSheetState {
    case regular(ViewObject)
    case empty
    
    struct ViewObject {
        let nameText: String
        let bikeSpaceText: String
        let emptySpaceText: String
        let isFavorite: Bool
    }
}
