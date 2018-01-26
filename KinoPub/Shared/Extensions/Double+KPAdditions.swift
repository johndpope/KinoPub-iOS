//
//  Double+KPAdditions.swift
//  KinoPub
//
//  Created by Евгений Дац on 26.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import Foundation

extension Double {
    var formattedTime: String {
        var formattedTime = "0:00"
        if self > 0 {
            let hours = Int(self / 3600)
            let minutes = Int(truncatingRemainder(dividingBy: 3600) / 60)
            formattedTime = String(hours) + ":" + (minutes < 10 ? "0" + String(minutes) : String(minutes))
        }
        return formattedTime
    }
    
    var kmFormatted: String {
        
        if self >= 10000, self <= 999999 {
            return String(format: "%.1fk", locale: Locale.current,self/1000).replacingOccurrences(of: ".0", with: "")
        }
        
        if self > 999999 {
            return String(format: "%.1fm", locale: Locale.current,self/1000000).replacingOccurrences(of: ".0", with: "")
        }
        
        return String(format: "%.0f", locale: Locale.current,self)
    }
}

extension TimeInterval {
    func timeIntervalAsString(_ format: String = "dd days, hh hours, mm minutes, ss seconds, sss ms") -> String {
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        let ms = Int(self.truncatingRemainder(dividingBy: 1) * (ago ? -1000 : 1000))
        let s = asInt % 60
        let m = (asInt / 60) % 60
        let h = ((asInt / 3600))%24
        let d = (asInt / 86400)
        
        var value = format
        value = value.replacingOccurrences(of: "hh", with: String(format: "%0.2d", h))
        value = value.replacingOccurrences(of: "mm", with: String(format: "%0.2d", m))
        value = value.replacingOccurrences(of: "sss", with: String(format: "%0.3d", ms))
        value = value.replacingOccurrences(of: "ss", with: String(format: "%0.2d", s))
        value = value.replacingOccurrences(of: "dd", with: String(format: "%d", d))
        if (ago) {
            value += " ago"
        }
        return value
    }
}
