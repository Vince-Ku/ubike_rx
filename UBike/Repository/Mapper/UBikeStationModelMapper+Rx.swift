//
//  UbikeStationModelMapper+Rx.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

extension UbikeStationModelMapper: ReactiveCompatible {}

extension Reactive where Base: UbikeStationModelMapper {
    func transform(apiModel: GetUBikesResp) -> Single<[UbikeStation]> {
        Single.create { [weak base] observer in
            guard let appModel = base?.transform(apiModel: apiModel) else {
                return Disposables.create()
            }
            
            observer(.success(appModel))
            
            return Disposables.create()
        }
    }
}
