//
//  YAWTATests.swift
//  YAWTATests
//
//  Created by MAC on 29.05.2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import XCTest
@testable import YAWTA


class YAWTATests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelLoading() {
        let model = UserModel()
        
        XCTAssertNotNil(model)
    }
    
    func testModelLoadsQuickly() {
        measure {
            _ = UserModel()
        }
    }

    func testDayChanging() {
        var model = UserModel(testing: true)
        let yesterday = model.getDate()
        
        // simulate isDayChangedNotification notification
        model.refreshTotal()
        let today = model.getDate() + 1
        
        XCTAssertNotEqual(today, yesterday)
    }
    
    func testRefreshTotal() {
        var model = UserModel(testing: true)
        model.addWater(1)
        model.refreshTotal()
        
        let totalWaterAfterRefresh = model.getWaterStatus()
        XCTAssertEqual(totalWaterAfterRefresh, 0, "Failed, its not 0")
    }
    
}


