//
//  LocationManagerProxyType.swift
//  UBike
//
//  Created by Vince on 2023/4/27.
//

import RxSwift
import CoreLocation

protocol LocationManagerProxyType {
    var delegate: LocationManagerProxyDelegate? { get set }

    func getCurrentLocation() -> Maybe<CLLocation>
}
