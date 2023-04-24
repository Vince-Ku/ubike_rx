//
//  LocationManagerProxy.swift
//  UBike
//
//  Created by Vince on 2023/4/20.
//

import CoreLocation
import RxSwift
import RxRelay

protocol LocationManagerProxyDelegate: AnyObject {
    func openLocationSettingAlert(completion: @escaping (() -> Void))
}

class LocationManagerProxy: NSObject {
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private let didChangeAuthorization = PublishRelay<Void>()
    private let didUpdateLocation = PublishRelay<CLLocation?>()
    private let currentLocation = BehaviorRelay<CLLocation?>(value: nil)

    private var authorizationIsValid: Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    weak var delegate: LocationManagerProxyDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        didUpdateLocation
            .bind(to: currentLocation)
            .disposed(by: disposeBag)
    }
    
    func requestAuthorizationIfNeeded() -> Single<Void> {
        requestAuthorizationIfNeeded().ifEmpty(default: ())
    }
    
    func activate() -> Single<CLLocation?> {
        didUpdateLocation.take(1).asSingle()
            .do(onSubscribed: { [weak self] in
                self?.locationManager.startUpdatingLocation()
            })
    }
    
    func getCurrentLocation() -> CLLocation? {
        currentLocation.value
    }
    
    private func requestAuthorizationIfNeeded() -> Maybe<Void> {
        presentAuthorizationAlert()
            .flatMap { [weak self] _ -> Maybe<Void> in
                self?.didChangeAuthorization.take(1).asMaybe() ?? .never()
            }
    }
    
    private func presentAuthorizationAlert() -> Maybe<Void> {
        Maybe<Void>.create { [weak self] observe -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            guard !self.authorizationIsValid else {
                observe(.completed)
                return Disposables.create()
            }
            
            guard self.locationManager.authorizationStatus != .notDetermined else {
                self.locationManager.requestAlwaysAuthorization()
                observe(.success(()))
                return Disposables.create()
            }
            
            self.delegate?.openLocationSettingAlert(completion: {
                observe(.success(()))
            })
            
            return Disposables.create()
        }
    }
}

extension LocationManagerProxy: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        didChangeAuthorization.accept(())
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocation.accept(locations.last)
    }
}
