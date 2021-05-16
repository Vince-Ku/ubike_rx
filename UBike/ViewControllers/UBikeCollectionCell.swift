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
    @IBOutlet unowned var navigationBtn : BorderButton!
    @IBOutlet unowned var totalSpaces : UILabel!
    @IBOutlet unowned var bikesSpaces : UILabel!
    @IBOutlet unowned var emptySpaces : UILabel!
    
    weak var viewModel : UBikesViewModel?
    var disposeBag : DisposeBag!
    var ubike : UBike! {
        didSet{
            disposeBag = DisposeBag()
            
            station.text = ubike.sna
            address.text = ubike.ar
            bikesSpaces.text = ": \(ubike.sbi ?? "")"
            totalSpaces.text = ": \(ubike.tot ?? "")"
            emptySpaces.text = ": \(ubike.bemp ?? "")"
            
            if let mday = ubike.mday{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"

                if let date = dateFormatter.date(from: mday){
                    dateFormatter.dateFormat = "MM-dd HH:mm:ss"
                    updateDate.text = dateFormatter.string(from: date)
                }
            }
            
            let favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
            
            let isSelected = favoriteUbikes
                                    .filter{ $0.key == ubike?.sno ?? "none" }
                                    .first?.value
            favoriteBtn.isSelected = isSelected ?? false
            
            favoriteBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [weak self] in
                guard let self = self , let station = self.ubike?.sno else {return}
                self.favoriteBtn.isSelected = !self.favoriteBtn.isSelected
                
                var favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]

                favoriteUbikes.updateValue(self.favoriteBtn.isSelected, forKey: station)
                UserDefaults.standard.setValue(favoriteUbikes, forKey: ubilkesFavoriteKey)
                
                //refresh data without fetching API
                if self.reuseIdentifier == "bikeItem" {
                    self.viewModel?.refreshFavorite.onNext(())
                    
                }else if self.reuseIdentifier == "favoriteBikeItem"{
                    self.viewModel?.refreshAreaAndFavorite.onNext(())
                }
                
            }).disposed(by: disposeBag)
            
            if let viewModel = viewModel {
                navigationBtn.rx.controlEvent(.touchUpInside)
                    .flatMapLatest{ [weak self] _ -> Observable<UBike?> in
                        return Observable.just(self?.ubike)
                    }
                    .bind(to: viewModel.navigateBtnTap)
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
