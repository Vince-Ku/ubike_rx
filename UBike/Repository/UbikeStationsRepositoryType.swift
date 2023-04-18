//
//  UbikeStationsRepositoryType.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

protocol UbikeStationsRepositoryType {
    func getUbikeStations(isLatest: Bool) -> Single<[UbikeStation]>
}
