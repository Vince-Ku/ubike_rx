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
    private let ubikeStationsRepository: UbikeStationsRepositoryType
    private let mapper: UibikeStationBottomSheetStateMapper
    
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    let viewDidLoad = PublishRelay<Void>()
    let showUserLocationButtonDidTap = PublishRelay<Void>()
    let refreshButtonDidTap = PublishRelay<Void>()
    let annotationDidSelect = PublishRelay<UbikeStation>()
    let annotationDidDeselect = PublishRelay<UbikeStation>()
    let favoriteStationButtonDidTap = PublishRelay<(String, Bool)>()
    let navigationButtonDidTap = PublishRelay<Void>()

    // MARK: Output
    let showLocation = PublishRelay<(CLLocation, CLLocationDistance?)>()
    let showUibikeStationsAnnotation = BehaviorRelay<[UBikeStationAnnotation]>(value: [])
    let updateUibikeStationBottomSheet = BehaviorRelay<UibikeStationBottomSheetState>(value: .empty)
    let updateUibikeSpaceText = BehaviorRelay<String?>(value: nil)
    let updateEmptySpaceText = BehaviorRelay<String?>(value: nil)
    let updateFavoriteButtonState = BehaviorRelay<Bool>(value: false)
    
    init(locationManager: LocationManagerProxy, ubikeStationsRepository: UbikeStationsRepositoryType, mapper: UibikeStationBottomSheetStateMapper) {
        self.locationManager = locationManager
        self.ubikeStationsRepository = ubikeStationsRepository
        self.mapper = mapper
        
        setupLocation()
        setupUbikeStations()
        setupAnnotation()
        setupButtomSheet()
    }
    
    private func setupLocation() {
        viewDidLoad.take(1).asSingle()
            .flatMap { [weak self] _ -> Single<Void> in
                self?.locationManager.requestAuthorizationIfNeeded() ?? .never()
            }
            .flatMap { [weak self] _ -> Single<CLLocation?> in
                self?.locationManager.activate() ?? .never()
            }
            .compactMap { $0 }
            .subscribe(onSuccess: { [weak self] location in
                self?.showLocation.accept((location, 5000))
            })
            .disposed(by: disposeBag)
        
        showUserLocationButtonDidTap
            .flatMap { [weak self] _ -> Single<Void> in
                self?.locationManager.requestAuthorizationIfNeeded() ?? .never()
            }
            .compactMap { [weak self] _ in self?.locationManager.getCurrentLocation() }
            .subscribe(onNext: { [weak self] location in
                self?.showLocation.accept((location, nil))
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
            .map { CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .subscribe(onNext: { [weak self] location in
                self?.showLocation.accept((location, nil))
            })
            .disposed(by: disposeBag)
        
        annotationDidSelect
            .compactMap { [weak self] ubikeStation -> UibikeStationBottomSheetState? in
                self?.mapper.transform(ubikeStation: ubikeStation)
            }
            .bind(to: updateUibikeStationBottomSheet)
            .disposed(by: disposeBag)
        
        annotationDidSelect
            .map(\.id)
            .withUnretained(self)
            .flatMap { owner, id -> Maybe<UbikeStation> in // get the latest data from the cache
                owner.ubikeStationsRepository.getUbikeStation(id: id)
                    .compactMap { $0 }
            }
            .subscribe(onNext: { [weak self] ubikeStation in
                self?.updateUibikeSpaceText.accept(String(ubikeStation.parkingSpace.bike))
                self?.updateEmptySpaceText.accept(String(ubikeStation.parkingSpace.empty))
                self?.updateFavoriteButtonState.accept(ubikeStation.isFavorite)
            })
            .disposed(by: disposeBag)
        
        annotationDidDeselect
            .subscribe(onNext: { [weak self] _ in
                self?.updateUibikeStationBottomSheet.accept(.empty)
                self?.updateUibikeSpaceText.accept(nil)
                self?.updateEmptySpaceText.accept(nil)
                self?.updateFavoriteButtonState.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupButtomSheet() {
        favoriteStationButtonDidTap
            .flatMapLatest { [weak self] id, isFavorite -> Single<Void> in
                self?.ubikeStationsRepository.updateUbikeStation(id: id, isFavorite: isFavorite) ?? .never()
            }
            .subscribe() // TODO: update annotation
            .disposed(by: disposeBag)
            
        
        // TODO: implement navigationButtonDidTap
    }
    
    
}
