//
//  NTDownloadDelegate.swift
//
//  Created by ntian on 2017/7/8.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

@objc public protocol NTDownloadManagerDelegate: NSObjectProtocol {
  
    /// A delegate method called when add new downlaod task
    @objc optional func addDownloadRequest(downloadTask: NTDownloadTask)
    /// A delegate method called each time whenever download task is start
    @objc optional func downloadRequestDidStarted(downloadTask: NTDownloadTask)
    /// A delegate method called each time whenever download task is paused
    @objc optional func downloadRequestDidPaused(downloadTask: NTDownloadTask)
    /// A delegate method called each time whenever any download task's progress is updated
    @objc optional func downloadRequestUpdateProgress(downloadTask: NTDownloadTask)
    /// A delegate method called each time whenever any download task is finished
    @objc optional func downloadRequestFinished(downloadTask: NTDownloadTask)
    /// A delegate method called each time whenever any download task is failed
    @objc optional func downloadRequestDidFailedWithError(error: Error, downloadTask: NTDownloadTask)
}
