//
//  AlamofireNetworkServiceType.swift
//  UBike
//
//  Created by Vince on 2023/4/26.
//

import Foundation
import RxSwift

protocol AlamofireNetworkServiceType: RemoteDataSourceType {
    func fetch<T: APIInterfaceType>(apiInterface target: T) -> Single<T.OutputModel>
}
