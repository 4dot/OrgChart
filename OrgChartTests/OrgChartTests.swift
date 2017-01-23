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
    
    // Test for loading .json file and Check Data Validation
    
    func testOrgChartData() {
        
        // loading .json file
        orgChartVC?.orgChart = OrgChartData.loadOrgChartData("OrgChart")
        
        XCTAssert(orgChartVC?.orgChart != nil, "OrgChart.json file couldn't be load")
        
        
        // Check Data Validation
        
        if let rootCellData = orgChartVC?.orgChart {
            
            var allCellDatas:[OrgChartData] = [rootCellData]
            var idx = 0
            
            // Collect all cell datas
            while idx < allCellDatas.count {
                allCellDatas += allCellDatas[idx].children
                idx += 1
            }
            
            NSLog("Total Cell's count is \(allCellDatas.count)")
            
            // Get a duplicate udids
            
            let duplicates = Array(Set(allCellDatas.filter({ (data) -> Bool in
                allCellDatas.filter( {$0 == data }).count > 1
            })))
            
            XCTAssert(duplicates.count <= 0, "Detacted duplicate datas.")
        }
    }
}
