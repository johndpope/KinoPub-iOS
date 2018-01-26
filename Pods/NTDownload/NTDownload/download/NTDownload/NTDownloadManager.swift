//
//  NTDownloadManager.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit

open class NTDownloadManager: URLSessionDownloadTask {
    
    open static let shared = NTDownloadManager()
    open weak var delegate: NTDownloadManagerDelegate?
    
    open var unFinishedList: [NTDownloadTask] {
        return taskList.filter { $0.status != .NTFinishedDownload }
    }
    open var finishedList: [NTDownloadTask] {
        return taskList.filter { $0.status == .NTFinishedDownload }
    }
    
    private lazy var taskList = [NTDownloadTask]()
    private let configuration = URLSessionConfiguration.background(withIdentifier: "NTDownload")
    private var session: URLSession!
    private let plistPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/NTDownload.plist"
    
    override init() {
        super.init()
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        self.loadTaskList()
//        debugPrint(plistPath)
    }
    public func addDownloadTask(urlString: String, fileName: String? = nil, fileImage: String? = nil) {

        let url = URL(string: urlString)!
        for task in taskList {
            if task.fileURL == url {
                return
            }
        }
        let request = URLRequest(url: url)
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()
        let status = NTDownloadStatus(rawValue: downloadTask.state.rawValue)!.status
        let fileName = fileName ?? (url.absoluteString as NSString).lastPathComponent
        let task = NTDownloadTask(fileURL: url, fileName: fileName,  fileImage: fileImage)
        task.status = status
        task.task = downloadTask
        self.taskList.append(task)
        delegate?.addDownloadRequest?(downloadTask: task)
        self.saveTaskList()
    }
    
    public func pauseTask(downloadTask: NTDownloadTask) {
        if downloadTask.status != .NTDownloading {
            return
        }
        var task = downloadTask.task
        if task == nil {
            task = session.downloadTask(with: downloadTask.fileURL)
            downloadTask.task = task
        }
        task?.suspend()
        downloadTask.status = NTDownloadStatus(rawValue: (task?.state.rawValue)!)!.status
        delegate?.downloadRequestDidPaused?(downloadTask: downloadTask)
    }

    public func resumeTask(downloadTask: NTDownloadTask) {
        if downloadTask.status != .NTPauseDownload {
            return
        }
        var task = downloadTask.task
        if task == nil {
            task = session.downloadTask(with: downloadTask.fileURL)
            downloadTask.task = task
        }
        task?.resume()
        downloadTask.status = NTDownloadStatus(rawValue: (task?.state.rawValue)!)!.status
        delegate?.downloadRequestDidStarted?(downloadTask: downloadTask)
    }

    public func resumeAllTask() {
        for task in unFinishedList {
            resumeTask(downloadTask: task)
        }
    }

    public func pauseAllTask() {
        for task in unFinishedList {
            pauseTask(downloadTask: task)
        }
    }

    public func removeTask(downloadTask: NTDownloadTask) {
        for (index, task) in taskList.enumerated() {
            if task.fileURL == downloadTask.fileURL {
                if downloadTask.status == .NTFinishedDownload {
                    try? FileManager.default.removeItem(atPath: downloadTask.destinationPath!)
                } else {
                    downloadTask.task?.cancel()
                }
                taskList.remove(at: index)
                saveTaskList()
                break
            }
        }
    }
    public func removeAllTask() {
        for task in taskList {
            removeTask(downloadTask: task)
        }
    }
    public func clearTmp() {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@/%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
// MARK: - Private Function
private extension NTDownloadManager {
    func saveTaskList() {
        let jsonArray = NSMutableArray()
        for task in taskList {
            let jsonItem = NSMutableDictionary()
            jsonItem["fileURL"] = task.fileURL.absoluteString
            jsonItem["fileName"] = task.fileName
            jsonItem["fileImage"] = task.fileImage
            if task.status == .NTFinishedDownload {
                jsonItem["statusCode"] = NTDownloadStatus.NTFinishedDownload.rawValue
                jsonItem["fileSize.size"] = task.fileSize?.size
                jsonItem["fileSize.unit"] = task.fileSize?.unit
            }
            jsonArray.add(jsonItem)
        }
        jsonArray.write(toFile: plistPath, atomically: true)
    }
    func loadTaskList() {
        guard let jsonArray = NSArray(contentsOfFile: plistPath) else {
            return
        }
        for jsonItem in jsonArray {
            guard let item = jsonItem as? NSDictionary, let fileName = item["fileName"] as? String, let urlString = item["fileURL"] as? String else {
                return
            }
            let fileURL = URL(string: urlString)!
            let fileImage = item["fileImage"] as? String
            let statusCode = item["statusCode"] as? Int
            let task = NTDownloadTask(fileURL: fileURL, fileName: fileName, fileImage: fileImage)
            if let statusCode = statusCode {
                let status = NTDownloadStatus(rawValue: statusCode)
                let fileSize = item["fileSize.size"] as? Float
                let fileSizeUnit = item["fileSize.unit"] as? String
                task.status = status
                task.fileSize = (fileSize, fileSizeUnit) as? (size: Float, unit: String)
            } else {
                task.status = .NTPauseDownload
            }
            self.taskList.append(task)
        }
    }
}
// MARK: - URLSessionDownloadDelegate
extension NTDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let error = error as NSError?
        var downloadTask = task as! URLSessionDownloadTask
        if (error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? Int) == NSURLErrorCancelledReasonUserForceQuitApplication || (error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? Int) == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
            let task = unFinishedList.filter { $0.fileURL == downloadTask.currentRequest?.url || $0.fileURL == downloadTask.originalRequest?.url }.first
            let fileURL = task?.fileURL
            let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            if resumeData == nil {
                downloadTask = session.downloadTask(with: fileURL!)
            } else {
                downloadTask = session.downloadTask(withResumeData: resumeData!)
            }
            task?.status = NTDownloadStatus(rawValue: downloadTask.state.rawValue)!.status
            task?.task = downloadTask
        } else {
            for task in unFinishedList {
                if downloadTask.isEqual(task.task) {
                    if error != nil {
                        task.status = .NTFailed
                        task.fileSize = nil
                        task.downloadedFileSize = nil
                        delegate?.downloadRequestDidFailedWithError?(error: error!, downloadTask: task)
                    }
                }
            }
        }
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for task in unFinishedList {
            if downloadTask.isEqual(task.task) {
                task.status = .NTFinishedDownload
                let destUrl = documentUrl.appendingPathComponent(task.fileName)
                do {
                    try FileManager.default.moveItem(at: location, to: destUrl)
                    delegate?.downloadRequestFinished?(downloadTask: task)
                } catch {
                    delegate?.downloadRequestDidFailedWithError?(error: error, downloadTask: task)
                }
            }
        }
        saveTaskList()
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for task in unFinishedList {
            if downloadTask.isEqual(task.task) {
                task.fileSize = (NTCommonHelper.calculateFileSize(totalBytesExpectedToWrite), NTCommonHelper.calculateUnit(totalBytesExpectedToWrite))
                task.downloadedFileSize = (NTCommonHelper.calculateFileSize(totalBytesWritten),NTCommonHelper.calculateUnit(totalBytesWritten))
                task.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                delegate?.downloadRequestUpdateProgress?(downloadTask: task)
            }
        }
    }
}

