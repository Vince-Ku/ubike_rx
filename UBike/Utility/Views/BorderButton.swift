//
//  BorderBtn.swift
//  UBike
//
//  Created by Vince on 2021/5/14.
//

import UIKit

class BorderButton: ToggleButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            if oldValue {
                layer.borderColor = UIColor.gray.cgColor
            } else {
                layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
