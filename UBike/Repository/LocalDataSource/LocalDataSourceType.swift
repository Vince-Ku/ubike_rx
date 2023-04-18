//
//  LocalDataSourceType.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

protocol LocalDataSourceType {
    static var shared: LocalDataSourceType { get }
    func getUbikes() -> Single<[UbikeStation]>
}
