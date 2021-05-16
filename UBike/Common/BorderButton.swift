//
//  BorderBtn.swift
//  UBike
//
//  Created by Vince on 2021/5/14.
//

import UIKit

@IBDesignable
//temp
class BorderButton : UIButton{

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
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = bounds.height / 2
        
    }
}
