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
    
    private func fetchUbikeStations() -> Single<[UbikeStation]> {
        remoteDataSource.fetch(apiInterface: ubikesApiInterface)
            .flatMap { [weak self] apiModel -> Single<[UbikeStation]> in
                self?.ubikeStationModelMapper.rx.transform(apiModel: apiModel) ?? .never()
            }
            .flatMapCompletable { [weak self] appModel -> Completable in
                self?.saveUbikeStations(ubikeStations: appModel) ?? .never()
            }
            .andThen(ubikeStationCoreDataService.get())
    }
    
    private func saveUbikeStations(ubikeStations: [UbikeStation]) -> Completable {
        ubikeStationCoreDataService.save(ubikeStations: ubikeStations)
    }
}
