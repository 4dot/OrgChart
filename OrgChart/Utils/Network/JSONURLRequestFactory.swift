//
//  JSONURLRequestFactory.swift
//  TheMartianTimes
//
//  Created by Chanick on 6/11/21.
//  Copyright (c) 2021 Chanick Park. All rights reserved.
//

import Foundation


enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum JSONURLRequestFactoryError: Error {
    case invalidUrl
}

//
// JSONURLRequestFactory
//
struct JSONURLRequestFactory {
    /**
     * @desc Create URL request for Json
     * @return URLRequest
     */
    func create(url: URL, httpMethod: HttpMethod, parameters: [String: Any]? = nil, httpBody: Data? = nil, httpHeaders: [String: String]? = nil) throws -> URLRequest {
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let parameters = parameters {
            components?.queryItems = URLQueryItemFactory().create(parameters: parameters)
        }
        
        guard let componentsUrl = components?.url else {
            throw JSONURLRequestFactoryError.invalidUrl
        }
        
        // Create URL request
        var request = URLRequest(url: componentsUrl)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        request.allHTTPHeaderFields?.add(dictionary: jsonHeaders)
        
        // Add Http Header Info
        if let httpHeaders = httpHeaders {
            request.allHTTPHeaderFields?.add(dictionary: httpHeaders)
        }
        
        return request
    }
    
    // Http Header field (Json)
    private let jsonHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
}
