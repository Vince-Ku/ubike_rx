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
    private let mapper: UibikeStationBottomSheetStateMapper
    
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    let viewDidLoad = PublishRelay<Void>()
    let showCurrentLocationBtnDidTap = PublishRelay<Void>()
    let refreshButtonDidTap = PublishRelay<Void>()
    let annotationDidSelect = PublishRelay<UbikeStation>()
    let annotationDidDeselect = PublishRelay<UbikeStation>()
    let favoriteStationButtonDidTap = PublishRelay<Void>()
    let navigationButtonDidTap = PublishRelay<Void>()

    // MARK: Output
    let showUserLocation = PublishRelay<(CLLocation?, CLLocationDistance?)>()
    let showUibikeStationsAnnotation = BehaviorRelay<[UBikeStationAnnotation]>(value: [])
    let updateUibikeStationBottomSheet = BehaviorRelay<UibikeStationBottomSheetState>(value: .empty)
    
    init(locationManager: LocationManagerProxy, ubikeStationsRepository: UbikeStationsRepository, mapper: UibikeStationBottomSheetStateMapper) {
        self.locationManager = locationManager
        self.ubikeStationsRepository = ubikeStationsRepository
        self.mapper = mapper
        
        setupLocation()
        setupUbikeStations()
        setupAnnotation()
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
    
    private func setupAnnotation() {
        annotationDidSelect
            .map { CLLocation(latitude: $0.coordinator.latitude, longitude: $0.coordinator.longitude) }
            .subscribe(onNext: { [weak self] location in
                self?.showUserLocation.accept((location, nil))
            })
            .disposed(by: disposeBag)
        
        annotationDidSelect
            .compactMap { [weak self] ubikeStation -> UibikeStationBottomSheetState? in
                self?.mapper.transform(ubikeStation: ubikeStation)
            }
            .debug()
            .bind(to: updateUibikeStationBottomSheet)
            .disposed(by: disposeBag)
        
        annotationDidDeselect
            .map { _ -> UibikeStationBottomSheetState in
                UibikeStationBottomSheetState.empty
            }
            .debug()
            .bind(to: updateUibikeStationBottomSheet)
            .disposed(by: disposeBag)
    }
    
    private func setupButtomSheet() {
        // TODO: implement favoriteStationButtonDidTap
        
        // TODO: implement navigationButtonDidTap
    }
}
