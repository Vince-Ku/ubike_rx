//
//  UserDefaultsUtil.swift
//  UBike
//
//  Created by Vince on 2021/5/16.
//

import Foundation

let ubilkesFavoriteKey = "ubikes.favorite.station"

class UserDefaultsUtil {
    
    static func saveDataToUserDefaults(data: Any?, key: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: key)
    }
    
    static func getDataFromUserDefaults(keys:String) -> Any?{
        let userDefault = UserDefaults.standard
        let data = userDefault.value(forKey: keys)
        return data
    }

    static func removeDataFromUserDefaults(key:String){
        UserDefaults.standard.removeObject(forKey: key)
    }
}
