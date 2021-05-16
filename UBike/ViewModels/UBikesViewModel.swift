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
    var navigateBtnTap = PublishSubject<UBike?>()
    
    //MARK: -- Output
    var loadingResult : Observable<GetUBikesResp?>!
    var ubikesForArea = BehaviorRelay<[SectionModel<String, [UBike]>]>(value: [])
    var ubikesForFavorite = BehaviorRelay<[UBike]>(value: [])
    
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
            .flatMapLatest { resp ,_, _ -> Observable<[UBike]> in
                var ubikes : [UBike] = []
                
                let favoriteUbikes : [String:Bool] = UserDefaults.standard.value(forKey: ubilkesFavoriteKey) as! [String:Bool]
                
                //temp for preformance
                for ubikeDic in resp?.retVal ?? [:] {
                    for favoriteUbike in favoriteUbikes{
                        if let sno = ubikeDic.value.sno {
                            if favoriteUbike.key == sno && favoriteUbike.value{
                                ubikes.append(ubikeDic.value)
                            }
                        }
                    }
                }
                
                ubikes.sort(by: { first, second in
                    // order by bikes number ASC
                    return Int(first.sbi ?? "0") ?? 0 > Int(second.sbi ?? "0") ?? 0
                })
                
                return Observable.just(ubikes)
            }
            .bind(to: ubikesForFavorite)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(loadingResult,refreshAreaAndFavorite)
                .flatMapLatest { resp , _  -> Observable<[SectionModel<String, [UBike]>]> in
                    var ubikes : [UBike] = []
                    for ubikeDic in resp?.retVal ?? [:] {
                        ubikes.append(ubikeDic.value)
                    }
                    
                    var sectionModels : [SectionModel<String, [UBike]>] = []
                    
                    let ubikesGroupAndSort = Dictionary(grouping: ubikes, by: {$0.sarea ?? ""})
                                                        .sorted(by: { first, second in
                                                            return first.key > second.key
                                                        })
                    
                    for (sectionTitle,items) in ubikesGroupAndSort {
                        var sortItems = items
                        sortItems.sort(by: { first, second in
                            // order by bikes number ASC
                            return Int(first.sbi ?? "0") ?? 0 > Int(second.sbi ?? "0") ?? 0
                        })
                        sectionModels.append(
                            SectionModel(model: sectionTitle , items: [sortItems])
                        )
                    }
                
                    return Observable.just(sectionModels)
                }
                .bind(to: ubikesForArea)
                .disposed(by: disposeBag)
        
        }
}

extension UBikesViewModel{
    
    private func fetchUBikesApi() -> Observable<GetUBikesResp?>{
        return ApiRequest.fetchApi(requestDic: nil , urlPath: HttpPathEnum.GetUBikes.rawValue)
    }
    
}
