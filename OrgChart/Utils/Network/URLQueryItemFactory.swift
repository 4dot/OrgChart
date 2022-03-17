//
//  URLQueryItemFactory.swift
//  TheMartianTimes
//
//  Created by Chanick on 6/10/21.
//  Copyright (c) 2021 Chanick Park. All rights reserved.
//

import Foundation

//
// Query parameters parser helper
//
struct URLQueryItemFactory {
    
    func create(parameters: [String: Any]) -> [URLQueryItem] {
        return parameters.flatMap(queryItems)
    }
    
    /**
     * @desc query parameters parser
     * @return [URLQueryItem]
     */
    private func queryItems(_ key: String, _ value: Any?) -> [URLQueryItem] {
        var result = [URLQueryItem]()
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                result += queryItems("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            let arrayKey = "\(key)[]"
            for value in array {
                result += queryItems(arrayKey, value)
            }
        } else if let _ = value as? NSNull {
            result.append(URLQueryItem(name: key, value: nil))
        } else if let value = value {
            result.append(URLQueryItem(name: key, value: "\(value)"))
        } else {
            result.append(URLQueryItem(name: key, value: nil))
        }
        
        return result
    }
}
