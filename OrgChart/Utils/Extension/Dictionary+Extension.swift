//
//  Dictionary+Extension.swift
//  TheMartianTimes
//
//  Created by Park, Chanick on 6/11/21.
//  Copyright © 2021 Chanick Park. All rights reserved.
//

import Foundation


extension Dictionary {
    /**
     * @desc Update value in Immutable dictionary
     * @param [Key:Value]
     */
    mutating func add(dictionary: [Key: Value]) {
        dictionary.forEach { (key, value) in
            self.updateValue(value, forKey: key)
        }
    }
}
