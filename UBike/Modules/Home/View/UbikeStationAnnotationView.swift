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
    
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        if selected{
            bikesSpaceLabel.font = UIFont.boldSystemFont(ofSize: 14)
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width * 1.5, height: frame.size.height * 1.5))
            
        }else{
            bikesSpaceLabel.font = UIFont.boldSystemFont(ofSize: 12)
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width / 1.5, height: frame.size.height / 1.5))
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
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
}
