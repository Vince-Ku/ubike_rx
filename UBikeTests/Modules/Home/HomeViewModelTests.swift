//
//  HomeViewModelTests.swift
//  UBikeTests
//
//  Created by Vince on 2023/4/27.
//

import XCTest
@testable import UBike
import RxSwift
import CoreLocation
import MapKit
import RxTest

final class HomeViewModelTests: XCTestCase {

    private var sut: HomeViewModel!
    
    private func makeSUT(locationManager: LocationManagerProxyType = MockLocationManagerProxy(getCurrentLocationResult: .never()),
                         ubikeStationsRepository: UbikeStationsRepositoryType = MockUbikeStationsRepository(),
                         routeRepository: RouteRepositoryType = MockRouteRepository(),
                         mapper: UibikeStationBottomSheetStateMapperType = MockUibikeStationBottomSheetStateMapper(),
                         coordinator: HomeCoordinatorType = MockHomeCoordinator() ) -> HomeViewModel {
        HomeViewModel(locationManager: locationManager,
                      ubikeStationsRepository: ubikeStationsRepository,
                      routeRepository: routeRepository,
                      mapper: mapper,
                      coordinator: coordinator)
    }
    
    private func getUbikeStation(id: String = "",
                                 name: UbikeStation.Name = .init(english: "", chinese: ""),
                                 area: UbikeStation.Area = .init(english: "", chinese: ""),
                                 coordinate: UbikeStation.Coordinate = .init(latitude: 0, longitude: 0),
                                 address: UbikeStation.Address = .init(english: "", chinese: ""),
                                 parkingSpace: UbikeStation.ParkingSpace = .init(total: 0, bike: 0, empty: 0),
                                 isFavorite: Bool = false,
                                 updatedDate: Date? = nil) -> UbikeStation {
        
        UbikeStation(id: id, name: name, area: area, coordinate: coordinate, address: address, parkingSpace:     parkingSpace, isFavorite: isFavorite, updatedDate: updatedDate)
    }
    
    ///
    /// 當`畫面載入完成`時，更新`地圖顯示區域`。
    ///
    /// Expect:
    ///     更新地圖顯示區域事件(只會發出`1`次):
    ///         中心點: `(經度：123, 緯度：222)`
    ///         半徑: `5000`
    ///
    /// Condition:
    ///     使用者位置: `(經度：123, 緯度：222)`
    ///
    func testUpdateMapRegionWhenViewDidLoadWithUserLocation() {
        // expect
        let expectedLatitude: Double = 123
        let expectedLongitude: Double = 222
        let expectedDistance: CLLocationDistance = 5000
        
        // mock
        let mockLocation = CLLocation(latitude: 123, longitude: 222)
        let mockLocationManagerProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(mockLocation))
        
