//
//  ToggleButton.swift
//  UBike
//
//  Created by Vince on 2023/4/23.
//

import UIKit

class ToggleButton: UIButton {
    var id: String?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isSelected.toggle()
    }
}
