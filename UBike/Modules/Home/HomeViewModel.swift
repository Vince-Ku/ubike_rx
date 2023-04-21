//
//  HomeViewModel.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import Foundation
import RxSwift
import RxRelay
import CoreLocation

class HomeViewModel {
    let disposeBag = DisposeBag()
    
    // MARK: DI
    private let locationManager: LocationManagerProxy
    
    //MARK: -- Input
    let viewDidLoad = PublishRelay<Void>()
    let showCurrentLocationBtnDidTap = PublishRelay<Void>()
    
    var refresh = BehaviorSubject<Void>(value: ())
    var selectAnnotation = PublishSubject<UBike>()
    var guideTap = PublishSubject<UBike>()
    
    //MARK: -- Output
    let showUserLocation = PublishRelay<(CLLocation?, CLLocationDistance?)>()
    
    var ubikes : Observable<[UBike]>!
    
    let repository = UbikeStationsRepository(remoteDataSource: AlamofireNetworkService.shared,
                                             ubikeStationCoreDataService: UBikeStationCoreDataService.shared)
    
    
    init(locationManager: LocationManagerProxy) {
        self.locationManager = locationManager
        setupLocation()
        
        
//        refresh
//            .flatMap { self.repository.getUbikeStations(isLatest: true) }
//            .subscribe(onNext: { result in
//                for each in result {
//                    print("---")
//                    print(each)
//                    print()
//                }
//            })
//            .disposed(by: disposeBag)
        
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
    
    private func setupLocation() {
        viewDidLoad
            .take(1).ignoreElements().asCompletable()
            .andThen(locationManager.requestAuthorizationIfNeeded())
            .andThen(locationManager.activate())
            .subscribe(onCompleted: { [weak self] in
                let location = self?.locationManager.getCurrentLocation()
                self?.showUserLocation.accept((location, 5000))
            })
            .disposed(by: disposeBag)
        
        showCurrentLocationBtnDidTap
            .withUnretained(self)
            .flatMap { owner, _ -> Maybe<CLLocation?> in
                owner.locationManager.requestAuthorizationIfNeeded()
                    .andThen(.just(owner.locationManager.getCurrentLocation()))
            }
            .subscribe(onNext: { [weak self] location in
                self?.showUserLocation.accept((location, nil))
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel{
    private func fetchUBikesApi() -> Single<GetUBikesResp> {
        return AlamofireNetworkService.shared.fetch(apiInterface: GetUBikesInterface())
    }
}
    
