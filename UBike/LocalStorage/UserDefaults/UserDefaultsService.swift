//
//  UserDefaultsService.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

final class UserDefaultsService: UserDefaultsServiceType {

    static var shared = UserDefaultsService()
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard
    
    func get<T: Decodable>(key: String) -> Single<[T]> {
        
        guard let data = userDefaults.value(forKey: key) as? Data else {
            print("⚠️⚠️⚠️ UserDefaults value not found, key: \(key)")
            return .error(NSError(domain: "UserDefaultsService.get", code: NSURLErrorDataNotAllowed))
        }
        
        do {
            let data: [T] = try decode(data: data)
            return .just(data)
            
        } catch (let error) {
            return .error(error)
        }
    }
    
    func save<T: Encodable>(encodables: [T], key: String) -> Completable {
        do {
            let data = try encode(encodableModels: encodables)
            userDefaults.set(data, forKey: key)
            
            return .empty()
            
        } catch (let error) {
            return .error(error)
        }
    }
    
    private func decode<T: Decodable>(data: Data) throws -> [T] {
        try jsonDecoder.decode([T].self, from: data)
    }
    
    private func encode<T: Encodable>(encodableModels: [T]) throws -> Data {
        try jsonEncoder.encode(encodableModels)
    }
}
