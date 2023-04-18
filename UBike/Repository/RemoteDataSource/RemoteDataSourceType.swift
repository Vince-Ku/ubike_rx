//
//  RemoteDataSourceType.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

protocol RemoteDataSourceType {
    static var shared: RemoteDataSourceType { get }
    func fetch<T: APIInterfaceType>(apiInterface target: T) -> Single<T.OutputModel>
}
