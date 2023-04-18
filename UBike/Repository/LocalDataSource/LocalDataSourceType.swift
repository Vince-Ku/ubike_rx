//
//  LocalDataSourceType.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

protocol LocalDataSourceType {
    static var shared: LocalDataSourceType { get }
    
    // ❌❌❌ The Model `Ubike` couple to LocalDataSourceType protocol !!!
    // CRUD is the only knowledge could exist in this place !!
    //
    // TODO: use generic type instead
    //
    func getUbikeStations() -> Single<[UbikeStation]>
    func saveUbikeStations(ubikeStations: [UbikeStation]) -> Completable
}
