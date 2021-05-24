//
//  UBikesViewModel.swift
//  UBike
//
//  Created by Vince on 2021/5/15.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

class UBikesViewModel {
    let disposeBag = DisposeBag()
    
    //MARK: -- Input
    var refresh = BehaviorSubject<Void>(value: ())
    var refreshFavorite = BehaviorSubject<Void>(value: ())
    var refreshAreaAndFavorite = BehaviorSubject<Void>(value: ())
    var ubikeCellTap = PublishSubject<UBike?>()
    var guideBtnTap = PublishSubject<UBike>()
    var favoriteBtnTap = PublishSubject<[String:UBikeCellModel]>()
    
    //MARK: -- Output
    var loadingResult : Observable<GetUBikesResp?>!
    var ubikesForArea = BehaviorRelay<[SectionModel<String, [UBikeCellModel]>]>(value: [])
    var ubikesForFavorite = BehaviorRelay<[UBikeCellModel]>(value: [])
    
    init() {
        loadingResult = refresh
                        .do(onNext: { [weak self] in
                            self?.ubikesForArea.accept([])
                            self?.ubikesForFavorite.accept([])
                        })
                        //.delay(.milliseconds(1500), scheduler: MainScheduler.instance)
                        .flatMapLatest { [weak self] in
                            self?.fetchUBikesApi().catchAndReturn(nil) ?? Observable.just(nil)
                        }
                        .share()
        
        Observable.combineLatest(loadingResult,refreshAreaAndFavorite, refreshFavorite)
            .flatMapLatest { resp ,_, _ -> Observable<[UBikeCellModel]> in
                var ubikesCM : [UBikeCellModel] = []
                
                let favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
                
                for ubikeDic in resp?.retVal ?? [:] {
                    for favoriteUbike in favoriteUbikes{
                        if let sno = ubikeDic.value.sno {
                            if favoriteUbike.key == sno && favoriteUbike.value {
                                ubikesCM.append(UBikeCellModel(ubike: ubikeDic.value, isFavorite: favoriteUbike.value) )
                            }
                        }
                    }
                }
                
                ubikesCM.sort(by: { first, second in
                    // order by bikes number DESC
                    return Int(first.ubike.sbi ?? "0") ?? 0 > Int(second.ubike.sbi ?? "0") ?? 0
                })
                
                return Observable.just(ubikesCM)
            }
            .bind(to: ubikesForFavorite)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(loadingResult,refreshAreaAndFavorite)
                .flatMapLatest { resp , _  -> Observable<[SectionModel<String, [UBikeCellModel]>]> in
                    var ubikesCM : [UBikeCellModel] = []
                    
                    let favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
                    
                    for ubikeDic in resp?.retVal ?? [:] {
                        if let sno = ubikeDic.value.sno {
                            var ubikeCM = UBikeCellModel(ubike: ubikeDic.value, isFavorite: false)
                            for favoriteUbike in favoriteUbikes{
                                if favoriteUbike.key == sno && favoriteUbike.value {
                                    ubikeCM.isFavorite = true
                                }
                            }
                            ubikesCM.append(ubikeCM)
                        }
                    }
                    
                    var sectionModels : [SectionModel<String, [UBikeCellModel]>] = []
                    
                    let ubikesGroupAndSort = Dictionary(grouping: ubikesCM, by: {$0.ubike.sarea ?? ""})
                                                        .sorted(by: { first, second in
                                                            return first.key > second.key
                                                        })
                    
                    for (sectionTitle,items) in ubikesGroupAndSort {
                        var sortItems = items
                        sortItems.sort(by: { first, second in
                            // order by bikes number DESC
                            return Int(first.ubike.sbi ?? "0") ?? 0 > Int(second.ubike.sbi ?? "0") ?? 0
                        })
                        sectionModels.append(
                            SectionModel(model: sectionTitle , items: [sortItems])
                        )
                    }
                
                    return Observable.just(sectionModels)
                }
                .bind(to: ubikesForArea)
                .disposed(by: disposeBag)
        
        favoriteBtnTap.subscribe(onNext:{ [weak self] dic in
            
            for (reuseIdentifier,cellModel) in dic {
                guard let station = cellModel.ubike.sno else { return }
                
                var favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
                favoriteUbikes.updateValue(cellModel.isFavorite, forKey: station)
                UserDefaults.standard.setValue(favoriteUbikes, forKey: ubilkesFavoriteKey)

                //refresh data without fetching API
                if reuseIdentifier == "bikeItem" {
                    self?.refreshFavorite.onNext(())

                }else if reuseIdentifier == "favoriteBikeItem"{
                    self?.refreshAreaAndFavorite.onNext(())
                }
            }
            
        }).disposed(by: disposeBag)
    }
}

extension UBikesViewModel{
    private func fetchUBikesApi() -> Observable<GetUBikesResp?>{
        return ApiRequest.fetchApi(requestDic: nil , urlPath: HttpPathEnum.GetUBikes.rawValue)
    }
    
}
