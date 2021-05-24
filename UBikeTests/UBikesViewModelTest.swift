//
//  vmTest.swift
//  UBikeTests
//
//  Created by Vince on 2021/5/24.
//

import RxSwift
import XCTest
import RxCocoa
import RxTest
import RxDataSources

@testable import UBike

class vmTest: XCTestCase {
    
    var vm : UBikesViewModel!
    var disposeBag : DisposeBag!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vm = UBikesViewModel()
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
        var result : GetUBikesResp!
        
        vm.loadingResult.subscribe(onNext:{ loadingResult in
            result = loadingResult
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

    //
    // Test : Area list data
    // Expectation : 1.The amount of all the area's number in Taipei are 12
    //               2.All the ubike station order by ubike's number DESC
    //
    func testUBikesForArea() throws {
        let expect = expectation(description: #function)
        let expectSectionNub = 12
        var result : [SectionModel<String, [UBikeCellModel]>]!
        
        vm.ubikesForArea
            .skip(1)//filter default
            .subscribe(onNext:{ loadingResult in
                result = loadingResult
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            //verify section number
            XCTAssertEqual(result.count, expectSectionNub)
            
            //verify ubikes number DESC
            for sectionModel in result{
                for (index1,ubikeCM1) in sectionModel.items.first!.enumerated() {
                    for (index2,ubikeCM2) in sectionModel.items.first!.enumerated() {
                        if index1 < index2 {
                            XCTAssert(Int(ubikeCM1.ubike.sbi!)! >= Int(ubikeCM2.ubike.sbi!)!)
                        }
                    }
                }
            }
        }
    }
    
    //
    // Test : The favorite button of the cell is tapped either in Area or favorite list
    // Expectation : 1.The favorite button of the cell is selected or deselected in Area list
    //               2.The cell exists or disappear in Favorite list
    //
    func testFavoriteBtnTap() throws {
        let ubike =
        UBike(sno: "0219", sna: "大理高中", tot: "38", sbi: "12", sarea: "萬華區", mday: "20210524235039", lat: "25.031147", lng: "121.490740", ar: "環河南路二段300號對面人行道(大理高中)", sareaen: "Wanhua Dist.", snaen: "Dali High School", aren: "No.300, Sec. 2, Huanhe S. Rd. (opposite)", bemp: "25", act: "1")
        
        let expectedName = ubike.sna
        let isFavorite = false
        let reuseIdentifier = "bikeItem" // favoriteBikeItem、bikeItem
        let cellModel = [ reuseIdentifier : UBikeCellModel(ubike: ubike, isFavorite: isFavorite) ]
        
        let expect = expectation(description: #function)
        var favoriteResult : [UBikeCellModel]!
        var areaResult : [SectionModel<String, [UBikeCellModel]>]!
        
        Observable.combineLatest(vm.ubikesForFavorite.skip(1),vm.ubikesForArea.skip(1))//filter default
            .subscribe(onNext:{ favorite,area in
                favoriteResult = favorite
                areaResult = area
                expect.fulfill()
                
            }).disposed(by: disposeBag)
        
        //mock tap favorite
        self.vm.favoriteBtnTap.onNext(cellModel)
        
        waitForExpectations(timeout: 5.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            if isFavorite {
                //exists in favorite list
                XCTAssertNotNil(favoriteResult.filter{ $0.ubike.sna == expectedName }.first)
                
                //exists in area list
                for sectionModel in areaResult{
                    if let tappedCell = sectionModel.items.first!.filter({ $0.ubike.sna == expectedName }).first{
                        XCTAssert(tappedCell.isFavorite)
                    }
                }
                
            }else{
                XCTAssertNil(favoriteResult.filter{ $0.ubike.sna == expectedName }.first)
                
                for sectionModel in areaResult{
                    if let tappedCell = sectionModel.items.first!.filter({ $0.ubike.sna == expectedName }).first{
                        XCTAssert(!tappedCell.isFavorite)
                    }
                }
            }
        }
    }
}
