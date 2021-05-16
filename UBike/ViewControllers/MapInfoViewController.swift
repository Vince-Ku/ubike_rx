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
    
    var ubike : UBike? {
        didSet{
            disposeBag = DisposeBag()
            let favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
            
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
                
                var favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
                
                favoriteUbikes.updateValue(self.favoriteBtn.isSelected, forKey: station)
                UserDefaults.standard.setValue(favoriteUbikes, forKey: ubilkesFavoriteKey)
                
            }).disposed(by:disposeBag)
            
            guideBtn.rx.controlEvent(.touchUpInside)
                .flatMapLatest{ [weak self] _ -> Observable<UBike?> in
                    return Observable.just(self?.ubike)
                }
                .bind(to: homeViewModel.navigateTap)
                .disposed(by: disposeBag)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // temp -- how to calculate cornerRadius
        mainView.layer.cornerRadius = 19
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowRadius = 30
        mainView.layer.shadowOpacity = 0.3
        //mainView.layer.masksToBounds = false
    }
    
    private func setupRx(){
        
    }
}
