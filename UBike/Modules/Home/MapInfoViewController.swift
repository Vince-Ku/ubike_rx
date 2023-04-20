//
//  MapInfoViewController.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import UIKit
import RxSwift
import RxCocoa

class MapInfoViewController : UIViewController {
    @IBOutlet unowned var mainView : UIView!
    @IBOutlet unowned var guideBtn : UIButton!
    @IBOutlet unowned var favoriteBtn : UIButton!
    @IBOutlet unowned var stationName : UILabel!
    @IBOutlet unowned var bikesSpace : UILabel!
    @IBOutlet unowned var emptySpace : UILabel!
    
    weak var homeViewModel : HomeViewModel!
    var disposeBag : DisposeBag!
    
    var ubike : UBike! {
        didSet{
            disposeBag = DisposeBag()
            
            guideBtn.isEnabled = true
            favoriteBtn.isEnabled = true
            
            let favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: LocalStorageConstants.UserDefaults.favoriteUbikeStationsData) as! [String:Bool]
            
            let isSelected = favoriteUbikes
                                    .filter{ $0.key == ubike?.sno ?? "none" }
                                    .first?.value
            favoriteBtn.isSelected = isSelected ?? false
            
            //station name
            stationName.text = ubike?.sna
            
            //ubikes space & empty space
            if let empty = Int(ubike?.bemp ?? "") , let bikes = Int(ubike?.sbi ?? "") {
                bikesSpace.text = ": \(bikes)"
                emptySpace.text = ": \(empty)"
            }else{
                bikesSpace.text = ": 錯誤"
                emptySpace.text = ": 錯誤"
            }
            
            favoriteBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [weak self] in
                guard let self = self , let station = self.ubike?.sno else {return}
                self.favoriteBtn.isSelected = !self.favoriteBtn.isSelected
                
                var favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: LocalStorageConstants.UserDefaults.favoriteUbikeStationsData) as! [String:Bool]
                
                favoriteUbikes.updateValue(self.favoriteBtn.isSelected, forKey: station)
                UserDefaults.standard.setValue(favoriteUbikes, forKey: LocalStorageConstants.UserDefaults.favoriteUbikeStationsData)
                
            }).disposed(by:disposeBag)
            
            guideBtn.rx.controlEvent(.touchUpInside)
                .flatMapLatest{ [ubike] _ -> Observable<UBike> in
                    return Observable.just(ubike!)
                }
                .bind(to: homeViewModel.guideTap)
                .disposed(by: disposeBag)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.layer.cornerRadius = view.bounds.height / 8
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowRadius = view.bounds.height / 8
        mainView.layer.shadowOpacity = 0.3
    }
    
}
