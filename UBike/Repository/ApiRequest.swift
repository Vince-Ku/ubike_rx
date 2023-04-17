
//
//  ApiRequest.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

class ApiRequest {
    
    static func fetchApi<T:Codable>(requestDic:[String:Any]? ,urlPath:String) -> Observable<T?> {
        print("fetchApi")
        guard let url = URL(string: urlPath ) else {
            print("Api URL doesn't exist!!")
            return Observable.just(nil)
        }

        return request(.get, url,parameters: requestDic) // use background quene by default
            .responseJSON() // use main quene by default
            .flatMapLatest{ response -> Observable<T?> in
                
                //print("Api 回傳結果 -> \(response.result)")
                print("Api Code -> \(String(describing: response.response?.statusCode))")
                //
                // outer response
                //
                switch response.result {
                case .success:
                    do{
                        let decoder = JSONDecoder()
                        let data = response.data
                        
                        return Observable<T?>.just(try decoder.decode(T.self, from: data!))
                    }
                    catch (let error){
                        print(error.localizedDescription)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                return Observable<T?>.just(nil)
            }
    }
}

