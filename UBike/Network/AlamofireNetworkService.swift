
//
//  AlamofireAdapter.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

class AlamofireNetworkService: RemoteDataSourceType {

    static var shared: RemoteDataSourceType = AlamofireNetworkService()
    
    func fetch<T: APIInterfaceType>(apiInterface target: T) -> Single<T.OutputModel> {
        request(HTTPMethod(rawValue: target.method), target.url, parameters: target.parameters) // use background quene by default
            .responseJSON() // use main quene by default
            .asSingle()
            .flatMap { response -> Single<T.OutputModel> in
                
                //
                // outer response
                //
                switch response.result {
                case .success:
                    return .just(try self.decode(target: target, data: response.data))

                case .failure(let error):

                    print("❌❌❌ -> \(error.localizedDescription)")
                    return .error(error)
                }
            }
    }
    
    private func decode<T: APIInterfaceType>(target: T, data: Data?) throws -> T.OutputModel {
        
        guard let data = data else {
            throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
        }

        return try target.decoder.decode(T.OutputModel.self, from: data)
    }
}
