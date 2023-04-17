//
//  UBikePointAnnotation.swift
//  UBike
//
//  Created by Vince on 2021/5/14.
//

import MapKit
import SnapKit

class UBikeAnnotation: MKPointAnnotation {
    var ubike : UBike?
}

class UBikeAnnotationView : MKAnnotationView {
    
    let bikesSpaceLabel = UILabel()
    
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
    
    override var annotation: MKAnnotation? {
        didSet{
            let annotation = annotation as? UBikeAnnotation
            
            if let bikesSpace = annotation?.ubike?.sbi  {
                bikesSpaceLabel.text = bikesSpace
                
                if let emptySpace = Int(annotation?.ubike?.bemp ?? "") {
                    
                    // according to remaining parking space to set the image
                    if Int(bikesSpace) == 0{
                        image = UIImage(named: "icon_pin_red")
                    }else if emptySpace == 0{
                        image = UIImage(named: "icon_pin_brown")
                    }else{
                        image = UIImage(named: "icon_pin_green")
                    }
                }
            }
            bikesSpaceLabel.font = UIFont.boldSystemFont(ofSize: 12)
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
    
}
