//
//  BorderBtn.swift
//  UBike
//
//  Created by Vince on 2021/5/14.
//

import UIKit

@IBDesignable
class BorderButton: IdentifiableButton {

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = bounds.height / 2
    }
    
    func initStyle() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = bounds.height / 2
    }
}
