//
//  Dictionary+KPAdditions.swift
//  KinoPub
//
//  Created by Евгений Дац on 26.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func swap(_ key1: Key, _ key2: Key) {
        if  let value = self[key1], let existingValue = self[key2] {
            self[key1] = existingValue
            self[key2] = value
        }
    }
    public var toString: String {
        var value = ""
        for (_, item) in self {
            if value != "" {
                value += "-"
            }
            value += item as! String
        }
        return value
    }
    mutating func unionInPlace(_ dictionary: Dictionary) {
        for (key,value) in dictionary {
            self.updateValue(value, forKey:key)
        }
    }
}
