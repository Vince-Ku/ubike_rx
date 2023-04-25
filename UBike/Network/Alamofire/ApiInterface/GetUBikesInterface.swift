//
//  GetUBikesInterface.swift
//  UBike
//
//  Created by Vince on 2023/4/17.
//

import Foundation

struct GetUBikesInterface: APIInterfaceType {
    
    typealias OutputModel = GetUBikesResp

    var decoder: JSONDecoder = JSONDecoder() // default key strategy
    var url: String = "\(NetworkConstants.httpsUrlScheme)\(NetworkConstants.taipeiGovernmentDomainHost)/blobyoubike/YouBikeTP.json"
    var method: String = "GET"
    var parameters: [String : Any] = [:]
}
