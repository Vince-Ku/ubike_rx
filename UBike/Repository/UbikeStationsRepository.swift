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

    private let alamofireNetworkService: AlamofireNetworkServiceType
    private let ubikeStationCoreDataService: UBikeStationCoreDataServiceType
    
    init(alamofireNetworkService: AlamofireNetworkServiceType, ubikeStationCoreDataService: UBikeStationCoreDataServiceType) {
        self.alamofireNetworkService = alamofireNetworkService
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
    
    func updateUbikeStation(id: String, isFavorite: Bool) -> Single<UbikeStation> {
        ubikeStationCoreDataService.update(id: id, isFavorite: isFavorite)
            .flatMap { [weak self] _ -> Single<UbikeStation?> in
                guard let self = self else { return .never() }
                
                return self.getUbikeStation(id: id)
            }
            .map { ubikeStation -> UbikeStation in
                guard let ubikeStation = ubikeStation else {
                    throw NSError(domain: "UbikeStationsRepository func updateUbikeStation", code: NSURLErrorDataNotAllowed)
                }
                return ubikeStation
            }
    }
    
    private func fetchUbikeStations() -> Single<[UbikeStation]> {
        alamofireNetworkService.fetch(apiInterface: ubikesApiInterface)
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
