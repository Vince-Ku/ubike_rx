//
//  UBikesFavoriteViewController.swift
//  UBike
//
//  Created by Vince on 2021/5/16.
//

import UIKit
import RxSwift
import RxCocoa

class UBikesFavoriteViewController : UIViewController {
    @IBOutlet unowned var collectionView : UICollectionView!

    weak var viewModel : UBikesViewModel!
    let refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupRx()
    }
    
    private func initUI(){
        collectionView.addSubview(refreshControl)
    }
    
    private func setupRx(){
        viewModel.loadingResult.subscribe(onNext:{ [weak self] resp in
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refresh)
            .disposed(by: disposeBag)
        
        viewModel.ubikesForFavorite.bind(to: collectionView.rx.items(cellIdentifier: "favoriteBikeItem", cellType: UBikeCollectionCell.self )){ [weak self] _, ubike, cell in
            cell.viewModel = self?.viewModel // must be set first
            cell.ubike = ubike
            
        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .flatMapLatest{ [weak self] indexPath -> Observable<UBike?> in
                let cell = self?.collectionView.cellForItem(at: indexPath) as? UBikeCollectionCell
                return Observable.just(cell?.ubike)
            }
            .bind(to: self.viewModel.ubikeCellTap)
            .disposed(by: disposeBag)
        
    }
    
}

extension UBikesFavoriteViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let size = CGSize(width: UIScreen.main.bounds.width - 10  , height: UIScreen.main.bounds.height / 4.1)
        
        return size
    }

}
