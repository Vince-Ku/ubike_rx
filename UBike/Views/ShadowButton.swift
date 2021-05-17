//
//  ShadowButton.swift
//  UBike
//
//  Created by Vince on 2021/5/15.
//

import UIKit

@IBDesignable
class ShadowButton : UIButton{

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initStyle()
    }
    
    override func prepareForInterfaceBuilder() {
        initStyle()
    }
    
    func initStyle() {
        layer.cornerRadius = bounds.width / 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
}
