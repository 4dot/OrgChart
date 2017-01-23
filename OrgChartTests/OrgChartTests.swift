/**
 * OrgChartTests.swift
 * OrgChart
 *
 * Created by Park, Chanick on 1/13/17.
 * Copyright © 2016 Park, Chanick. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
