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

    ///
    /// 當`畫面載入完成`時，更新所有`Ubike場站地圖標注`。
    ///
    /// Expect:
    ///     更新Ubike場站地圖標注事件(只會發出`1`+`1`次):
    ///         Ubike場站 (`3`個):
    ///             id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///             id:`22`, 座標: `(經度：22, 緯度：22)`
    ///             id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    /// Condition:
    ///     Ubike場站 (`3`個):
    ///             id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///             id:`22`, 座標: `(經度：22, 緯度：22)`
    ///             id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    func testUpdateUbikeStationAnnotationWhenViewDidLoad() {
        // expect
        let expectUbikeStations = [getUbikeStation(id: "4444", coordinate: .init(latitude: 4444, longitude: 44)),
                                   getUbikeStation(id: "22", coordinate: .init(latitude: 22, longitude: 22)),
                                   getUbikeStation(id: "00", coordinate: .init(latitude: 123, longitude: 888))]

        // mock
        let mockUbikeStations = [getUbikeStation(id: "4444", coordinate: .init(latitude: 4444, longitude: 44)),
                                 getUbikeStation(id: "22", coordinate: .init(latitude: 22, longitude: 22)),
                                 getUbikeStation(id: "00", coordinate: .init(latitude: 123, longitude: 888))]
        
        // sut
        let sut = makeSUT(ubikeStationsRepository: MockUbikeStationsRepository(ubikeStations: mockUbikeStations))
        
        let observer = TestScheduler(initialClock: 0).createObserver([UBikeStationAnnotation].self)
        _ = sut.updateUibikeStationsAnnotation.subscribe(observer)
        
        sut.viewDidLoad.accept(())
        sut.viewDidLoad.accept(())
        sut.viewDidLoad.accept(())
        
        XCTAssertEqual(observer.events.count, 2)
        
        XCTAssertEqual(observer.events[0].value.element?.count, 0) // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element?.count, 3)
                
            for (nub, annotation) in event.value.element!.enumerated() {
                XCTAssertEqual(annotation.ubikeStation.id, expectUbikeStations[nub].id)
                XCTAssertEqual(annotation.ubikeStation.coordinate.latitude,
                               expectUbikeStations[nub].coordinate.latitude)
                XCTAssertEqual(annotation.ubikeStation.coordinate.longitude,
                               expectUbikeStations[nub].coordinate.longitude)
            }
        }
    }
    
    ///
    /// 當`重新整理按鈕點擊`時，更新所有`Ubike場站地圖標注`。
    ///
    /// Expect:
    ///     更新Ubike場站地圖標注事件(可以發出`1`+`多`次):
    ///         Ubike場站 (`3`個):
    ///             id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///             id:`22`, 座標: `(經度：22, 緯度：22)`
    ///             id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    /// Condition:
    ///     Ubike場站 (`3`個):
    ///             id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///             id:`22`, 座標: `(經度：22, 緯度：22)`
    ///             id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    func testUpdateUbikeStationAnnotationWhenRefreshButtonDidTap() {
        // expect
        let expectUbikeStations = [getUbikeStation(id: "4444", coordinate: .init(latitude: 4444, longitude: 44)),
                                   getUbikeStation(id: "22", coordinate: .init(latitude: 22, longitude: 22)),
                                   getUbikeStation(id: "00", coordinate: .init(latitude: 123, longitude: 888))]

        // mock
        let mockUbikeStations = [getUbikeStation(id: "4444", coordinate: .init(latitude: 4444, longitude: 44)),
                                 getUbikeStation(id: "22", coordinate: .init(latitude: 22, longitude: 22)),
                                 getUbikeStation(id: "00", coordinate: .init(latitude: 123, longitude: 888))]
        
        // sut
        let sut = makeSUT(ubikeStationsRepository: MockUbikeStationsRepository(ubikeStations: mockUbikeStations))
        
        let observer = TestScheduler(initialClock: 0).createObserver([UBikeStationAnnotation].self)
        _ = sut.updateUibikeStationsAnnotation.subscribe(observer)
        
        sut.refreshAnnotationButtonDidTap.accept(())
        sut.refreshAnnotationButtonDidTap.accept(())
        sut.refreshAnnotationButtonDidTap.accept(())
        
        XCTAssertEqual(observer.events.count, 4)
        
        XCTAssertEqual(observer.events[0].value.element?.count, 0) // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element?.count, 3)
                
            for (nub, annotation) in event.value.element!.enumerated() {
                XCTAssertEqual(annotation.ubikeStation.id, expectUbikeStations[nub].id)
                XCTAssertEqual(annotation.ubikeStation.coordinate.latitude,
                               expectUbikeStations[nub].coordinate.latitude)
                XCTAssertEqual(annotation.ubikeStation.coordinate.longitude,
                               expectUbikeStations[nub].coordinate.longitude)
            }
        }
    }
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`Ubike場站資訊小卡`狀態。
    ///
    /// Expect:
    ///     更新Ubike場站資訊小卡狀態事件(可以發出`1`+`多`次):
    ///         狀態: `regular (id: 228)`
    ///
    /// Condition:
    ///     Ubike場站地圖標注:
    ///         id: `228`
    ///
    func testUpdateUbikeStationDetailStateWhenUbikeStationAnnotationDidSelect() {
        // mock
        let mockUbikeStation = getUbikeStation(id: "228")
        
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(UibikeStationBottomSheetState.self)
        _ = sut.updateUibikeStationBottomSheet.subscribe(observer)

        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element, .empty) // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, .regular(id: "228"))
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
    private let ubikeStations: [UbikeStation]
    
    init(ubikeStations: [UbikeStation] = []) {
        self.ubikeStations = ubikeStations
    }
    
    func getUbikeStation(id: String) -> Single<UbikeStation?> {
        return .never()
    }
    
    func getUbikeStations(isLatest: Bool) -> Single<[UbikeStation]> {
        .just(ubikeStations)
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
