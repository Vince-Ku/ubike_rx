//
//  UBikeStationCoreDataServiceType.swift
//  UBike
//
//  Created by Vince on 2023/4/20.
//

import RxSwift

protocol UBikeStationCoreDataServiceType: CoreDataServiceType {
    func get() -> Single<[UbikeStation]>
    func save(ubikeStations: [UbikeStation]) -> Completable
}
