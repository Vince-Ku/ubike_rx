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
    
    private func makeSUT(locationManager: LocationManagerProxyType = MockLocationManagerProxy(),
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
        // mock
        let mockLocation = CLLocation(latitude: 123, longitude: 222)
        let mockLocationManagerProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(mockLocation))
        
        // sut
        let sut = makeSUT(locationManager: mockLocationManagerProxy)

        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)

        sut.viewDidLoad.accept(())
        sut.viewDidLoad.accept(())
        sut.viewDidLoad.accept(())
        
        XCTAssertEqual(observer.events.count, 1) // only execute once
        
        XCTAssertEqual(observer.events[0].value.element?.0.coordinate.latitude, 123)
        XCTAssertEqual(observer.events[0].value.element?.0.coordinate.longitude, 222)
        XCTAssertEqual(observer.events[0].value.element?.1, 5000)
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
        // mock
        let mockLocation = CLLocation(latitude: 123, longitude: 2222)
        let mockLocationManagerProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(mockLocation))
        
        // sut
        let sut = makeSUT(locationManager: mockLocationManagerProxy)

        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)

        sut.positioningButtonDidTap.accept(())
        sut.positioningButtonDidTap.accept(())
        sut.positioningButtonDidTap.accept(())
        
        XCTAssertEqual(observer.events.count, 3)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element?.0.coordinate.latitude, 123)
            XCTAssertEqual(event.value.element?.0.coordinate.longitude, 2222)
            XCTAssertEqual(event.value.element?.1, nil)
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
        // mock
        let mockUbikeStation = getUbikeStation(coordinate: .init(latitude: 555, longitude: 888))
        
        // sut
        let sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)
        
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 3)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element?.0.coordinate.latitude, 555)
            XCTAssertEqual(event.value.element?.0.coordinate.longitude, 888)
            XCTAssertEqual(event.value.element?.1, nil)
        }
    }

    ///
    /// 當`畫面載入完成`時，更新所有`Ubike場站地圖標注`。
    ///
    /// Expect:
    ///     更新Ubike場站地圖標注事件(只會發出`1`+`1`次):
    ///         default(`0`個):
    ///             []
    ///         第一次:
    ///             Ubike場站 (`3`個):
    ///                 id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///                 id:`22`, 座標: `(經度：22, 緯度：22)`
    ///                 id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    /// Condition:
    ///     Ubike場站 (`3`個):
    ///             id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///             id:`22`, 座標: `(經度：22, 緯度：22)`
    ///             id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    func testUpdateUbikeStationAnnotationWhenViewDidLoad() {
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
                XCTAssertEqual(annotation.ubikeStation.id, mockUbikeStations[nub].id)
                XCTAssertEqual(annotation.ubikeStation.coordinate.latitude,
                               mockUbikeStations[nub].coordinate.latitude)
                XCTAssertEqual(annotation.ubikeStation.coordinate.longitude,
                               mockUbikeStations[nub].coordinate.longitude)
            }
        }
    }
    
    ///
    /// 當`重新整理按鈕點擊`時，更新所有`Ubike場站地圖標注`。
    ///
    /// Expect:
    ///     更新Ubike場站地圖標注事件(可以發出`1`+`多`次):
    ///         default(`0`個):
    ///             []
    ///         第N次:
    ///             Ubike場站 (`3`個):
    ///                 id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///                 id:`22`, 座標: `(經度：22, 緯度：22)`
    ///                 id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    /// Condition:
    ///     Ubike場站 (`3`個):
    ///             id:`4444`, 座標: `(經度：4444, 緯度：44)`
    ///             id:`22`, 座標: `(經度：22, 緯度：22)`
    ///             id:`00`, 座標: `(經度：123, 緯度：888)`
    ///
    func testUpdateUbikeStationAnnotationWhenRefreshButtonDidTap() {
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
                XCTAssertEqual(annotation.ubikeStation.id, mockUbikeStations[nub].id)
                XCTAssertEqual(annotation.ubikeStation.coordinate.latitude,
                               mockUbikeStations[nub].coordinate.latitude)
                XCTAssertEqual(annotation.ubikeStation.coordinate.longitude,
                               mockUbikeStations[nub].coordinate.longitude)
            }
        }
    }
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`Ubike場站資訊小卡`狀態。
    ///
    /// Expect:
    ///     更新Ubike場站資訊小卡狀態事件(可以發出`1`+`多`次):
    ///         default:
    ///             狀態: `empty`
    ///         第N次:
    ///             狀態: `regular (id: 228)`
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
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`Ubike場站名稱`。
    ///
    /// Expect:
    ///     更新Ubike場站名稱事件(可以發出`1`+`多`次):
    ///         default:
    ///             名稱: `尚未選擇站點`
    ///         第N次:
    ///             名稱: `Vince 場站`
    ///
    /// Condition:
    ///     Ubike場站地圖標注:
    ///         名稱: `Vince 場站`
    ///
    func testUpdateUbikeStationNameWhenUbikeStationAnnotationDidSelect() {
        // mock
        let mockUbikeStation = getUbikeStation(name: .init(english: "", chinese: "Vince 場站"))
        
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(String.self)
        _ = sut.updateUibikeStationNameText.subscribe(observer)

        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element, "尚未選擇站點") // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, "Vince 場站")
        }
    }
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`Ubike車輛數量`。
    ///
    /// Expect:
    ///     更新Ubike車輛數事件(可以發出`1`+`多`次):
    ///         default:
    ///              數量: `nil`
    ///         第N次:
    ///              數量: `777` 台
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateUbikeNumberWhenUbikeStationAnnotationDidSelect() {
        // mock
        let mockUbikeStation = getUbikeStation(parkingSpace: .init(total: 0, bike: 777, empty: 0))
        
        // sut
        sut = makeSUT(ubikeStationsRepository: MockUbikeStationsRepository(ubikeStation: mockUbikeStation))
        
        let observer = TestScheduler(initialClock: 0).createObserver(String?.self)
        _ = sut.updateUibikeSpaceText.subscribe(observer)

        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element!, nil) // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, "777")
        }
    }
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`空車位數量`。
    ///
    /// Expect:
    ///     更新空車位數量事件(可以發出`1`+`多`次):
    ///         default:
    ///              數量: `nil`
    ///         第N次:
    ///              數量: `568` 台
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateEmptySpaceNumberWhenUbikeStationAnnotationDidSelect() {
        // mock
        let mockUbikeStation = getUbikeStation(parkingSpace: .init(total: 0, bike: 0, empty: 568))
        
        // sut
        sut = makeSUT(ubikeStationsRepository: MockUbikeStationsRepository(ubikeStation: mockUbikeStation))
        
        let observer = TestScheduler(initialClock: 0).createObserver(String?.self)
        _ = sut.updateEmptySpaceText.subscribe(observer)

        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element!, nil) // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, "568")
        }
    }
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`收藏按鈕狀態`。
    ///
    /// Expect:
    ///     更新收藏鈕狀態事件(可以發出`1`+`多`次):
    ///         default:
    ///             狀態: `false` (未收藏)
    ///         第N次:
    ///             狀態: `true`  (已收藏)
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateCollectionButtonStateWhenUbikeStationAnnotationDidSelect() {
        // mock
        let mockUbikeStation = getUbikeStation(isFavorite: true)
        
        // sut
        sut = makeSUT(ubikeStationsRepository: MockUbikeStationsRepository(ubikeStation: mockUbikeStation))
        
        let observer = TestScheduler(initialClock: 0).createObserver(Bool.self)
        _ = sut.updateCollectionButtonState.subscribe(observer)

        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element, false) // default view state

        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, true)
        }
    }
    
    ///
    /// 當點擊`收藏按鈕`時，更新`收藏按鈕狀態`。
    ///
    /// Expect:
    ///     更新收藏鈕狀態事件(可以發出`1`+`多`次):
    ///         default:
    ///             狀態: `false` (未收藏)
    ///         第N次:
    ///             狀態: `true`  (已收藏)
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateCollectionButtonStateWhenCollectionButtonDidTap() {
        // mock
        let mockUbikeStationsRepository = MockUbikeStationsRepository(isFavorite: true)
        
        // sut
        sut = makeSUT(ubikeStationsRepository: mockUbikeStationsRepository)
        
        let observer = TestScheduler(initialClock: 0).createObserver(Bool.self)
        _ = sut.updateCollectionButtonState.subscribe(observer)

        sut.collectionButtonDidTap.accept(("", true))
        sut.collectionButtonDidTap.accept(("", true))
        sut.collectionButtonDidTap.accept(("", true))
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element, false) // default view state
        
        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, true)
        }
    }
    
    ///
    /// 當點擊`Ubike場站地圖標注`時，更新`導航按鈕標題文字`。
    ///
    /// Expect:
    ///     更新導航按鈕標題事件(可以發出`1`+`多`次):
    ///         default:
    ///             狀態: `nil`
    ///         第N次:
    ///             狀態: `還有很多時間喔！！`
    ///
    /// Condition:
    ///     使用者位置: `(經度：111, 緯度：9282)`
    ///     Ubike場站位置: `(經度：555, 緯度：888)`
    ///
    func testUpdateNavigaionTitleWhenAnnotationDidSelect() {
        // mock
        let mockLocationProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(.init(latitude: 111, longitude: 9282)))
        let mockRouteRepository = MockRouteRepository(route: MKRoute())
        let mockMapper = MockUibikeStationBottomSheetStateMapper(titleText: "還有很多時間喔！！")
        let mockUbikeStation = getUbikeStation(coordinate: .init(latitude: 555, longitude: 888))
        
        // sut
        sut = makeSUT(locationManager: mockLocationProxy, routeRepository: mockRouteRepository, mapper: mockMapper)
        
        let observer = TestScheduler(initialClock: 0).createObserver(String?.self)
        _ = sut.updateNavigationTitle.subscribe(observer)

        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        sut.annotationDidSelect.accept(mockUbikeStation)
        
        XCTAssertEqual(observer.events.count, 1+3)
        
        XCTAssertEqual(observer.events[0].value.element!, nil) // default view state
        
        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, "還有很多時間喔！！")
        }
    }
    
    ///
    /// 當點擊`導航按鈕`時，更新地圖上的`導航路線`。
    ///
    /// Expect:
    ///     更新導航路線事件(可發出`1`+`多`次):
    ///         default:
    ///             導航路線: `nil`
    ///         第N次:
    ///             導航路線: `mockRoute` reference
    ///
    /// Condition:
    ///     使用者位置: `(經度：222, 緯度：7777)`
    ///     場站位置: `(經度：111, 緯度：6666)`
    ///
    func testUpdateRouteWhenNavigationButtonDidTap() {
        // mock
        let mockRoute = MKRoute()
        let mockUbikeStationRepository = MockUbikeStationsRepository(ubikeStation: getUbikeStation(coordinate: .init(latitude: 111, longitude: 6666)))
        let mockLocationProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(.init(latitude: 222, longitude: 7777)))
        let mockRouteRepository = MockRouteRepository(route: mockRoute)
        
        // sut
        sut = makeSUT(locationManager: mockLocationProxy, ubikeStationsRepository: mockUbikeStationRepository, routeRepository: mockRouteRepository)
        
        let observer = TestScheduler(initialClock: 0).createObserver(MKRoute?.self)
        _ = sut.updateRoute.subscribe(observer)
        
        sut.navigationButtonDidTap.accept("")
        sut.navigationButtonDidTap.accept("")
        sut.navigationButtonDidTap.accept("")
        
        XCTAssertEqual(observer.events.count, 4)
        
        XCTAssertEqual(observer.events[0].value.element!, nil) // default view state
        
        for event in observer.events[1...] {
            XCTAssertEqual(event.value.element, mockRoute)
        }
    }
    
    ///
    /// 當點擊`導航按鈕`時，更新`地圖顯示區域`。
    ///
    /// Expect:
    ///     更新地圖顯示區域事件(可發出`多`次):
    ///         第N次:
    ///             中心點: `mockRoute` 的中心點 (經度, 緯度)
    ///             距離: `mockRoute` 的距離
    ///
    /// Condition:
    ///     使用者位置: `(經度：44, 緯度：11)`
    ///     場站位置: `(經度：555, 緯度：12345)`
    ///
    func testUpdateMapRegionWhenNavigationButtonDidTap() {
        // mock
        let mockRoute = MKRoute()
        let mockUbikeStationRepository = MockUbikeStationsRepository(ubikeStation: getUbikeStation(coordinate: .init(latitude: 555, longitude: 12345)))
        let mockLocationProxy = MockLocationManagerProxy(getCurrentLocationResult: .just(.init(latitude: 44, longitude: 11)))
        let mockRouteRepository = MockRouteRepository(route: mockRoute)
        
        // sut
        sut = makeSUT(locationManager: mockLocationProxy, ubikeStationsRepository: mockUbikeStationRepository, routeRepository: mockRouteRepository)
        
        let observer = TestScheduler(initialClock: 0).createObserver((CLLocation, CLLocationDistance?).self)
        _ = sut.updateMapRegion.subscribe(observer)
        
        sut.navigationButtonDidTap.accept("")
        sut.navigationButtonDidTap.accept("")
        sut.navigationButtonDidTap.accept("")
        
        XCTAssertEqual(observer.events.count, 3)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element?.0.coordinate.latitude, mockRoute.polyline.coordinate.latitude)
            XCTAssertEqual(event.value.element?.0.coordinate.longitude, mockRoute.polyline.coordinate.longitude)
            XCTAssertEqual(event.value.element?.1, mockRoute.distance)
        }
    }
    
    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新`Ubike場站資訊小卡狀態`。
    ///
    /// Expect:
    ///     更新Ubike場站資訊小卡狀態事件(可以發出`1`+`多`次):
    ///         default:
    ///             狀態: `empty` (空白)
    ///         第N次:
    ///             狀態: `empty` (空白)
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateUibikeStationBottomSheetStateWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(UibikeStationBottomSheetState.self)
        _ = sut.updateUibikeStationBottomSheet.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element, .empty)
        }
    }

    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新 `Ubike場站名稱`。
    ///
    /// Expect:
    ///     更新Ubike場站名稱事件(可以發出`1`+`多`次):
    ///         default:
    ///             名稱: `尚未選擇站點`
    ///         第N次:
    ///             名稱: `尚未選擇站點`
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateUpdateUibikeStationNameTextWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(String.self)
        _ = sut.updateUibikeStationNameText.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element, "尚未選擇站點")
        }
    }
    
    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新`收藏鈕狀態`。
    ///
    /// Expect:
    ///     更新收藏鈕狀態事件(可以發出`1`+`多`次):
    ///         default:
    ///             狀態: `false` (未收藏)
    ///         第N次:
    ///             狀態: `false` (未收藏)
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateCollectionButtonStateWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(Bool.self)
        _ = sut.updateCollectionButtonState.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element, false)
        }
    }
    
    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新`Ubike車輛數`。
    ///
    /// Expect:
    ///     更新Ubike車輛數事件(可以發出`1`+`多`次):
    ///         default:
    ///             數量: `nil`
    ///         第N次:
    ///             數量: `nil`
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateUbikeSpaceWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(String?.self)
        _ = sut.updateUibikeSpaceText.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element!, nil)
        }
    }
    
    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新`空車位數量`。
    ///
    /// Expect:
    ///     更新空車位數量事件(可以發出`1`+`多`次):
    ///         default:
    ///             數量: `nil`
    ///         第N次:
    ///             數量: `nil`
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateEmptySpaceWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(String?.self)
        _ = sut.updateEmptySpaceText.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element!, nil)
        }
    }
    
    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新`導航路線`。
    ///
    /// Expect:
    ///     更新導航路線事件(可發出`1`+`多`次):
    ///         default:
    ///             導航路線: `nil`
    ///         第N次:
    ///             導航路線: `nil`
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateRouteWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(MKRoute?.self)
        _ = sut.updateRoute.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element!, nil)
        }
    }
    
    ///
    /// 當取消點選`Ubike場站地圖標注`時，更新`導航按鈕標題`。
    ///
    /// Expect:
    ///     更新導航按鈕標題事件(可以發出`1`+`多`次):
    ///         default:
    ///             導航按鈕標題: `nil`
    ///         第N次:
    ///             導航按鈕標題: `nil`
    ///
    /// Condition:
    ///     none
    ///
    func testUpdateNavigationTitleWhenUbikeStationAnnotationDeselect() {
        // sut
        sut = makeSUT()
        
        let observer = TestScheduler(initialClock: 0).createObserver(String?.self)
        _ = sut.updateNavigationTitle.subscribe(observer)
        
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        sut.annotationDidDeselect.accept(getUbikeStation())
        
        XCTAssertEqual(observer.events.count, 4)
        
        for event in observer.events {
            XCTAssertEqual(event.value.element!, nil)
        }
    }
    
    ///
    /// 當點擊`Ubike場站列表按鈕`時，打開`Ubike場站列表`模組。
    ///
    /// Expect:
    ///     路由器調用方法 `openUbikeListModule()`
    ///
    /// Condition:
    ///     none
    ///
    func testOpenUbikeListModuleWhenShowListButtonDidTap() {
        // mock
        let mockCoordinator = MockHomeCoordinator()
        
        // sut
        sut = makeSUT(coordinator: mockCoordinator)
        
        sut.showListButtonDidTap.accept(())
        
        XCTAssertEqual(mockCoordinator.openUbikeListModuleDidCalled, true)
    }
}

