//
//  UBikeCollectionCell.swift
//  UBike
//
//  Created by Vince on 2021/5/16.
//

import UIKit
import RxSwift
import RxCocoa

class UBikeCollectionCell : UICollectionViewCell {
    @IBOutlet unowned var station : UILabel!
    @IBOutlet unowned var address : UILabel!
    @IBOutlet unowned var updateDate : UILabel!
    @IBOutlet unowned var favoriteBtn : UIButton!
    @IBOutlet unowned var guideBtn : BorderButton!
    @IBOutlet unowned var totalSpaces : UILabel!
    @IBOutlet unowned var bikesSpaces : UILabel!
    @IBOutlet unowned var emptySpaces : UILabel!
    
    weak var viewModel : UBikesViewModel?
    var disposeBag : DisposeBag!
    var ubikeCM : UBikeCellModel! {
        didSet{
            disposeBag = DisposeBag()
            
            station.text = ubikeCM.ubike.sna
            address.text = ubikeCM.ubike.ar
            bikesSpaces.text = ": \(ubikeCM.ubike.sbi ?? "")"
            totalSpaces.text = ": \(ubikeCM.ubike.tot ?? "")"
            emptySpaces.text = ": \(ubikeCM.ubike.bemp ?? "")"
            
            if let mday = ubikeCM.ubike.mday{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"

                if let date = dateFormatter.date(from: mday){
                    dateFormatter.dateFormat = "MM-dd HH:mm:ss"
                    updateDate.text = dateFormatter.string(from: date)
                }
            }
            
            favoriteBtn.isSelected = ubikeCM.isFavorite
            
            if let viewModel = viewModel {
                guideBtn.rx.controlEvent(.touchUpInside)
                    .flatMapLatest{ [ubikeCM] _ -> Observable<UBike> in
                        return Observable.just(ubikeCM!.ubike)
                    }
                    .bind(to: viewModel.guideBtnTap)
                    .disposed(by: disposeBag)
                
                favoriteBtn.rx.controlEvent(.touchUpInside)
                    .do(onNext:{ [unowned self] in
                        self.favoriteBtn.isSelected = !self.favoriteBtn.isSelected
                    })
                    .map{ [unowned self] in
                        [self.reuseIdentifier! : UBikeCellModel(ubike: self.ubikeCM.ubike, isFavorite: self.favoriteBtn.isSelected) ]
                    }
                    .bind(to: viewModel.favoriteBtnTap)
                    .disposed(by: disposeBag)
            }
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //disposeBag = DisposeBag()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.layer.cornerRadius = bounds.height / 7
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.masksToBounds = true
        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        layer.shadowRadius = bounds.height / 7
//        layer.shadowOpacity = 0.2
//        layer.masksToBounds = false
        //layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius:
    }
    
}

struct UBikeCellModel {
    var ubike : UBike
    var isFavorite : Bool
}
