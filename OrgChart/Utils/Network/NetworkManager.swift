//
//  NetworkManager.swift
//  TheMartianTimes
//
//  Created by Chanick on 6/11/21.
//  Copyright (c) 2021 Chanick Park. All rights reserved.
//

import Foundation

//
// NetworkManager protocol
//
protocol NetworkManager {
    var client: NetworkClient { get }
    var relativePath: String { get }
    var path: String { get }
}

extension NetworkManager {
    var path: String {
        return "\(client.basePath)\(relativePath)"
    }
}
