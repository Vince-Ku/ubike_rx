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
    private let locationManager: LocationManagerProxy
    private let ubikeStationsRepository: UbikeStationsRepositoryType
    private let routeRepository: RouteRepositoryType
    private let mapper: UibikeStationBottomSheetStateMapper
    
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    let viewDidLoad = PublishRelay<Void>()
    let showUserLocationButtonDidTap = PublishRelay<Void>()
    let refreshButtonDidTap = PublishRelay<Void>()
    let annotationDidSelect = PublishRelay<UbikeStation>()
    let annotationDidDeselect = PublishRelay<UbikeStation>()
    let favoriteStationButtonDidTap = PublishRelay<(String, Bool)>()
    let navigationButtonDidTap = PublishRelay<String>()

    // MARK: Output
    let showLocation = PublishRelay<(CLLocation, CLLocationDistance?)>()
    let showUibikeStationsAnnotation = BehaviorRelay<[UBikeStationAnnotation]>(value: [])
    let updateUibikeStationBottomSheet = BehaviorRelay<UibikeStationBottomSheetState>(value: .empty)
    let updateUibikeStationNameText = BehaviorRelay<String>(value: "尚未選擇站點")
    let updateUibikeSpaceText = BehaviorRelay<String?>(value: nil)
    let updateEmptySpaceText = BehaviorRelay<String?>(value: nil)
    let updateFavoriteButtonState = BehaviorRelay<Bool>(value: false)
    let updateNavigationTitle = BehaviorRelay<String?>(value: nil)
    let updateRoute = BehaviorRelay<MKRoute?>(value: nil)
    
    init(locationManager: LocationManagerProxy, ubikeStationsRepository: UbikeStationsRepositoryType, routeRepository: RouteRepositoryType, mapper: UibikeStationBottomSheetStateMapper) {
        self.locationManager = locationManager
        self.ubikeStationsRepository = ubikeStationsRepository
        self.routeRepository = routeRepository
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
                self?.updateFavoriteButtonState.accept(ubikeStation.isFavorite)
            })
            .disposed(by: disposeBag)
        
        annotationDidSelect
            .map { CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .compactMap { [weak self] destination -> (CLLocation, CLLocation)? in
                guard let location = self?.locationManager.getCurrentLocation() else { return nil }
                return (location, destination)
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
                self?.updateFavoriteButtonState.accept(false)
                self?.updateNavigationTitle.accept(nil)
                self?.updateRoute.accept(nil)
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
            
        navigationButtonDidTap
            .withUnretained(self)
            .flatMapLatest { owner, id -> Maybe<CLLocation> in // get Source
                owner.ubikeStationsRepository.getUbikeStation(id: id)
                    .compactMap { $0?.coordinate }
                    .map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
            }
            .compactMap { [weak self] destination -> (CLLocation, CLLocation)? in // get Destination
                guard let location = self?.locationManager.getCurrentLocation() else { return nil }
                return (location, destination)
            }
            .flatMapLatest { [weak self] source, destination -> Single<MKRoute> in // get Route
                self?.routeRepository.getWalkingRoute(source: source, destination: destination) ?? .never()
            }
            .subscribe(onNext: { [weak self] route in
                let centerLocation = CLLocation(latitude: route.polyline.coordinate.latitude,
                                                longitude: route.polyline.coordinate.longitude)
                
                self?.updateRoute.accept(route)
                self?.showLocation.accept((centerLocation, route.distance))
            })
            .disposed(by: disposeBag)
    }
}
