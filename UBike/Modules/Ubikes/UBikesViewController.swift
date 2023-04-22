//
//  UBikesViewController.swift
//  UBike
//
//  Created by Vince on 2021/5/16.
//

import UIKit
import RxSwift
import RxDataSources

class UBikesViewController : UIViewController {
    
    @IBOutlet unowned var favoriteContainerView: UIView!
    @IBOutlet unowned var areaContainerView: UIView!
    @IBOutlet unowned var favoriteBtn : UIButton!
    @IBOutlet unowned var areaBtn : UIButton!
    
    weak var homeViewModel : HomeViewModel?
    let viewModel = UBikesViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "areaBikesSegue":
            let areaVC = segue.destination as? UBikesAreaViewController
            areaVC?.viewModel = viewModel
            return
            
        case "favoriteBikesSegue":
            let favoriteVC = segue.destination as? UBikesFavoriteViewController
            favoriteVC?.viewModel = viewModel
            return
            
        default:
            print("unpredicted segue")
        }
    }
    
    private func setupRx(){
        //radio button
        Observable.merge(areaBtn.rx.tap.map{0} , favoriteBtn.rx.tap.map{1})
            .subscribe(onNext:{ [weak self] btnType in
                guard let self = self else { return }
                if btnType == 0{
                    self.favoriteBtn.isSelected = false
                    self.areaBtn.isSelected = !self.areaBtn.isSelected
                    self.favoriteContainerView.isHidden = true
                    self.areaContainerView.isHidden = false
                }else{
                    self.areaBtn.isSelected = false
                    self.favoriteBtn.isSelected = !self.favoriteBtn.isSelected
                    self.favoriteContainerView.isHidden = false
                    self.areaContainerView.isHidden = true
                }
                
            }).disposed(by: disposeBag)
        
        viewModel.ubikeCellTap.subscribe(onNext:{ [weak self] ubike in
            guard let ubike = ubike else { return }
            
            self?.navigationController?.popViewController(animated: true)
//            self?.homeViewModel?.selectAnnotation.onNext(ubike)

        }).disposed(by: disposeBag)
        
        if let homeViewModel = homeViewModel{
            
//            viewModel.guideBtnTap
//                .bind(to: homeViewModel.selectAnnotation)
//                .disposed(by: disposeBag)
            
//            viewModel.guideBtnTap
//                .do(onNext: { [weak self] _ in
//                    self?.navigationController?.popViewController(animated: true)
//                })
//                .bind(to: homeViewModel.guideTap)
//                .disposed(by: disposeBag)
            
        }
        
    }
    
}
