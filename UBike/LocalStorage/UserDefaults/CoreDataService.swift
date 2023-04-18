//
//  CoreDataService.swift
//  UBike
//
//  Created by Vince on 2023/4/19.
//

import RxSwift

class CoreDataService: LocalDataSourceType {
    static var shared: LocalDataSourceType = CoreDataService()
    
    func getUbikeStations() -> Single<[UbikeStation]> {
        // TODO: implement it
        return .never()
    }

    func saveUbikeStations(ubikeStations: [UbikeStation]) -> Completable {
        // TODO: implement it
        return .never()
    }
}
