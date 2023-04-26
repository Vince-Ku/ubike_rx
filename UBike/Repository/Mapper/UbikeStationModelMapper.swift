//
//  UBikeModelMapper.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

class UbikeStationModelMapper {
    private let unknown = "unknown"
    
    func transform(apiModel: GetUBikesResponse) -> [UbikeStation] {
        
        guard let apiModels = apiModel.retVal?.values else {
            return []
        }

        return apiModels.compactMap { apiModel -> UbikeStation? in
            // filter unknown coordinate station
            guard let coordinate = getCoordinate(apiModel: apiModel) else {
                return nil
            }
            
            return UbikeStation(id: apiModel.sno ?? unknown,
                                name: getName(apiModel: apiModel),
                                area: getArea(apiModel: apiModel),
                                coordinate: coordinate,
                                address: getAddress(apiModel: apiModel),
                                parkingSpace: getParkingSpace(apiModel: apiModel),
                                isFavorite: false, // default value
                                updatedDate: getUpdatedDate(apiModel: apiModel))
        }
    }
    
    private func getName(apiModel: GetUBikesResponse.Station) -> UbikeStation.Name {
        UbikeStation.Name(english: apiModel.snaen ?? unknown,
                          chinese: apiModel.sna ?? unknown)
    }
    
    private func getArea(apiModel: GetUBikesResponse.Station) -> UbikeStation.Area {
        UbikeStation.Area(english: apiModel.sareaen ?? unknown,
                          chinese: apiModel.sarea ?? unknown)
    }
    
    private func getAddress(apiModel: GetUBikesResponse.Station) -> UbikeStation.Address {
        UbikeStation.Address(english: apiModel.aren ?? unknown,
                             chinese: apiModel.ar ?? unknown)
    }
    
    private func getCoordinate(apiModel: GetUBikesResponse.Station) -> UbikeStation.Coordinate? {
        guard let lat = Double(apiModel.lat ?? ""),
              let long = Double(apiModel.lng ?? "") else {
            return nil
        }

        return UbikeStation.Coordinate(latitude: lat, longitude: long)
    }
    
    private func getParkingSpace(apiModel: GetUBikesResponse.Station) -> UbikeStation.ParkingSpace {
        let total = Int(apiModel.tot ?? "0") ?? 0
        let bike = Int(apiModel.sbi ?? "0") ?? 0
        let empty = Int(apiModel.bemp ?? "0") ?? 0
        
        return UbikeStation.ParkingSpace(total: total, bike: bike, empty: empty)
    }
    
    private func getUpdatedDate(apiModel: GetUBikesResponse.Station) -> Date? {
        guard let updatedDateString = apiModel.mday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        
        return formatter.date(from: updatedDateString)
    }
}
