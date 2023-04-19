//
//  CoreDataService.swift
//  UBike
//
//  Created by Vince on 2023/4/19.
//

import RxSwift
import CoreData

class CoreDataService: LocalDataSourceType {
    static var shared: LocalDataSourceType = CoreDataService()
    
    private let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    private let mapper = UbikeStationCoreDataMapper()
    
    func getUbikeStations() -> Single<[UbikeStation]> {
        let fetchRequest = Ubike_Station.fetchRequest()

        do {
            let ubikeStationCoreDataModels = try container.viewContext.fetch(fetchRequest)
            let ubikeStations = mapper.transform(coreDataModels: ubikeStationCoreDataModels)

            return .just(ubikeStations)
        } catch (let error){
            print("❌❌❌ core data query error !")
            return .error(error)
        }
    }

    func saveUbikeStations(ubikeStations: [UbikeStation]) -> Completable {
        mapper.setupCoreDataModel(context: container.viewContext, models: ubikeStations)

        do {
            try container.viewContext.save()
            return .empty()

        } catch (let error){
            print("❌❌❌ core data saving error!!!")
            return .error(error)
        }
    }
}
