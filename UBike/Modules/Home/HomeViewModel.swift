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
    var guideTap = PublishSubject<UBike>()
    
    //MARK: -- Output
    var ubikes : Observable<[UBike]>!
    
    init() {
        ubikes = refresh
            .flatMapLatest { [weak self] _ -> Single<GetUBikesResp> in
                guard let self = self else { return .never() }
                
                return self.fetchUBikesApi()
            }
            .flatMapLatest { resp -> Observable<[UBike]> in
                var ubikes : [UBike] = []
                for ubikeDic in resp.retVal ?? [:] {
                    ubikes.append(ubikeDic.value)
                }
                
                return Observable<[UBike]>.just(ubikes)
            }
            .share()
    }
}

extension HomeViewModel{
    private func fetchUBikesApi() -> Single<GetUBikesResp> {
        return AlamofireNetworkService.shared.fetch(apiInterface: GetUBikesInterface())
    }
}
    
