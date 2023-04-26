//
//  RoundedRectangleShadowButton.swift
//  UBike
//
//  Created by Vince on 2021/5/15.
//

import UIKit

class RoundedRectangleShadowButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 4
        layer.shadowRadius = bounds.width / 4
    }
}
