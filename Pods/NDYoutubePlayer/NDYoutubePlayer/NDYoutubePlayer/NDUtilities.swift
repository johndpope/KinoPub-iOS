//
//  Utilities.swift
//  NDYoutubeKit
//
//  Created by user on 9/25/17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation


extension Dictionary {
    func toStringParameters() -> String {
        
        func escape(_ string: String) -> String {
            // Reserved characters defined by RFC 3986
            // Reference: https://www.ietf.org/rfc/rfc3986.txt
            let generalDelimiters = ":#[]@"
            let subDelimiters = "!$&'()*+,;="
            let reservedCharacters = generalDelimiters + subDelimiters
            
            var allowedCharacterSet = CharacterSet()
            allowedCharacterSet.formUnion(.urlQueryAllowed)
            allowedCharacterSet.remove(charactersIn: reservedCharacters)
            
            // Crashes due to internal bug in iOS 7 ~ iOS 8.2.
            // References:
            //   - https://github.com/Alamofire/Alamofire/issues/206
            //   - https://github.com/AFNetworking/AFNetworking/issues/3028
            // return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
            
            let batchSize = 50
            var index = string.startIndex
            
            var escaped = ""
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let substring = String(string[startIndex..<endIndex])
                
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                
                index = endIndex
            }
            
            return escaped
        }
        
        let pairs = self.map { key, value -> String in
            if value is NSNull {
                return "\(escape(key as! String))"
            }
            
            let valueAsString = (value as? String) ?? "\(value)"
            return "\(escape(key as! String ))=\(escape(valueAsString))"
        }
        
        return pairs.joined(separator: "&")
    }
}


extension String {
    func toDictionary() -> [String: AnyObject] {
        var dictionary :[String: AnyObject] = [:]
        let fields =  self.components(separatedBy: "&")
        for field in fields {
            let pair = field.components(separatedBy: "=")
            if pair.count == 2 {
                let key = pair[0]
                var value = pair[1].removingPercentEncoding!
                value = value.replacingOccurrences(of: "+", with: "=")
                if (dictionary[key] != nil) {
                    debugPrint("Using toDictionary is inappropriate because the query string has multiple values for the key")
                }
                dictionary[key] = value as AnyObject
            }
        }
        return dictionary
    }
}
