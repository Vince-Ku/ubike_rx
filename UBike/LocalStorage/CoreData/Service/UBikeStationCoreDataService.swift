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
    
    func get(id: String) -> Single<UbikeStation?> {
        let context = container.newBackgroundContext()
        
        let fetchRequest = Ubike_Station.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = [LocalStorageConstants.CoreData.RelationShip.favorite]
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            
        do {
            let ubikeStationCoreDataModel = try context.fetch(fetchRequest)
            let ubikeStation = mapper.transform(coreDataModels: ubikeStationCoreDataModel).first

            return .just(ubikeStation)
        } catch (let error) {
            print("❌❌❌ UBikeStationCoreDataService query by id fail !")
            return .error(error)
        }
    }
    
    func get() -> Single<[UbikeStation]> {
        let context = container.newBackgroundContext()
        
        let fetchRequest = Ubike_Station.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = [LocalStorageConstants.CoreData.RelationShip.favorite]
            
        do {
            let ubikeStationCoreDataModels = try context.fetch(fetchRequest)
            let ubikeStations = mapper.transform(coreDataModels: ubikeStationCoreDataModels)

            return .just(ubikeStations)
        } catch (let error) {
            print("❌❌❌ UBikeStationCoreDataService query fail !")
            return .error(error)
        }
    }

    func save(ubikeStations: [UbikeStation]) -> Single<Void> {
        let context = container.newBackgroundContext()
        
        // truncate table
        truncate(context: context)
        
        do {
            // fetch favorite
            let favorites = try context.fetch(Favorite_Ubike_Station.fetchRequest())
            
            // setup inserted core data Model
            mapper.setupCoreDataModel(context: context, models: ubikeStations, favorites: favorites)
            
            try context.save()
            
            return .just(())

        } catch (let error) {
            print("❌❌❌ UBikeStationCoreDataService save fail !")
            return .error(error)
        }
    }
    
    func update(id: String, isFavorite: Bool) -> Single<Void> {
        let context = container.newBackgroundContext()
        
        do {
            let favorite = try getFavorite(id: id, context: context)
            let ubikeStation = try getUbikeStation(id: id, context: context)
            
            if let favorite = favorite {
                // favorite exist, then update both favorite and ubikeStation
                favorite.isFavorite = isFavorite
                ubikeStation?.favorite = favorite

            } else {
                // favorite doesn't exist, then insert favorite and update ubikeStation
                let favorite = Favorite_Ubike_Station(context: context)
                favorite.id = id
                favorite.isFavorite = isFavorite
                ubikeStation?.favorite = favorite
            }

            try context.save()
            
            return .just(())
            
        } catch let error {
            print("❌❌❌ UBikeStationCoreDataService update fail !")
            return .error(error)
        }
    }
    
    private func truncate(context: NSManagedObjectContext) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Ubike_Station.fetchRequest())
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("❌❌❌ UBikeStationCoreDataService truncate fail !")
        }
    }
    
    private func getFavorite(id: String, context: NSManagedObjectContext) throws -> Favorite_Ubike_Station? {
        let fetchRequest = Favorite_Ubike_Station.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
            
        } catch let error {
            print("❌❌❌ UBikeStationCoreDataService getFavorite fail !")
            throw error
        }
    }
    
    private func getUbikeStation(id: String, context: NSManagedObjectContext) throws -> Ubike_Station? {
        // fetch Ubike_Station
        let fetchRequest = Ubike_Station.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.relationshipKeyPathsForPrefetching = [LocalStorageConstants.CoreData.RelationShip.favorite]

        do {
            return try context.fetch(fetchRequest).first
            
        } catch let error {
            print("❌❌❌ UBikeStationCoreDataService getUbikeStation fail !")
            throw error
        }
    }
    
}
