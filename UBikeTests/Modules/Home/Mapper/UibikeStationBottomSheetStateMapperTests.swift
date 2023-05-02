//
//  UibikeStationBottomSheetStateMapperTests.swift
//  UBikeTests
//
//  Created by Vince on 2023/5/3.
//

import XCTest
import MapKit
@testable import UBike

final class UibikeStationBottomSheetStateMapperTests: XCTestCase {

    private var sut: UibikeStationBottomSheetStateMapper = UibikeStationBottomSheetStateMapper()

    ///
    /// 當路程預期時間為`0`時，回傳文案`步行 1 分鐘以內`。
    ///
    /// Expect: `步行 1 分鐘以內`
    ///
    /// Condition:
    ///     路程預期時間：`0 秒`
    ///     移動方式：`步行`
    ///
    func testReturnWhenExpectedTravelIsZero() {
        // mock
        let mockRoute = MockMKRoute(mockExpectedTravelTime: 0, mockTransportType: .walking)
        
        // sut
        let result = sut.getNavigationText(route: mockRoute)
        
        XCTAssertEqual(result, "步行 1 分鐘以內")
    }
    
    ///
    /// 當路程預期時間`小於一分鐘`時，回傳文案`步行 1 分鐘以內`。
    ///
    /// Expect: `步行 1 分鐘以內`
    ///
    /// Condition:
    ///     路程預期時間：`59 秒`
    ///     移動方式：`步行`
    ///
    func testReturnWhenExpectedTravelTimeLessThanOneMinute() {
        // mock
        let mockRoute = MockMKRoute(mockExpectedTravelTime: 59, mockTransportType: .walking)
        
        // sut
        let result = sut.getNavigationText(route: mockRoute)
        
        XCTAssertEqual(result, "步行 1 分鐘以內")
    }
    
    ///
    /// 當路程預期時間`大於一分鐘`且`小於一小時`時，回傳文案`步行 %@ 分鐘`。
    ///
    /// Expect: `步行 22 分鐘`
    ///
    /// Condition:
    ///     路程預期時間：`22 分鐘`
    ///     移動方式：`步行`
    ///
    func testReturnWhenExpectedTravelTimeGreaterThanOneMinuteLessThanOneHour() {
        // mock
        let mockRoute = MockMKRoute(mockExpectedTravelTime: 60 * 22, mockTransportType: .walking)
        
        // sut
        let result = sut.getNavigationText(route: mockRoute)
        
        XCTAssertEqual(result, "步行 22 分鐘")
    }
    
    ///
    /// 當路程預期時間`大於一小時`時，回傳文案`步行 %@ 小時 %@ 分鐘`。
    ///
    /// Expect: `步行 1 小時 36 分鐘`
    ///
    /// Condition:
    ///     路程預期時間：`1 小時 36 分鐘`
    ///     移動方式：`步行`
    ///
    func testReturnWhenExpectedTravelTimeGreaterThanOneHour() {
        // mock
        let mockRoute = MockMKRoute(mockExpectedTravelTime: 60 * (60 + 36), mockTransportType: .walking)
        
        // sut
        let result = sut.getNavigationText(route: mockRoute)
        
        XCTAssertEqual(result, "步行 1 小時 36 分鐘")
    }

}

// MARK: Mock object
class MockMKRoute: MKRoute {
    private let mockExpectedTravelTime: TimeInterval
    private let mockTransportType: MKDirectionsTransportType
    
    init(mockExpectedTravelTime: TimeInterval, mockTransportType: MKDirectionsTransportType) {
        self.mockExpectedTravelTime = mockExpectedTravelTime
        self.mockTransportType = mockTransportType
        super.init()
    }
    
    override var expectedTravelTime: TimeInterval {
        mockExpectedTravelTime
    }
    
    override var transportType: MKDirectionsTransportType {
        mockTransportType
    }
}
