//
//  UbikeStationCoreDataMapper.swift
//  UBike
//
//  Created by Vince on 2023/4/19.
//

import CoreData

class UbikeStationCoreDataMapper {
    private let unknown = "unknown"
    
    func setupCoreDataModel(context: NSManagedObjectContext, models: [UbikeStation]) {
        models.forEach { model in
            let coreDataModel = Ubike_Station(context: context)
            coreDataModel.id = model.id
            coreDataModel.name_en = model.name.english
            coreDataModel.name_ch = model.name.chinese
            coreDataModel.area_en = model.area.english
            coreDataModel.area_ch = model.area.chinese
            coreDataModel.latitude = model.coordinator?.latitude ?? 0
            coreDataModel.longitude = model.coordinator?.longitude ?? 0
            coreDataModel.address_en = model.address.english
            coreDataModel.address_ch = model.address.chinese
            coreDataModel.total_parking_number = Int16(model.parkingSpace.total)
            coreDataModel.bike_number = Int16(model.parkingSpace.bike)
            coreDataModel.empty_parking_number = Int16(model.parkingSpace.empty)
            coreDataModel.updated_date = model.updatedDate
        }
    }
    
    func transform(coreDataModels: [Ubike_Station]) -> [UbikeStation] {
        
        coreDataModels.compactMap { [weak self] coreDataModel -> UbikeStation? in
            guard let self = self else { return nil }

            return UbikeStation(id: coreDataModel.id ?? unknown,
                                name: self.getName(coreDataModel: coreDataModel),
                                area: self.getArea(coreDataModel: coreDataModel),
                                coordinator: self.getCoordinate(coreDataModel: coreDataModel),
                                address: self.getAddress(coreDataModel: coreDataModel),
                                parkingSpace: self.getParkingSpace(coreDataModel: coreDataModel),
                                updatedDate: coreDataModel.updated_date)
        }
    }

    private func getName(coreDataModel: Ubike_Station) -> UbikeStation.Name {
        UbikeStation.Name(english: coreDataModel.name_en ?? unknown,
                          chinese: coreDataModel.name_ch ?? unknown)
    }

    private func getArea(coreDataModel: Ubike_Station) -> UbikeStation.Area {
        UbikeStation.Area(english: coreDataModel.area_en ?? unknown,
                          chinese: coreDataModel.area_ch ?? unknown)
    }

    private func getCoordinate(coreDataModel: Ubike_Station) -> UbikeStation.Coordinate {
        UbikeStation.Coordinate(latitude: coreDataModel.latitude,
                                longitude: coreDataModel.longitude)
    }

    private func getAddress(coreDataModel: Ubike_Station) -> UbikeStation.Address {
        UbikeStation.Address(english: coreDataModel.address_en ?? unknown,
                             chinese: coreDataModel.address_ch ?? unknown)
    }

    private func getParkingSpace(coreDataModel: Ubike_Station) -> UbikeStation.ParkingSpace {
        UbikeStation.ParkingSpace(total: Int(coreDataModel.total_parking_number),
                                  bike: Int(coreDataModel.bike_number),
                                  empty: Int(coreDataModel.empty_parking_number))
    }
}
