//
//  HomeViewModel.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import Foundation
import RxSwift

class HomeViewModel {
    let disposeBag = DisposeBag()
    
    //MARK: -- Input
    var refresh = BehaviorSubject<Void>(value: ())
    var selectAnnotation = PublishSubject<UBike>()
    var navigateTap = PublishSubject<UBike?>()
    
    //MARK: -- Output
    var ubikes : Observable<[UBike]>!
    
    init() {
        ubikes = refresh
            .flatMapLatest { [weak self] in
                self?.fetchUBikesApi().catchAndReturn(nil) ?? Observable.just(nil)
            }
            .flatMapLatest { resp -> Observable<[UBike]> in
                var ubikes : [UBike] = []
                for ubikeDic in resp?.retVal ?? [:] {
                    ubikes.append(ubikeDic.value)
                }
                
                return Observable<[UBike]>.just(ubikes)
            }
            .share()
    }
}

extension HomeViewModel{
    
    private func fetchUBikesApi() -> Observable<GetUBikesResp?>{
        return ApiRequest.fetchApi(requestDic: nil , urlPath: HttpPathEnum.GetUBikes.rawValue)
    }
    
}
    
