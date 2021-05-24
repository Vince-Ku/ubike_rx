//
//  UBikeTests.swift
//  UBikeTests
//
//  Created by Vince on 2021/5/12.
//

import RxSwift
import XCTest
import RxCocoa
import RxTest

@testable import UBike

class HomeViewModelTests: XCTestCase {
    
    var vm : HomeViewModel!
    var disposeBag : DisposeBag!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vm = HomeViewModel()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //
    // Test : Api
    // Expectation : result not null
    //
    func testLoadingResult() throws {
        
        let expect = expectation(description: #function)
        var result : [UBike]!
        
        vm.ubikes.subscribe(onNext:{ ubikes in
            result = ubikes
            expect.fulfill()
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertNotNil(result)
        }
        
    }

}
