//
//  UBikeStationCoreDataService.swift
//  UBike
//
//  Created by Vince on 2023/4/20.
//

import CoreData
import RxSwift

final class UBikeStationCoreDataService: UBikeStationCoreDataServiceType {
    
    static var shared = UBikeStationCoreDataService()
    
    private let mapper = UbikeStationCoreDataMapper()
    
    func get() -> Single<[UbikeStation]> {
        let fetchRequest = Ubike_Station.fetchRequest()

        do {
            let ubikeStationCoreDataModels = try container.newBackgroundContext().fetch(fetchRequest)
            let ubikeStations = mapper.transform(coreDataModels: ubikeStationCoreDataModels)

            return .just(ubikeStations)
        } catch (let error) {
            print("❌❌❌ UBikeStationCoreDataService query fail !")
            return .error(error)
        }
    }

    func save(ubikeStations: [UbikeStation]) -> Completable {
        let context = container.newBackgroundContext()
        mapper.setupCoreDataModel(context: context, models: ubikeStations)

        do {
            try context.save()
            return .empty()

        } catch (let error) {
            print("❌❌❌ UBikeStationCoreDataService save fail !")
            return .error(error)
        }
    }
}