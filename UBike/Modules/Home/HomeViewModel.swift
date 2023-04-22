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

    // MARK: DI
    private let locationManager: LocationManagerProxy
    private let ubikeStationsRepository: UbikeStationsRepository
    
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    let viewDidLoad = PublishRelay<Void>()
    let showCurrentLocationBtnDidTap = PublishRelay<Void>()
    var refreshButtonDidTap = PublishRelay<Void>()

    var selectAnnotation = PublishSubject<UBike>()
    var guideTap = PublishSubject<UBike>()
    
    // MARK: Output
    let showUserLocation = PublishRelay<(CLLocation?, CLLocationDistance?)>()
    let showUibikeStationsAnnotation = BehaviorRelay<[UBikeStationAnnotation]>(value: [])
    
    init(locationManager: LocationManagerProxy, ubikeStationsRepository: UbikeStationsRepository) {
        self.locationManager = locationManager
        self.ubikeStationsRepository = ubikeStationsRepository
        
        setupLocation()
        setupUbikeStations()
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
    
    private func setupUbikeStations() {
        Observable.merge(viewDidLoad.asObservable().take(1), refreshButtonDidTap.asObservable())
            .flatMapLatest { [weak self] _ -> Single<[UbikeStation]> in
                self?.ubikeStationsRepository.getUbikeStations(isLatest: true) ?? .never()
            }
            .map {
                $0.map { UBikeStationAnnotation(ubikeStation: $0) }
            }
            .bind(to: showUibikeStationsAnnotation)
            .disposed(by: disposeBag)
    }
}
