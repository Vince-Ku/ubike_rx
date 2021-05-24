//
//  UBikesCollectionCell.swift
//  UBike
//
//  Created by Vince on 2021/5/15.
//

import UIKit
import RxSwift
import RxCocoa

class UBikesCollectionCellHeader : UICollectionReusableView {
    @IBOutlet unowned var stationArea : UILabel!
}

class UBikesCollectionCell : UICollectionViewCell {
    @IBOutlet unowned var ubikeCV : UICollectionView!
    @IBOutlet unowned var ubikeCVLayout : UICollectionViewFlowLayout!
    
    weak var viewModel : UBikesViewModel?
    var disposeBag : DisposeBag!
    
    var ubikesCM : [UBikeCellModel] = [] {
        didSet{
            disposeBag = DisposeBag()
            
            Observable.just(ubikesCM)
                .bind(to: ubikeCV.rx.items(cellIdentifier: "bikeItem", cellType: UBikeCollectionCell.self )){ [weak self] _, ubikeCM, cell in
                    cell.viewModel = self?.viewModel
                    cell.ubikeCM = ubikeCM
                }.disposed(by: disposeBag)
            
            if let viewModel = viewModel {
                ubikeCV.rx.itemSelected
                    .flatMapLatest{ [weak self] indexPath -> Observable<UBike?> in
                        let cell = self?.ubikeCV.cellForItem(at: indexPath) as? UBikeCollectionCell
                        return Observable.just(cell?.ubikeCM.ubike)
                    }
                    .bind(to: viewModel.ubikeCellTap)
                    .disposed(by: disposeBag)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
extension UBikesCollectionCell : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        // you have to make sectionInset half of minimumLineSpacing, in order to support page scrolling
        let gap = ubikeCVLayout.minimumLineSpacing
        let size = CGSize(width: UIScreen.main.bounds.width - gap , height: 200)
        
        return size
    }
    
}

