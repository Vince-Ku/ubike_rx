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
        let id: String
        let nameText: String
    }
}
