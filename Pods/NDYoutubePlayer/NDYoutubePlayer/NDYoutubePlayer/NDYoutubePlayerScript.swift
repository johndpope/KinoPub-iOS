//
//  NDYoutubePlayerScript.swift
//  NDYoutubeKit
//
//  Created by Den on 9/25/17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation
import JavaScriptCore

class NDYoutubePlayerScript: NSObject {
    
    fileprivate var context: JSContext?
    fileprivate var signatureFunction: JSValue?
    
    init(withString string: String) {
        super.init()
        
        self.context = JSContext()
        self.context!.exceptionHandler = { (context, value) in
            debugPrint("JavaScript exception: \(String(describing: value?.context.description))")
        }
        let environment: NSDictionary = [
            "document" : [
                "documentElement" : [:]
            ],
            "location": [
                "hash": ""
            ],
            "navigator": [
                "userAgent" : ""
            ]
        ]
        self.context!.setObject([:], forKeyedSubscript: "window" as NSCopying & NSObjectProtocol)
        
        for propertyName in environment {
            let value = JSValue(object: environment[propertyName.key as! String], in: context!)
            context!.setObject(value!, forKeyedSubscript: propertyName.key as! String as NSCopying & NSObjectProtocol)
            context!.objectForKeyedSubscript("window").setObject(value, forKeyedSubscript: propertyName.key as! String as NSCopying & NSObjectProtocol)
        }

        let script = (string as NSString).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.context!.evaluateScript(script)
        
//        NSRegularExpression *anonymousFunctionRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\(function\\(([^)]*)\\)\\{(.*)\\}\\)\\(([^)]*)\\)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        do {
            
            let anonymousFunctionRegularExpression = try NSRegularExpression(pattern: "\\(function\\(([^)]*)\\)\\{(.*)\\}\\)\\(([^)]*)\\)", options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let anonymousFunctionResult = anonymousFunctionRegularExpression.firstMatch(in: script, options: [], range: NSRange(location: 0, length: script.count))
            if let anonymousFunctionResult = anonymousFunctionResult {
                if anonymousFunctionResult.numberOfRanges > 3 {
                    let parameters = (script as NSString).substring(with: anonymousFunctionResult.range(at: 1)).components(separatedBy: ",")
                    let arguments = (script as NSString).substring(with: anonymousFunctionResult.range(at: 3)).components(separatedBy: ",")
                    if parameters.count == arguments.count {
                        for index in 0..<parameters.count {
                            context!.setObject(self.context!.objectForKeyedSubscript(arguments[index]), forKeyedSubscript: parameters[index] as NSCopying & NSObjectProtocol)

                        }
                        let anonymousFunctionBody = (script as NSString).substring(with: anonymousFunctionResult.range(at: 2))
                        context!.evaluateScript(anonymousFunctionBody)
                    }
                }
                let signatureRegularExpression = try NSRegularExpression(pattern: "[\"']signature[\"']\\s*,\\s*([^\\(]+)", options: NSRegularExpression.Options.caseInsensitive)
                
                let result = signatureRegularExpression.matches(in: script, options: [], range: NSRange(location: 0, length: script.count))
                for signatureResult in result {
                    let signatureFunctionName = signatureResult.numberOfRanges > 1 ? (script as NSString).substring(with: signatureResult.range(at: 1)) : nil
                    if signatureFunctionName == nil {
                        continue
                    }
                    let signatureFunction = self.context!.objectForKeyedSubscript(signatureFunctionName)
                    if signatureFunction!.isObject {
                        self.signatureFunction = signatureFunction
                        break
                    }
                }
            }
        } catch {
            
        }
    }

    func unscrambleSignature(scrambledSignature: String?) -> String? {
        if self.signatureFunction == nil || scrambledSignature == nil {
            return nil
        }
        let unscrambledSignature = self.signatureFunction!.call(withArguments: [scrambledSignature ?? ""])
        return (unscrambledSignature?.isString)! ? unscrambledSignature!.toString() : nil
    }
}
