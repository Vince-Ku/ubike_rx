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
import MapKit

class HomeViewModel {

    // MARK: DI
    private let locationManager: LocationManagerProxyType
    private let ubikeStationsRepository: UbikeStationsRepositoryType
    private let routeRepository: RouteRepositoryType
    private let mapper: UibikeStationBottomSheetStateMapperType
    private let coordinator: HomeCoordinatorType
    
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    let viewDidLoad = PublishRelay<Void>()
    let positioningButtonDidTap = PublishRelay<Void>()
    let refreshAnnotationButtonDidTap = PublishRelay<Void>()
    let annotationDidSelect = PublishRelay<UbikeStation>()
    let annotationDidDeselect = PublishRelay<UbikeStation>()
    let collectionButtonDidTap = PublishRelay<(String, Bool)>()
    let navigationButtonDidTap = PublishRelay<String>()
    let showListButtonDidTap = PublishRelay<Void>()

    // MARK: Output
    let updateMapRegion = PublishRelay<(CLLocation, CLLocationDistance?)>()
    let updateUibikeStationsAnnotation = BehaviorRelay<[UBikeStationAnnotation]>(value: [])
    let updateUibikeStationBottomSheet = BehaviorRelay<UibikeStationBottomSheetState>(value: .empty)
    let updateUibikeStationNameText = BehaviorRelay<String>(value: "尚未選擇站點")
    let updateUibikeSpaceText = BehaviorRelay<String?>(value: nil)
    let updateEmptySpaceText = BehaviorRelay<String?>(value: nil)
    let updateCollectionButtonState = BehaviorRelay<Bool>(value: false)
    let updateNavigationTitle = BehaviorRelay<String?>(value: nil)
    let updateRoute = BehaviorRelay<MKRoute?>(value: nil)
    
    init(locationManager: LocationManagerProxyType, ubikeStationsRepository: UbikeStationsRepositoryType, routeRepository: RouteRepositoryType, mapper: UibikeStationBottomSheetStateMapperType, coordinator: HomeCoordinatorType) {
        self.locationManager = locationManager
        self.ubikeStationsRepository = ubikeStationsRepository
        self.routeRepository = routeRepository
        self.mapper = mapper
        self.coordinator = coordinator
        
        setupLocation()
        setupAnnotations()
        setupButtomSheet()
        setupUbikeList()
    }
    
    private func setupLocation() {
        viewDidLoad.take(1).asMaybe()
            .flatMap { [weak self] _ -> Maybe<CLLocation> in
                self?.locationManager.getCurrentLocation() ?? .never()
            }
            .subscribe(onSuccess: { [weak self] location in
                self?.updateMapRegion.accept((location, 5000))
            })
            .disposed(by: disposeBag)
        
        positioningButtonDidTap
            .flatMap { [weak self] _ -> Maybe<CLLocation> in
                self?.locationManager.getCurrentLocation() ?? .never()
            }
            .subscribe(onNext: { [weak self] location in
                self?.updateMapRegion.accept((location, nil))
            })
            .disposed(by: disposeBag)
        
        annotationDidSelect
            .map { CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .subscribe(onNext: { [weak self] location in
                self?.updateMapRegion.accept((location, nil))
            })
            .disposed(by: disposeBag)
    }
    
    private func setupAnnotations() {
        Observable.merge(viewDidLoad.asObservable().take(1), refreshAnnotationButtonDidTap.asObservable())
            .flatMapLatest { [weak self] _ -> Single<[UbikeStation]> in
                self?.ubikeStationsRepository.getUbikeStations(isLatest: true) ?? .never()
            }
            .map {
                $0.map { UBikeStationAnnotation(ubikeStation: $0) }
            }
            .bind(to: updateUibikeStationsAnnotation)
            .disposed(by: disposeBag)
    }
    
    private func setupButtomSheet() {
        annotationDidSelect
            .subscribe(onNext: { [weak self] ubikeStation in
                self?.updateUibikeStationNameText.accept(ubikeStation.name.chinese)
                self?.updateUibikeStationBottomSheet.accept(.regular(id: ubikeStation.id))
            })
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
                self?.updateCollectionButtonState.accept(ubikeStation.isFavorite)
            })
            .disposed(by: disposeBag)
        
        annotationDidSelect
            .map { CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .flatMapLatest { [weak self] destination -> Maybe<(CLLocation, CLLocation)> in
                guard let self = self else { return .never() }
                
                return self.locationManager.getCurrentLocation()
                    .map { location in (location, destination)}
            }
            .flatMapLatest { [weak self] source, destination -> Single<MKRoute> in
                self?.routeRepository.getWalkingRoute(source: source, destination: destination) ?? .never()
            }
            .map { [weak self] route in
                self?.mapper.getNavigationText(route: route)
            }
            .subscribe(onNext: { [weak self] title in
                self?.updateNavigationTitle.accept(title)
            })
            .disposed(by: disposeBag)
        
        annotationDidDeselect
            .subscribe(onNext: { [weak self] _ in
                self?.updateUibikeStationBottomSheet.accept(.empty)
                self?.updateUibikeStationNameText.accept("尚未選擇站點")
                self?.updateUibikeSpaceText.accept(nil)
                self?.updateEmptySpaceText.accept(nil)
                self?.updateCollectionButtonState.accept(false)
                self?.updateNavigationTitle.accept(nil)
                self?.updateRoute.accept(nil)
            })
            .disposed(by: disposeBag)
        
        collectionButtonDidTap
            .flatMapLatest { [weak self] id, isFavorite -> Single<Bool> in
                guard let self = self else { return .never() }
                return self.ubikeStationsRepository.updateUbikeStation(id: id, isFavorite: isFavorite)
                    .map(\.isFavorite)
                    .catchAndReturn(!isFavorite) // recover collection button state
            }
            .subscribe(onNext: { [weak self] isFavorite in
                self?.updateCollectionButtonState.accept(isFavorite)
            })
            .disposed(by: disposeBag)
            
        navigationButtonDidTap
            .withUnretained(self)
            .flatMapLatest { owner, id -> Maybe<CLLocation> in // get Source
                owner.ubikeStationsRepository.getUbikeStation(id: id)
                    .compactMap { $0?.coordinate }
                    .map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
            }
            .flatMapLatest { [weak self] destination -> Maybe<(CLLocation, CLLocation)> in // get Destination
                guard let self = self else { return .never() }
                
                return self.locationManager.getCurrentLocation()
                    .map { location in (location, destination)}
            }
            .flatMapLatest { [weak self] source, destination -> Single<MKRoute> in // get Route
                self?.routeRepository.getWalkingRoute(source: source, destination: destination) ?? .never()
            }
            .subscribe(onNext: { [weak self] route in
                let centerLocation = CLLocation(latitude: route.polyline.coordinate.latitude,
                                                longitude: route.polyline.coordinate.longitude)

                self?.updateRoute.accept(route)
                self?.updateMapRegion.accept((centerLocation, route.distance))
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUbikeList() {
        showListButtonDidTap
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator.openUbikeListModule()
            })
            .disposed(by: disposeBag)
    }
}
