//
//  RouteRepository.swift
//  UBike
//
//  Created by Vince on 2023/4/25.
//

import MapKit
import RxSwift

protocol RouteRepositoryType {
    func getWalkingRoute(source: CLLocation, destination: CLLocation) -> Single<MKRoute>
}

class RouteRepository: RouteRepositoryType {
    
    private let appleMapService: AppleMapService
    
    init(appleMapService: AppleMapService) {
        self.appleMapService = appleMapService
    }
    
    func getWalkingRoute(source: CLLocation, destination: CLLocation) -> Single<MKRoute> {
        Single.create { [weak self] observe in
            guard let self = self else { return Disposables.create() }
            
            self.appleMapService.fetch(source: source, destination: destination, completion: observe)
            
            return Disposables.create()
        }
    }
}