// MARK: Utility
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

// MARK: mock objects
class MockLocationManagerProxy: LocationManagerProxyType {
    var delegate: LocationManagerProxyDelegate?
    
    private let getCurrentLocationResult: Maybe<CLLocation>

    init(delegate: LocationManagerProxyDelegate? = nil, getCurrentLocationResult: Maybe<CLLocation> = .never()) {
        self.delegate = delegate
        self.getCurrentLocationResult = getCurrentLocationResult
    }
    
    func getCurrentLocation() -> Maybe<CLLocation> {
        getCurrentLocationResult
    }
}

class MockUbikeStationsRepository: UbikeStationsRepositoryType {
    private let ubikeStations: [UbikeStation]
    private let ubikeStation: UbikeStation?
    private let isFavorite: Bool?
    
    init(ubikeStations: [UbikeStation] = [], ubikeStation: UbikeStation? = nil, isFavorite: Bool? = nil) {
        self.ubikeStations = ubikeStations
        self.ubikeStation = ubikeStation
        self.isFavorite = isFavorite
    }
    
    func getUbikeStation(id: String) -> Single<UbikeStation?> {
        .just(ubikeStation)
    }
    
    func getUbikeStations(isLatest: Bool) -> Single<[UbikeStation]> {
        .just(ubikeStations)
    }

    func updateUbikeStation(id: String, isFavorite: Bool) -> Single<UbikeStation> {
        guard let isFavorite = self.isFavorite else { return .never() }
        return .just(UBikeTests.getUbikeStation(isFavorite: isFavorite))
    }
}

class MockRouteRepository: RouteRepositoryType {
    private let route: MKRoute?
    
    init(route: MKRoute? = nil) {
        self.route = route
    }
    
    func getWalkingRoute(source: CLLocation, destination: CLLocation) -> Single<MKRoute> {
        guard let route = route else { return .never() }
        
        return .just( route)
    }
}

class MockUibikeStationBottomSheetStateMapper: UibikeStationBottomSheetStateMapperType {
    private let titleText: String?
    
    init(titleText: String? = nil) {
        self.titleText = titleText
    }
    
    func getNavigationText(route: MKRoute) -> String {
        guard let titleText = titleText else { return "" }
        return titleText
    }
}

class MockHomeCoordinator: HomeCoordinatorType {
    var openUbikeListModuleDidCalled = false
    
    func start() {}
    
    func openUbikeListModule() {
        openUbikeListModuleDidCalled = true
    }
}
