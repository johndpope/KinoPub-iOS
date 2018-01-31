//
//  NDYoutubeVideoWebPage.swift
//  NDYoutubeKit
//
//  Created by Den on 9/26/17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation
import UIKit

class NDYoutubeVideoWebPage {

    
    var playerConfiguration: [String: AnyObject]?
    
    var videoInfo: [String: AnyObject]?
    var javaScriptPlayerURL: URL?
    var isAgeRestricted: Bool?
    var regionsAllowed: Set<String>?
    var html: String!
    
    init(html: String) {
        self.html = html
    }
    
    func getPlayerConfiguration() -> [String: AnyObject]? {
        if let playerConfiguration = playerConfiguration {
            return playerConfiguration
        } else {
            do {
                let playerConfigRegularExpression = try NSRegularExpression(pattern: "ytplayer.config\\s*=\\s*(\\{.*?\\});|[\\({]\\s*'PLAYER_CONFIG'[,:]\\s*(\\{.*?\\})\\s*(?:,'|\\))", options: NSRegularExpression.Options.caseInsensitive)
                
                let resultArray = playerConfigRegularExpression.matches(in: self.html, options: [], range: NSRange(location: 0, length: self.html.count))
                var dic: [String: AnyObject]?
                for result in resultArray {
                    for index in 1..<result.numberOfRanges {
                        let range = result.range(at: index)
                        if range.length == 0 {
                            continue
                        }
                        let configString = (self.html as NSString).substring(with: range)
                        let configData = configString.data(using:.utf8)
                        do {
                            let playerConfiguration = try JSONSerialization.jsonObject(with: configData!, options: []) as? [String: AnyObject]
                            dic = playerConfiguration
                        } catch {
                            continue
                        }
                    }
                }
                self.playerConfiguration = dic
                return self.playerConfiguration
            } catch {
                return nil
            }
        }
    }
    
    func getVideoInfo() -> [String: AnyObject]? {
        if let videoInfo = self.videoInfo {
            return videoInfo
        } else {
            if let playerConfiguration = self.getPlayerConfiguration() {
                if let args = playerConfiguration["args"] as? [String: AnyObject] {
//                    let info = args.filter({ (arg) -> Bool in
//                        let (_, value) = arg
//                        return value is NSNumber
//                    })
                    videoInfo = args
                    return videoInfo
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    func getJavaScriptPlayerURL() -> URL? {
        if let javaScriptPlayerURL = self.javaScriptPlayerURL {
           return javaScriptPlayerURL
        } else {
            if let playerConfiguration = self.getPlayerConfiguration() {
                var javaScriptPlayerURLString = ""
                if let jsAssets = playerConfiguration["assets"]!["js"] as? String {
                    if jsAssets.hasPrefix("//") {
                        javaScriptPlayerURLString = "https:\(jsAssets)"
                    } else if jsAssets.hasPrefix("/")  {
                        javaScriptPlayerURLString = "https://www.youtube.com\(jsAssets)"
                    }
                    self.javaScriptPlayerURL = URL(string: javaScriptPlayerURLString)
                   return self.javaScriptPlayerURL
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    func getIsAgeRestricted() -> Bool {
        if let isAgeRestricted = self.isAgeRestricted {
            return isAgeRestricted
        } else {
            self.isAgeRestricted = false
            let rangeString = self.html.range(of: "og:restrictions:age")
            if rangeString != nil {
                self.isAgeRestricted = true
            }
            return self.isAgeRestricted!
        }
    }
    
        
    func getRegionsAllowed() -> Set<String>? {
        if let regionsAllowed = self.regionsAllowed {
            return regionsAllowed
        } else {
            do {
                let regionsAllowedRegularExpression = try NSRegularExpression(pattern: "meta\\s+itemprop=\"regionsAllowed\"\\s+content=\"(.*)\"", options: [])
                let regionsAllowedResult = regionsAllowedRegularExpression.firstMatch(in: self.html, options: [], range: NSRange(location: 0, length: self.html.count))
                if let regionsAllowedResult = regionsAllowedResult {
                    if regionsAllowedResult.numberOfRanges > 1 {
                        let regionsAllowed = (self.html as NSString).substring(with: regionsAllowedResult.range(at: 1))
                        if regionsAllowed.count > 0 {
                            let array = regionsAllowed.components(separatedBy: ",")
                            self.regionsAllowed = Set(array)
                            return Set(array)
                        }
                    }
                    return nil
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
    }
}

    

