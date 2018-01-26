//
//  NDYoutubeClient.swift
//  NDYoutubeKit
//
//  Created by user on 9/25/17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation


//typedef NS_ENUM(NSUInteger, XCDYouTubeRequestType) {
//    XCDYouTubeRequestTypeGetVideoInfo = 1,
//    XCDYouTubeRequestTypeWatchPage,
//    XCDYouTubeRequestTypeEmbedPage,
//    XCDYouTubeRequestTypeJavaScriptPlayer,
//};
enum NDYouTubeRequestType: Int {
    case NDYouTubeRequestTypeGetVideoInfo = 1
    case NDYouTubeRequestTypeWatchPage
    case NDYouTubeRequestTypeEmbedPage
    case NDYouTubeRequestTypeJavaScriptPlayer
}

enum NDYoutubeRequestError: Error {
    case NonError
    case CouldNotGetInfo(code: Int)
    case NoHttpLiveStream
    case NoPlayerScript
    case CantGetVideo
    case CheckNextRequest
}


let yotubeURL = "https://www.youtube.com"

open class NDYoutubeClient {
    open static let shared: NDYoutubeClient = NDYoutubeClient()
    fileprivate var languageIdentifier: String?
    fileprivate var eventLabels: [String] = []
    fileprivate var requestType: NDYouTubeRequestType!
    fileprivate var indentifier: String!
    
    fileprivate var playerScript: NDYoutubePlayerScript?
    fileprivate var embedWebpage: NDYoutubeVideoWebPage?
    fileprivate var webpage: NDYoutubeVideoWebPage?
    
    
    var getVideoQueue = DispatchQueue(label: "com.ndyoutube.nghia")
    
    
    let operationQueue = OperationQueue()
    var completionHandler: ((_ video: NDYoutubeVideo?, _ error: Error) -> Void)!
    
    fileprivate var dataTask = URLSessionDataTask()
    fileprivate let session = URLSession(configuration: .ephemeral)
    
    public init() {
        
    }
    
    open func getVideoWithIdentifier(videoIdentifier: String, completionHandler: @escaping ((_ video: NDYoutubeVideo?, _ error: Error) -> Void)) {
        self.operationQueue.cancelAllOperations()
        self.operationQueue.addOperation {
            self.start(indentifier: videoIdentifier, completionHandler: completionHandler)
        }
    }
    
    fileprivate func start(indentifier: String, completionHandler: @escaping ((_ video: NDYoutubeVideo?, _ error: Error) -> Void) ) {
        self.indentifier = indentifier
        eventLabels = ["embedded","detailpage"]
        self.completionHandler = completionHandler
        self.startGetVideo(withIndentifier: indentifier)
    }
    
    /**
     * Start Get Video
     */
    
    fileprivate func startGetVideo(withIndentifier indentifier: String) {
        if eventLabels.count == 0 {
            if self.requestType == NDYouTubeRequestType.NDYouTubeRequestTypeWatchPage || self.webpage != nil {
                completionHandler(nil, NDYoutubeRequestError.CantGetVideo)
            } else {
                self.startWatchPageRequest()
            }
        } else {
            let event = eventLabels[0]
            eventLabels.remove(at: 0)
            self.getVideoInfo(withIndentifier: indentifier, withEvent: event)
        }
    }
    
    /**
     * Get video web info of video
     */
    
