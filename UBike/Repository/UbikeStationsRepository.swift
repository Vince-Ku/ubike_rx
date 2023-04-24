//
//  UbikeStationsRepository.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

import RxSwift

class UbikeStationsRepository: UbikeStationsRepositoryType {
    private let ubikesApiInterface = GetUBikesInterface()
    private let ubikeStationModelMapper = UbikeStationModelMapper()

    private let remoteDataSource: RemoteDataSourceType
    private let ubikeStationCoreDataService: UBikeStationCoreDataServiceType
    
    init(remoteDataSource: RemoteDataSourceType, ubikeStationCoreDataService: UBikeStationCoreDataServiceType) {
        self.remoteDataSource = remoteDataSource
        self.ubikeStationCoreDataService = ubikeStationCoreDataService
    }
    
    func getUbikeStations(isLatest: Bool) -> Single<[UbikeStation]> {
        guard isLatest else {
            return ubikeStationCoreDataService.get()
        }
        
        return fetchUbikeStations()
    }
    
    func getUbikeStation(id: String) -> Single<UbikeStation?> {
        ubikeStationCoreDataService.get(id: id)
    }
    
    func updateUbikeStation(id: String, isFavorite: Bool) -> Single<Void> {
        ubikeStationCoreDataService.update(id: id, isFavorite: isFavorite)
    }
    
    private func fetchUbikeStations() -> Single<[UbikeStation]> {
        remoteDataSource.fetch(apiInterface: ubikesApiInterface)
            .flatMap { [weak self] apiModel -> Single<[UbikeStation]> in
                self?.ubikeStationModelMapper.rx.transform(apiModel: apiModel) ?? .never()
            }
            .flatMap { [weak self] appModel -> Single<Void> in
                self?.ubikeStationCoreDataService.save(ubikeStations: appModel) ?? .never()
            }
            .flatMap { [weak self] _ -> Single<[UbikeStation]> in
                self?.ubikeStationCoreDataService.get() ?? .never()
            }
    }
}
