//
//  ChartNetworkManager.swift
//  TheMartianTimesTests
//
//  Created by Chanick on 7/18/21.
//

import Foundation

//
// ChartNetworkManager
//
typealias ChartCompletionBlock = (NetworkClientResult<OrgChartModel>) -> (Void)

struct ChartNetworkManager: NetworkManager {
    var client: NetworkClient
    var relativePath: String
    
    
    
    init(client: NetworkClient) {
        self.client = client
        self.relativePath = ""
    }
    
    /**
     * @desc Request article List from local Json file
     */
    func requestOrgChart(_ complete: ChartCompletionBlock?) {
        DispatchQueue.global(qos: .default).async {
            client.request(method: .get, path: path, parameters: nil, httpBody: nil, complete: { (result: NetworkClientResult<OrgChartModel>) in
                complete?(result)
            })
        }
    }
}

