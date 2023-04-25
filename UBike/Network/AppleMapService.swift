//
//  AppleMapService.swift
//  UBike
//
//  Created by Vince on 2023/4/25.
//

import MapKit

class AppleMapService {
    static let shared = AppleMapService()
    
    func fetch(source: CLLocation, destination: CLLocation, completion: @escaping (Result<MKRoute, Error>) -> Void) {
        
        let directions = getDirections(source: source, destination: destination, transportType: .walking)
        
        directions.calculate { reponse, error in
            if let error = error {
                completion(.failure(error))
                print("❌❌❌ AppleMapService fetch fail !")
                return
            }
            
            guard let route = reponse?.routes.first else {
                completion(.failure(NSError(domain: "AppleMapService.fetch", code: NSURLErrorDataNotAllowed)))
                print("❌❌❌ AppleMapService fetch route not found !")
                return
            }
            
            completion(.success(route))
        }
    }
    
    private func getDirections(source: CLLocation, destination: CLLocation, transportType: MKDirectionsTransportType) -> MKDirections {
        // source
        //
        let sourcePlacemark = MKPlacemark(coordinate: source.coordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // destination
        //
        let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let request = MKDirections.Request()
        request.transportType = transportType
        request.source = sourceMapItem
        request.destination = destinationMapItem
        
        return MKDirections(request: request)
    }
}
