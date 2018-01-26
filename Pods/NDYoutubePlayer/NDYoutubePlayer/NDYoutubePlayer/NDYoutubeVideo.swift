//
//  NDYoutubeVideo.swift
//  NDYoutubeKit
//
//  Created by user on 9/25/17.
//  Copyright © 2017 Den. All rights reserved.
//

import UIKit


public enum NDYouTubeVideoQuality: String {
    /**
     *  Video: 240p MPEG-4 Visual | 0.175 Mbit/s
     *  Audio: AAC | 36 kbit/s
     */
    case NDYouTubeVideoQualitySmall240  = "36"
    
    /**
     *  Video: 360p H.264 | 0.5 Mbit/s
     *  Audio: AAC | 96 kbit/s
     */
    case NDYouTubeVideoQualityMedium360 = "18"
    
    /**
     *  Video: 720p H.264 | 2-3 Mbit/s
     *  Audio: AAC | 192 kbit/s
     */
    case NDYouTubeVideoQualityHD720     = "22"
}

open class NDYoutubeVideo: NSObject {
    
    /**
     *  --------------------------------
     *  @name Accessing video properties
     *  --------------------------------
     */
    
    /**
     *  The 11 characters YouTube video identifier.
     */
    open var identifier: String?
    /**
     *  The title of the video.
     */
    open var title: String?
    /**
     *  The duration of the video in seconds.
     */
    open var duration: TimeInterval?
    
    /**
     *  A thumbnail URL for an image of small size, i.e. 120×90. May be nil.
     */
    open var smallThumbnailURL: URL?
    /**
     *  A thumbnail URL for an image of medium size, i.e. 320×180, 480×360 or 640×480. May be nil.
     */
    open var mediumThumbnailURL: URL?
    /**
     *  A thumbnail URL for an image of large size, i.e. 1'280×720 or 1'980×1'080. May be nil.
     */
    open var largeThumbnailURL: URL?
    
    /**
     *  A dictionary of video stream URLs.
     *
     *  The keys are the YouTube [itag](https://en.wikipedia.org/wiki/YouTube#Quality_and_formats) values as `NSNumber` objects. The values are the video URLs as `NSURL` objects. There is also the special `XCDYouTubeVideoQualityHTTPLiveStreaming` key for live videos.
     *
     *  You should not store the URLs for later use since they have a limited lifetime and are bound to an IP address.
     *
     *  @see XCDYouTubeVideoQuality
     *  @see expirationDate
     */
//    #if __has_feature(objc_generics)
//    @property (nonatomic, readonly) NSDictionary<id, NSURL *> *streamURLs;
//    #else
//    @property (nonatomic, readonly) NSDictionary *streamURLs;
//    #endif
    
    open var streamURLs: [String: Any]?
    
    /**
     *  The expiration date of the video.
     *
     *  After this date, the stream URLs will not be playable. May be nil if it can not be determined, for example in live videos.
     */
    
    var expirationDate: Date?
    
    
    
//    - (instancetype) initWithIdentifier:(NSString *)identifier info:(NSDictionary *)info playerScript:(XCDYouTubePlayerScript *)playerScript response:(NSURLResponse *)response error:(NSError * __autoreleasing *)error
    
