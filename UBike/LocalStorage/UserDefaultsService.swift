//
//  UserDefaultsService.swift
//  UBike
//
//  Created by 辜敬閎 on 2023/4/18.
//

import RxSwift

class UserDefaultsService: LocalDataSourceType {
    static var shared: LocalDataSourceType = UserDefaultsService()
    
    func getUbikes() -> Single<[UbikeStation]> {
        // TODO: complete it
        .just([])
    }
}
