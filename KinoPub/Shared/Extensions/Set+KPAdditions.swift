//
//  Set+KPAdditions.swift
//  KinoPub
//
//  Created by Евгений Дац on 26.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import Foundation

extension Set {
    public var toString: String {
        var value = ""
        for item in self {
            if value != "" {
                value += ","
            }
            value += item.hashValue.string
        }
        return value
    }
}
