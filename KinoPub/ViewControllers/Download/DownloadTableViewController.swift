import UIKit
import NTDownload
import LKAlertController
import AVFoundation
import InteractiveSideMenu
import NotificationBannerSwift
import Result

class DownloadService {
    private class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
        private var progress: Progress?
        private let progressClosure: (Progress) -> Void
        private let completionClosure: (Result<URL, NSError>) -> Void
        
        init(progress: @escaping (Progress) -> Void, completion: @escaping (Result<URL, NSError>) -> Void) {
            progressClosure = progress
            completionClosure = completion
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            if progress
            let progress = Progress(totalUnitCount: totalBytesExpectedToWrite)
            progress.completedUnitCount = totalBytesWritten
            
            progressClosure(progress)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            completionClosure(Result(value: location))
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let nsError = error as NSError? {
                completionClosure(Result(error: nsError))
            }
            let convertedError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "Cannot convert error"])
            completionClosure(Result(error: convertedError))
        }
    }
    
    private var downloadDelegates: [DownloadDelegate] = []
    var downloads: [URLSessionDownloadTask] = []
    var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "KinoPub"), delegate: nil, delegateQueue: nil)
    
    func add(download: URL, progressClosure: (Progress) -> Void, completionClosure: () -> Void) {
        let task = urlSession.downloadTask(with: download)
        task.resume()
        downloads.append(task)
    }
    
    func remove(download: URL) {
//        downloads.remove
    }
}



class DownloadTableViewController: UITableViewController, SideMenuItemContent {
    enum Section: Int {
        case Downloading
        case Downloaded
        
        static let count = 2
    }
    
    fileprivate let mediaManager = Container.Manager.media
    var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "KinoPub"), delegate: nil, delegateQueue: nil)
    
    //    var progress: Float = 0.0
    var selectedIndexPath : IndexPath!
    
    var downed = [NTDownloadTask]()
    var downing = [NTDownloadTask]()
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        initdata()
        
        //        NTDownloadManager.shared.resumeAllTask()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(initdata), for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.kpOffWhite
    }
    
    func config() {
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
        }
        
        tableView.backgroundColor = .kpBackground
        
        NTDownloadManager.shared.delegate = self
        
        tableView.register(R.nib.downloadingTableViewCell)
        tableView.register(R.nib.downloadedTableViewCell)
        
//        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .kpOffWhiteSeparator
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.kinopubMenu(), style: .plain, target: self, action: #selector(showMenu))
        print(NTDocumentPath)
    }
    
    @objc func initdata() {
        self.downed = NTDownloadManager.shared.finishedList
        self.downing = NTDownloadManager.shared.unFinishedList
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    @objc func showMenu() {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }
    
    func showMoreAction(_ sender: Any) {
        ActionSheet()
            .tint(.kpBlack)
            .addAction("Приостановить все", style: .default) { (_) in
                NTDownloadManager.shared.pauseAllTask()
            }
            .addAction("Запустить все", style: .default) { (_) in
                NTDownloadManager.shared.resumeAllTask()
            }
            .addAction("Удалить все", style: .destructive) { (_) in
                self.removeAllTask()
            }
            .addAction("Отменить", style: .cancel)
            .setBarButtonItem(sender as! UIBarButtonItem)
            .show()
    }
    
    func removeAllTask() {
        Alert(message: "Удалить все загрузки?")
            .tint(.kpBlack)
            .addAction("Да", style: .destructive) { (_) in
                NTDownloadManager.shared.removeAllTask()
                self.initdata()
            }
            .addAction("Нет", style: .cancel)
            .show()
    }
    
    @IBAction func showMoreMenu(_ sender: Any) {
        showMoreAction(sender)
    }
}

// MARK: UITableViewDatasource Handler Extension
extension DownloadTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downing.count == 0, downed.count == 0 {
            Helper.empty(message: "Здесь будут ваши локальные файлы", viewController: self)
            moreButton.isEnabled = false
        } else {
            tableView.backgroundView = nil
            moreButton.isEnabled = true
        }
        
        switch Section(rawValue: section) {
        case .some(.Downloaded):
            return downed.count
        case .some(.Downloading):
            return downing.count
        default:
            preconditionFailure("Unexpected section")
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.downloadingTableViewCell, for: indexPath)!
            cell.fileInfo = downing[indexPath.row]
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.downloadedTableViewCell, for: indexPath)!
            cell.fileInfo = downed[indexPath.row]
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return downing.count > 0 ? "ЗАГРУЖАЕТСЯ" : nil
        case 1:
            return downed.count > 0 ? "ЗАГРУЖЕНО" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.kpBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.kpGreyishBrown
        header.textLabel?.font = header.textLabel?.font.withSize(12)
    }
    
}

// MARK: UITableViewDelegate Handler Extension