    fileprivate func startWatchPageRequest() {
        let query = [
            "v": self.indentifier,
            "hl": "en",
            "has_verified": "1"
            ] as [String : Any]
        let queryString = query.toStringParameters()
        let webpageURL = URL(string: "https://www.youtube.com/watch?\(queryString)")
        let request = URLRequest(url: webpageURL!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
        self.startRequest(withRequest: request, withType: NDYouTubeRequestType.NDYouTubeRequestTypeWatchPage)
    }
    
    
    /**
     * Get video info of this video, we have 2 type of this request, if first request fail, we try to get info from sencond request
     */
    
    private func getVideoInfo(withIndentifier indentifier: String, withEvent event: String) {
        let query = [
            "video_id": indentifier,
            "ps": "default",
            "el": event,
            "hl": "en"
        ]
        
        let querryString = query.toStringParameters()
        let videoInfoURL = URL(string : "\(yotubeURL)/get_video_info?\(querryString)")
        
        let request = URLRequest(url: videoInfoURL!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
        self.startRequest(withRequest: request, withType: NDYouTubeRequestType.NDYouTubeRequestTypeGetVideoInfo)
    }
    
    
    
    /**
     *  start request API
     */
    
    private func startRequest(withRequest request: URLRequest, withType type: NDYouTubeRequestType) {
        self.requestType = type
        dataTask = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                self.completionHandler(nil, error)
            } else if let data = data, let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                self.handleConnectionSuccessWithData(stringData: result, response: response!, requestType: type)
            }
        })
        dataTask.resume()
    }

    private func handleConnectionSuccessWithData(stringData: String, response res: URLResponse, requestType type: NDYouTubeRequestType) {
        switch type {
        case .NDYouTubeRequestTypeGetVideoInfo:
            self.handleVideoInfo(withInfo: stringData.toDictionary(), response: res)
            break
        case .NDYouTubeRequestTypeEmbedPage:
            break
        case .NDYouTubeRequestTypeWatchPage:
            self.handleWebPage(html: stringData)
            break
        case .NDYouTubeRequestTypeJavaScriptPlayer:
            self.handleJavaScriptPlayerWithScript(script: stringData)
            break
        }
    }
}

//MARK: Handle response
extension NDYoutubeClient {
//    - (void) handleVideoInfoResponseWithInfo:(NSDictionary *)info response:(NSURLResponse *)response
    fileprivate func handleVideoInfo(withInfo: [String: AnyObject], response res: URLResponse?) {
        
        var err: NDYoutubeRequestError = .NonError
        let video = NDYoutubeVideo(withIndentifier: self.indentifier, info: withInfo, response: res, playerScript: self.playerScript,  err: &err)
        if let video = video {
            DispatchQueue.main.async {
                self.completionHandler(video, NDYoutubeRequestError.NonError)
            }
        } else {
            switch err {
            case .CouldNotGetInfo(_):
                self.startGetVideo(withIndentifier: self.indentifier)
            case .NonError:
                return
            case .NoHttpLiveStream:
                self.startGetVideo(withIndentifier: self.indentifier)
            case .NoPlayerScript:
                self.startWatchPageRequest()
            case .CantGetVideo:
                break
            case .CheckNextRequest:
                self.startGetVideo(withIndentifier: self.indentifier)
            }
            
        }
    }
    fileprivate func handleWebPage(html: String) {
        self.webpage = NDYoutubeVideoWebPage(html: html)
        if let url = self.webpage?.getJavaScriptPlayerURL() {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
            self.startRequest(withRequest: request, withType: NDYouTubeRequestType.NDYouTubeRequestTypeJavaScriptPlayer)
        } else {
            if self.webpage!.getIsAgeRestricted() {
                let urlString = "https://www.youtube.com/embed/\(self.indentifier!)"
                let url = URL(string: urlString)
                let request = URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
                self.startRequest(withRequest: request, withType: NDYouTubeRequestType.NDYouTubeRequestTypeEmbedPage)
            } else {
                self.completionHandler(nil, NDYoutubeRequestError.CantGetVideo)
            }
        }
        
    }
    
//    - (void) handleJavaScriptPlayerWithScript:(NSString *)script
    func handleJavaScriptPlayerWithScript(script: String) {
        self.playerScript = NDYoutubePlayerScript(withString: script)
        if self.webpage!.getIsAgeRestricted() {
            
        } else {
            if let info = self.webpage?.getVideoInfo() {
                self.handleVideoInfo(withInfo: info, response: nil)
            }
        }
    }

}


