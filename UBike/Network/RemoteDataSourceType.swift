//
//  RemoteDataSourceType.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

protocol RemoteDataSourceType {
    static var shared: Self { get }
}
