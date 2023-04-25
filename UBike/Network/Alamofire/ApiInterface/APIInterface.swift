//
//  APIInterface.swift
//  UBike
//
//  Created by Vince on 2023/4/17.
//

import Foundation

protocol APIInterfaceType {
    associatedtype OutputModel: Decodable
    
    var parameters: [String: Any] { get set }
    var decoder: JSONDecoder { get set }
    var url: String { get set }
    var method: String { get set }
}
