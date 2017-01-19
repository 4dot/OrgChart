//
//  OrgChartTests.swift
//  OrgChartTests
//
//  Created by Park, Chanick on 3/16/16.
//  Copyright © 2016 Park, Chanick. All rights reserved.
//

import XCTest
@testable import OrgChart

class OrgChartTests: XCTestCase {
    
    var orgChartVC: OrgChartViewController?
    
    
    
    override func setUp() {
        super.setUp()
        
        orgChartVC = OrgChartViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // Test for loading .json file
    
    func testOrgChartData() {
        
        // loading .json file
        XCTAssertNil(orgChartVC?.orgChart, "OrgChart.json file couldn't be load")
        
        // check incorrect data
        
        // check duplicated guid
    }
}
