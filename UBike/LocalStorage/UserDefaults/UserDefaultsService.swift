//
//  UserDefaultsService.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

class UserDefaultsService: LocalDataSourceType {
    static var shared: LocalDataSourceType = UserDefaultsService()
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard
    
    func getUbikeStations() -> Single<[UbikeStation]> {
        guard let ubikeStationsData = userDefaults.value(forKey: LocalStorageConstants.ubikeStationsData) as? Data else {
            print("⚠️⚠️⚠️ ubikeStationsData is missing")
            return .error(NSError(domain: "UserDefaultsService", code: NSURLErrorDataNotAllowed))
        }
        
        do {
            let ubikeStations = try decode(ubikeStationsData: ubikeStationsData)
            return .just(ubikeStations)
            
        } catch (let error){
            return .error(error)
        }
    }
    
    func saveUbikeStations(ubikeStations: [UbikeStation]) -> Completable {
        do {
            let ubikeStationsData = try encode(ubikeStations: ubikeStations)
            userDefaults.set(ubikeStationsData, forKey: LocalStorageConstants.ubikeStationsData)
            
            return .empty()
            
        } catch (let error) {
            return .error(error)
        }
    }
    
    private func decode(ubikeStationsData: Data) throws -> [UbikeStation] {
        try jsonDecoder.decode([UbikeStation].self, from: ubikeStationsData)
    }
    
    private func encode(ubikeStations: [UbikeStation]) throws -> Data {
        try jsonEncoder.encode(ubikeStations)
    }
}
