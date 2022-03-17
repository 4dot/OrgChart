//
//  NetworkClient.swift
//  TheMartianTimes
//
//  Created by Chanick on 6/11/21.
//  Copyright (c) 2021 Chanick Park. All rights reserved.
//

import Foundation


//
// Protocol NetworkClient
//
protocol NetworkClient {
    var basePath: String { get }
    func request(method: HttpMethod, path: String, parameters: [String : Any]?, httpBody: Data?, complete: @escaping (NetworkClientResult<Data>) -> Void)
    func request<T: Codable>(method: HttpMethod, path: String, parameters: [String : Any]?, httpBody: Data?, complete: @escaping (NetworkClientResult<T>) -> Void)
    func request<T: Codable>(method: HttpMethod, path: String, parameters: [String : Any]?, httpBody: Data?, keyPath: String?, complete: @escaping (NetworkClientResult<T>) -> Void)
}

// Network Client Result
enum NetworkClientResult<Type> {
    case success(Type)
    // array of error messages
    case failure([String])
}
