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
    }
    
    func getCurrentLocation() -> Maybe<CLLocation> {
        requestAuthorization()
            .flatMap { [weak self] _ -> Single<CLLocation?> in
                guard let self = self else { return .never() }
                
                return self.getLatestLocation()
            }
            .compactMap { $0 }
    }
    
    private func getLatestLocation() -> Single<CLLocation?> {
        didUpdateLocation.take(1).asSingle()
            .do(onSubscribed: { [weak self] in
                self?.locationManager.stopUpdatingLocation()
                self?.locationManager.startUpdatingLocation()
            })
    }
    
    private func requestAuthorization() -> Single<Void> {
        requestAuthorizationIfNeeded()
            .flatMap { [weak self] isPresented -> Single<Void> in
                guard let self = self else { return .never() }
                
                guard isPresented else { return .just(()) }
                
                return self.didChangeAuthorization.take(1).asSingle()
            }
    }
    
    private func requestAuthorizationIfNeeded() -> Single<Bool> {
        Single<Bool>.create { [weak self] observe -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            guard !self.authorizationIsValid else {
                observe(.success(false))
                return Disposables.create()
            }
            
            guard self.locationManager.authorizationStatus != .notDetermined else {
                self.locationManager.requestAlwaysAuthorization()
                observe(.success(true))
                return Disposables.create()
            }
            
            self.delegate?.openLocationSettingAlert(completion: {
                observe(.success(true))
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