    init?(withIndentifier identifier: String, info: [String:AnyObject], response: URLResponse?, playerScript: NDYoutubePlayerScript?, err: inout NDYoutubeRequestError) {
        super.init()
        
        
        let streamMap = info["url_encoded_fmt_stream_map"] as? String
        let httpLiveStream = info["hlsvp"] as? String
        let adaptiveFormats = info["adaptive_fmts"] as? String
        
//        var userInfo = response?.url != nil ? [NSURLErrorKey: response?.url!.absoluteString ] : [:]
        
        
        let streamMapString = streamMap ?? ""
        let httpLiveStreamString = httpLiveStream ?? ""
        
        
        if streamMapString.count > 0 || httpLiveStreamString.count > 0 {
            var streamQueries = streamMapString.components(separatedBy: ",")
            if let adaptiveFormats = adaptiveFormats {
                streamQueries.append(contentsOf: adaptiveFormats.components(separatedBy: ","))
            }
            self.title = info["title"] as? String
            self.duration = info["length_seconds"] as? TimeInterval
            
            let smallThumbnail = info["thumbnail_url"] != nil ? info["thumbnail_url"] as? String : info["iurl"] as? String
            let mediumThumbnail = info["iurlsd"] != nil ? info["iurlsd"] as? String : info["iurlmq"] as? String
            let largeThumbnail = info["iurlmaxres"] as? String
            self.smallThumbnailURL = smallThumbnail != nil ? URL(string: smallThumbnail!) : nil
            self.mediumThumbnailURL = mediumThumbnail != nil ? URL(string: mediumThumbnail!) : nil
            self.largeThumbnailURL = largeThumbnail != nil ? URL(string: largeThumbnail!) : nil
            
            var streamURLs: [String: String] = [:]
            
            for streamQuery in streamQueries {
                let stream = streamQuery.toDictionary()
                let scrambledSignature = stream["s"] as? String
                
                if scrambledSignature != nil && playerScript == nil {
                    err = .NoPlayerScript
                    return nil
                }
                var signature: String? = nil
                if playerScript != nil {
                    signature = playerScript!.unscrambleSignature(scrambledSignature: scrambledSignature)
                }

                if playerScript != nil && scrambledSignature != nil && signature == nil {
                    continue
                }
                let urlString = stream["url"] as? String
                let itag = stream["itag"] as? String
                if let urlString = urlString, let itag = itag {
                    var streamURL = URL(string: urlString)
                    if self.expirationDate == nil {
                        self.expirationDate = self.getExpirationDate(streamURL: streamURL!)
                    }
                    if signature != nil {
                        let escapedSignature = signature!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                        streamURL = self.getURLBySettingParameter(url: streamURL!, key: "signature", percentEncodedValue: escapedSignature!)
                    }
                    streamURLs[itag] = self.getURLBySettingParameter(url: streamURL!, key: "ratebypass", percentEncodedValue: "yes")?.absoluteString
                }
                
            }
            if streamURLs.count == 0 {
                err = NDYoutubeRequestError.CheckNextRequest
                return nil
            }
            self.identifier = identifier
            self.streamURLs = streamURLs
        } else {
            if let reason = info["reason"] as? String {
                var reasonString = reason.replacingOccurrences(of: "<br\\s*/?>", with: " ")
                reasonString = reasonString.replacingOccurrences(of: "\n", with: " ")
                var range = reasonString.range(of: "<[^>]+>")
                while range != nil {
                    reasonString.replaceSubrange(range!, with: "")
                    range = reasonString.range(of: "<[^>]+>")
                }
                let errorCode = Int(info["errorcode"] as! String)
                err = .CouldNotGetInfo(code: errorCode!)
                return nil
            } else {
                if httpLiveStream == nil {
                    err = .NoHttpLiveStream
                }
                return nil
            }
        }

    }
    private func getExpirationDate(streamURL: URL) -> Date? {
        let query = streamURL.query!.toDictionary()
        let expire = query["expire"] as? Double
        if let expire = expire {
            return expire > 0 ? Date(timeIntervalSince1970: expire) : nil
        } else {
            return nil
        }
    }
    
    
    private func getURLBySettingParameter(url: URL, key: String, percentEncodedValue: String) -> URL? {
        let pattern = "((?:^|&)\(key)=)[^&]*"
        let template = "$1\(percentEncodedValue)"
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
            
            
            let percentEncodedQuery: NSMutableString = NSMutableString(string: components!.percentEncodedQuery!)
            
            let numberOfMatches = regularExpression.replaceMatches(in: percentEncodedQuery , options: [], range: NSRange(location: 0, length: percentEncodedQuery.length), withTemplate: template)
            var percentString = percentEncodedQuery as String
            if numberOfMatches == 0 {
                percentString = "\(percentString)\(percentEncodedQuery.length > 0 ? "&" : "")\(key)=\(percentEncodedValue)"
            }
            components!.percentEncodedQuery = percentString
            return components!.url
        } catch {
            return nil
        }
    }
}
