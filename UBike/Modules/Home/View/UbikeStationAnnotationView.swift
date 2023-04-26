//
//  UbikeStationAnnotationView.swift
//  UBike
//
//  Created by Vince on 2023/4/22.
//

import MapKit
import SnapKit

class UbikeStationAnnotationView: MKAnnotationView {
    private let bikesSpaceLabel = UILabel()
    private let scale = 1.4
    private let animationDuration = 0.3
    
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        
        if selected {
            animate(from: 1, to: scale)
        } else {
            animate(from: scale, to: 1)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        // make bottom center of view anchor the map location
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        addSubview(bikesSpaceLabel)
        
        bikesSpaceLabel.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup(ubikeStation: UbikeStation) {
        let bikeSpace = ubikeStation.parkingSpace.bike
        let emptySpace = ubikeStation.parkingSpace.empty
        
        bikesSpaceLabel.text = String(bikeSpace)
        bikesSpaceLabel.font = .boldSystemFont(ofSize: 12)

        if bikeSpace == 0 {
            image = UIImage(named: "icon_pin_red")
        } else if emptySpace == 0 {
            image = UIImage(named: "icon_pin_brown")
        } else {
            image = UIImage(named: "icon_pin_green")
        }
    }
    
    private func animate(from: Double, to: Double) {
        // Create the animation
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = animationDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.fromValue = from
        animation.toValue = to

        // Add the animation to the annotation view's layer
        layer.add(animation, forKey: "scaleAnimation")
    }
}
