//
//  UserDefaultsServiceType.swift
//  UBike
//
//  Created by Vince on 2023/4/20.
//

import RxSwift

protocol UserDefaultsServiceType: LocalDataSourceType {
    func get<T: Decodable>(key: String) -> Single<[T]>
    func save<T: Encodable>(encodables: [T], key: String) -> Completable
}
