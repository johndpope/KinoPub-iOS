//
//  NTDownloadTask.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

public typealias size = (size: Float, unit: String)

public enum NTDownloadStatus: Int {
    
    case NTDownloading
    case NTPauseDownload
    case NTFinishedDownload
    case NTFailed
    case NTUnknown
    
    var status: NTDownloadStatus {
        switch self.rawValue {
        case 0:
            return .NTDownloading
        case 1, 2:
            return .NTPauseDownload
        case 3:
            return .NTFinishedDownload
        case 4:
            return .NTFailed
        default:
            return .NTUnknown
        }
    }
}
open class NTDownloadTask: NSObject {

    open var fileURL: URL
    open var fileName: String
    open var fileImage: String?
    open var status: NTDownloadStatus? {
        didSet {
            if status == .NTFinishedDownload {
                destinationPath = "\(NTDocumentPath)/\(self.fileName)"
            }
        }
    }
    open var downloadedFileSize: size?
    open var fileSize: size?
    open var progress: Float = 0
    open var task: URLSessionDownloadTask?
    private(set) var destinationPath: String?
    
    init(fileURL: URL, fileName: String, fileImage: String? = nil) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.fileImage = fileImage
    }
}