        // sut
        let sut = makeSUT(locationManager: mockLocationManagerProxy)

        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)

        sut.viewDidLoad.accept(())
        sut.viewDidLoad.accept(())
        
        XCTAssertEqual(observer.events.count, 1) // only execute once
        
        XCTAssertEqual(observer.events[0].value.element?.0.coordinate.latitude, expectedLatitude)
        XCTAssertEqual(observer.events[0].value.element?.0.coordinate.longitude, expectedLongitude)
        XCTAssertEqual(observer.events[0].value.element?.1, expectedDistance)
    }
    
    ///
    /// 當`畫面載入完成`時，地圖顯示區域`不移動`。
    ///
    /// Expect:
    ///     更新地圖顯示區域事件: `none`
    ///
    /// Condition:
    ///     使用者位置: `nil`
    ///
    func testUpdateMapRegionWhenViewDidLoadWithoutUserLocation() {
        // mock
        let mockLocationManagerProxy = MockLocationManagerProxy(getCurrentLocationResult: .empty())
        
        // sut
        let sut = makeSUT(locationManager: mockLocationManagerProxy)

        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)

        sut.viewDidLoad.accept(())
        sut.viewDidLoad.accept(())
        
        XCTAssertEqual(observer.events.count, 0)
    }
    
    ///
    /// 當`點擊定位按鈕`時，更新`地圖顯示區域`。
    ///
    /// Expect:
    ///     更新地圖顯示區域事件(可發出`多`次):
    ///         中心點: `(經度：123, 緯度：2222)`
    ///         半徑: `nil`
    ///
    /// Condition:
    ///     使用者位置: `(經度：123, 緯度：2222)`
    ///
    func testUpdateMapRegionWhenPositionButtonDidTapWithUserLocation() {
        // expect
        let expectedLatitude: Double = 123
        let expectedLongitude: Double = 2222
        let expectedDistance: CLLocationDistance? = nil
        
        // mock
        let mockLocation = CLLocation(latitude: 123, longitude: 2222)
        let mockLocationManagerProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(mockLocation))
        
        // sut
        let sut = makeSUT(locationManager: mockLocationManagerProxy)

        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)

        sut.positioningButtonDidTap.accept(())
        sut.positioningButtonDidTap.accept(())
        
        XCTAssertEqual(observer.events.count, 2)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element?.0.coordinate.latitude, expectedLatitude)
            XCTAssertEqual(event.value.element?.0.coordinate.longitude, expectedLongitude)
            XCTAssertEqual(event.value.element?.1, expectedDistance)
        }
    }

    ///
    /// 當`點擊定位按鈕`時，地圖顯示區域`不移動`。
    ///
    /// Expect:
    ///     更新地圖顯示區域事件: `none`
    ///
    /// Condition:
    ///     使用者位置: `nil`
    ///
    func testUpdateMapRegionWhenPositionButtonDidTapWithoutUserLocation() {
        // mock
        let mockLocationManagerProxy = MockLocationManagerProxy(getCurrentLocationResult: .empty())
        
        // sut
        let sut = makeSUT(locationManager: mockLocationManagerProxy)

        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)

        sut.positioningButtonDidTap.accept(())
        sut.positioningButtonDidTap.accept(())
        
        XCTAssertEqual(observer.events.count, 0)
    }
    
    ///
    /// 當`點擊Ubike場站地圖標注`時，更新`地圖顯示區域`。
    ///
    /// Expect:
    ///     更新地圖顯示區域事件(可發出`多`次):
    ///         中心點: `(經度：555, 緯度：888)`
    ///         半徑: `nil`
    ///
    /// Condition:
    ///     Ubike場站位置: `(經度：555, 緯度：888)`
    ///
    func testUpdateMapRegionWhenAnnotationDidTap() {
        // expect
        let expectedLatitude: Double = 555
        let expectedLongitude: Double = 888
        let expectedDistance: CLLocationDistance? = nil
        
        // mock
        let mockUbikeStation = getUbikeStation(coordinate: .init(latitude: 555, longitude: 888))
        
        // sut
        let sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)
        
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 2)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element?.0.coordinate.latitude, expectedLatitude)
            XCTAssertEqual(event.value.element?.0.coordinate.longitude, expectedLongitude)
            XCTAssertEqual(event.value.element?.1, expectedDistance)
        }
    }

}

// MARK: mock objects
class MockLocationManagerProxy: LocationManagerProxyType {
    var delegate: LocationManagerProxyDelegate?
    
    private let getCurrentLocationResult: Maybe<CLLocation>

    init(delegate: LocationManagerProxyDelegate? = nil, getCurrentLocationResult: Maybe<CLLocation>) {
        self.delegate = delegate
        self.getCurrentLocationResult = getCurrentLocationResult
    }
    
    func getCurrentLocation() -> Maybe<CLLocation> {
        getCurrentLocationResult
    }
}

class MockUbikeStationsRepository: UbikeStationsRepositoryType {
    func getUbikeStation(id: String) -> Single<UbikeStation?> {
        return .never()
    }
    
    func getUbikeStations(isLatest: Bool) -> RxSwift.Single<[UbikeStation]> {
        return .never()
    }
    
    func updateUbikeStation(id: String, isFavorite: Bool) -> Single<Void> {
        return .never()
    }
}

class MockRouteRepository: RouteRepositoryType {
    func getWalkingRoute(source: CLLocation, destination: CLLocation) -> Single<MKRoute> {
        return .never()
    }
}

class MockUibikeStationBottomSheetStateMapper: UibikeStationBottomSheetStateMapperType {
    func getNavigationText(route: MKRoute) -> String {
        return ""
    }
}

class MockHomeCoordinator: HomeCoordinatorType {
    func start() {
        
    }
    
    func openUbikeListModule() {
        
    }
}
