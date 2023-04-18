//
//  UBikeModelMapper.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

class UbikeStationModelMapper {
    private let unknown = "unknown"
    
    func transform(apiModel: GetUBikesResp) -> [UbikeStation] {
        
        guard let apiModels = apiModel.retVal?.values else {
            return []
        }

        return apiModels.map {
            UbikeStation(id: $0.sno ?? unknown,
                         name: getName(apiModel: $0),
                         area: getArea(apiModel: $0),
                         coordinator: getCoordinate(apiModel: $0),
                         address: getAddress(apiModel: $0),
                         parkingSpace: getParkingSpace(apiModel: $0),
                         updatedDate: getUpdatedDate(apiModel: $0))
        }
    }
    
    private func getName(apiModel: UBike) -> UbikeStation.Name {
        UbikeStation.Name(english: apiModel.snaen ?? unknown,
                          chinese: apiModel.sna ?? unknown)
    }
    
    private func getArea(apiModel: UBike) -> UbikeStation.Area {
        UbikeStation.Area(english: apiModel.sareaen ?? unknown,
                          chinese: apiModel.sarea ?? unknown)
    }
    
    private func getAddress(apiModel: UBike) -> UbikeStation.Address {
        UbikeStation.Address(english: apiModel.aren ?? unknown,
                             chinese: apiModel.ar ?? unknown)
    }
    
    private func getCoordinate(apiModel: UBike) -> UbikeStation.Coordinate? {
        guard let lat = Double(apiModel.lat ?? ""),
              let long = Double(apiModel.lng ?? "") else {
            return nil
        }

        return UbikeStation.Coordinate(latitude: lat, longitude: long)
    }
    
    private func getParkingSpace(apiModel: UBike) -> UbikeStation.ParkingSpace {
        let total = Int(apiModel.tot ?? "0") ?? 0
        let bike = Int(apiModel.sbi ?? "0") ?? 0
        let empty = Int(apiModel.bemp ?? "0") ?? 0
        
        return UbikeStation.ParkingSpace(total: total, bike: bike, empty: empty)
    }
    
    private func getUpdatedDate(apiModel: UBike) -> Date? {
        guard let updatedDateString = apiModel.mday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        
        return formatter.date(from: updatedDateString)
    }
}
