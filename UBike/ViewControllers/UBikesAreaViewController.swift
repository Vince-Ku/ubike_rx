//
//  UBikesAreaViewController.swift
//  UBike
//
//  Created by Vince on 2021/5/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UBikesAreaViewController : UIViewController {
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
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, [UBike]>>(
            configureCell: { [weak self] (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "areaBikesItem", for: indexPath) as! UBikesCollectionCell
                cell.viewModel = self?.viewModel
                cell.ubikes = element
                return cell
            },
            configureSupplementaryView: {
                (ds ,cv, kind, ip) in
                let section = cv.dequeueReusableSupplementaryView(ofKind: kind,
                                                                  withReuseIdentifier: "bikeItemHeader", for: ip) as! UBikesCollectionCellHeader
                section.stationArea.text = "\(ds[ip.section].model)"
                return section
            }
        )
        
        viewModel.ubikesForArea
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

extension UBikesAreaViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let size = CGSize(width: UIScreen.main.bounds.width , height: 200 * 2 + 20)
        
        return size
    }

}