extension DownloadTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if indexPath.section == 0 {
            playPauseTask(at: indexPath)
        }
        if indexPath.section == 1 {
            openInPlayer()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Удалить") { (_, indexPath) in
                NTDownloadManager.shared.removeTask(downloadTask: self.downed[indexPath.row])
                self.downed.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            let share = UITableViewRowAction(style: .default, title: "Поделиться", handler: { (action, indexPath) in
                let fileUrl = URL(fileURLWithPath: "\(NTDocumentPath)/\(self.downed[indexPath.row].fileName)")
                //                let str = self.downed[indexPath.row].fileName
                
                let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: indexPath)
                self.present(activityViewController, animated: true, completion: nil)
            })
            
            delete.backgroundColor = .kpGreyishTwo
            share.backgroundColor = .kpMarigold
            
            return [delete, share]
        } else if indexPath.section == 0 {
            let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Удалить") { (_, indexPath) in
                NTDownloadManager.shared.removeTask(downloadTask: self.downing[indexPath.row])
                self.downing.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            delete.backgroundColor = .kpGreyishTwo
            return [delete]
        } else {
            return nil
        }
    }
    
}

extension DownloadTableViewController {
    func showActionController(at indexPath: IndexPath) {
        let action = ActionSheet().tint(.kpBlack)
        
        if downing[selectedIndexPath.row].status == .NTDownloading {
            action.addAction("Пауза", style: .default, handler: { (_) in
                NTDownloadManager.shared.pauseTask(downloadTask: self.downing[self.selectedIndexPath.row])
            })
        }
        if downing[selectedIndexPath.row].status == .NTPauseDownload {
            action.addAction("Продолжить", style: .default, handler: { (_) in
                NTDownloadManager.shared.resumeTask(downloadTask: self.downing[self.selectedIndexPath.row])
            })
        }
        action.addAction("Удалить", style: .destructive) { (_) in
            self.showConfirmAlert()
        }
        action.addAction("Отмена", style: .cancel)
        action.setPresentingSource(tableView.cellForRow(at: indexPath)!)
        action.show()
    }
    
    func playPauseTask(at indexPath: IndexPath) {
        if downing[indexPath.row].status == .NTDownloading {
            NTDownloadManager.shared.pauseTask(downloadTask: downing[indexPath.row])
        } else if downing[indexPath.row].status == .NTPauseDownload {
            NTDownloadManager.shared.resumeTask(downloadTask: downing[indexPath.row])
        }
    }
    
    func showConfirmAlert() {
        Alert(message: "Удалить?")
            .tint(.kpBlack)
            .addAction("Да", style: .destructive) { (_) in
                NTDownloadManager.shared.removeTask(downloadTask: self.downing[self.selectedIndexPath.row])
                self.downing.remove(at: self.selectedIndexPath.row)
                self.tableView.deleteRows(at: [self.selectedIndexPath], with: .fade)
            }
            .addAction("Нет", style: .cancel)
            .show()
    }
    
    func openInPlayer() {
        var mediaItem = MediaItem()
        mediaItem.url = URL(fileURLWithPath: "\(NTDocumentPath)/\(self.downed[selectedIndexPath.row].fileName)")
        mediaItem.title = downed[selectedIndexPath.row].fileName.replacingOccurrences(of: ".mp4", with: "").replacingOccurrences(of: ";", with: "").replacingOccurrences(of: ".", with: " ")
        mediaManager.playVideo(mediaItems: [mediaItem], userinfo: nil)
    }
}

// MARK: - NTDownloadManagerDelegate

extension DownloadTableViewController: NTDownloadManagerDelegate {
    func downloadRequestFinished(downloadTask: NTDownloadTask) {
        let title = downloadTask.fileName.replacingOccurrences(of: ".mp4", with: "").replacingOccurrences(of: ";", with: "").replacingOccurrences(of: ".", with: " ")
        let banner = NotificationBanner(title: "Завершено", subtitle: "\(title) успешно загружен", style: .success)
        banner.duration = 3
        banner.show(queuePosition: .front)
        initdata()
    }
    
    func addDownloadRequest(downloadTask: NTDownloadTask) {
        initdata()
    }
    
    func downloadRequestUpdateProgress(downloadTask: NTDownloadTask) {
        let cellArr = self.tableView.visibleCells
        for obj in cellArr {
            if obj.isKind(of: DownloadingTableViewCell.self) {
                let cell = obj as! DownloadingTableViewCell
                if cell.fileInfo?.fileURL == downloadTask.fileURL {
                    cell.fileInfo = downloadTask
                }
            }
        }
    }
    
    func downloadRequestDidFailedWithError(error: Error, downloadTask: NTDownloadTask) {
        let title = downloadTask.fileName.replacingOccurrences(of: ".mp4", with: "").replacingOccurrences(of: ";", with: "").replacingOccurrences(of: ".", with: " ")
        Alert(title: "Ошибка", message: "При загрузке \(title) произошла ошибка: \(error.localizedDescription)")
            .showOkay()
        initdata()
    }
    
    func downloadRequestDidPaused(downloadTask: NTDownloadTask) {
        let cellArr = self.tableView.visibleCells
        for obj in cellArr {
            if obj.isKind(of: DownloadingTableViewCell.self) {
                let cell = obj as! DownloadingTableViewCell
                if cell.fileInfo?.fileURL == downloadTask.fileURL {
                    cell.changeIcon()
                }
            }
        }
    }
    
    func downloadRequestDidStarted(downloadTask: NTDownloadTask) {
        let cellArr = self.tableView.visibleCells
        for obj in cellArr {
            if obj.isKind(of: DownloadingTableViewCell.self) {
                let cell = obj as! DownloadingTableViewCell
                if cell.fileInfo?.fileURL == downloadTask.fileURL {
                    cell.changeIcon()
                }
            }
        }
    }
}
