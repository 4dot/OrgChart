//
//  OrgChartViewModel.swift
//  OrgChart
//
//  Created by OGiP on 3/16/22.
//  Copyright © 2022 Park, Chanick. All rights reserved.
//

import Foundation


class OrgChartViewModel : NSObject {
    var networkManager: ChartNetworkManager
    
    private(set) var chartData : OrgChartModel? {
        didSet {
            self.bindChartUpdater?()
        }
    }
    
    // Binding
    var bindChartUpdater: (()->())?
    
    // DP
    init(_ networkManager: ChartNetworkManager = ChartNetworkManager(client: ChartNetworkClient())) {
        self.networkManager = networkManager
    }
    
    func fatchOrgChart() {
        self.networkManager.requestOrgChart({ result in
            switch result {
            case .success(let chartData):
                self.chartData = chartData
                
            case .failure(let error):
                // complete?(.failure(error))
                // show error message
                print(error.debugDescription)
            }
        })
    }
}
