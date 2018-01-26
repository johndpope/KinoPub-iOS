//
//  NTCommonHelper.swift
//
//  Created by ntian on 2017/7/12.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit

public let NTDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

open class NTCommonHelper {

    open class func calculateFileSize(_ contentLength: Int64) -> Float {
        let dataLength: Float64 = Float64(contentLength)
        if dataLength >= (1024.0 * 1024.0 * 1024.0) {
            return Float(dataLength / (1024.0 * 1024.0 * 1024.0))
        } else if dataLength >= 1024.0 * 1024.0 {
            return Float(dataLength / (1024.0 * 1024.0))
        } else if dataLength >= 1024.0 {
            return Float(dataLength / 1024.0)
        } else {
            return Float(dataLength)
        }
    }
    open class func calculateUnit(_ contentLength: Int64) -> String {
        if (contentLength >= (1024 * 1024 * 1024)) {
            return "GB"
        } else if contentLength >= (1024 * 1024) {
            return "MB"
        } else if contentLength >= 1024 {
            return "KB"
        } else {
            return "Bytes"
        }
    }
}
