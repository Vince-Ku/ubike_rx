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
    func openLocationSettingAlert() -> Completable
}

class LocationManagerProxy: NSObject {
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private let didChangeAuthorization = PublishRelay<CLAuthorizationStatus>()
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

    public func requestAuthorizationIfNeeded() -> Completable {
        guard !authorizationIsValid else {
            return .empty()
        }
        
        guard locationManager.authorizationStatus != .notDetermined else {
            return requestAuthorization()
        }
        
        guard let delegate = delegate else {
            return .never()
        }
        
        return delegate.openLocationSettingAlert()
            .andThen(didChangeAuthorizationCompletable)
    }
    
    public func activate() -> Completable {
        didUpdateLocationCompletable
            .do(onSubscribe: { [weak self] in
                self?.locationManager.startUpdatingLocation()
            })
    }
    
    public func getCurrentLocation() -> CLLocation? {
        currentLocation.value
    }
    
    private func requestAuthorization() -> Completable {
        didChangeAuthorizationCompletable
            .do(onSubscribe: { [weak self] in
                self?.locationManager.requestAlwaysAuthorization()
            })
    }
}

extension LocationManagerProxy: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        didChangeAuthorization.accept(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocation.accept(locations.last)
    }
}

extension LocationManagerProxy {
    private var didChangeAuthorizationCompletable: Completable {
        didChangeAuthorization.take(1).ignoreElements().asCompletable()
    }
    
    private var didUpdateLocationCompletable: Completable {
        didUpdateLocation.take(1).ignoreElements().asCompletable()
    }
}
