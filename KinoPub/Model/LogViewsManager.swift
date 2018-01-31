import Foundation
import LKAlertController
import NotificationBannerSwift


protocol LogViewsManager: class {
    func addDelegate(delegate: LogViewsManagerDelegate)
    func changeWatchingStatus(id: Int, video: Int?, season: Int, status: Int?)
    func changeMarktime(id: Int, time: TimeInterval, video: Int, season: Int?)
    func changeWatchlist(id: String)
    func changeWatchlistForMovie(id: Int, time: TimeInterval)
}

protocol LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager)
    func didToggledWatchlist(toggled: Bool)
}

extension LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager) {
        
    }
    func didToggledWatchlist(toggled: Bool) {
        
    }
}

class LogViewsManagerImp: LogViewsManager {
    fileprivate let accountManager = Container.Manager.account
    var delegatesStorage = DelegatesStorage()
    let networkingService: LogViewsNetworkingService
    
    
    init() {
        networkingService = LogViewsNetworkingService(requestFactory: accountManager.requestFactory)
    }
    
    func addDelegate(delegate: LogViewsManagerDelegate) {
        delegatesStorage.addDelegate(delegate: delegate as AnyObject)
    }
    
    func changeWatchingStatus(id: Int, video: Int?, season: Int, status: Int?) {
        networkingService.changeWatchingStatus(id: id, video: video, season: season, status: status) {(response, error) in
            if let responseData = response, responseData.status == 200 {
                self.delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
                    (delegate as! LogViewsManagerDelegate).didChangeStatus(manager: self)
                }
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func changeMarktime(id: Int, time: TimeInterval, video: Int, season: Int?) {
        networkingService.changeMarktime(id: id, time: time, video: video, season: season) { (_, _) in
            
        }
    }
    
    func changeWatchlistForMovie(id: Int, time: TimeInterval) {
        networkingService.changeMarktime(id: id, time: time, video: 1, season: nil) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                self.delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
                    (delegate as! LogViewsManagerDelegate).didChangeStatus(manager: self)
                }
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func changeWatchlist(id: String) {
        networkingService.changeWatchlist(id: id) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                self.delegatesStorage.enumerateDelegatesWithBlock { (delegate) in
                    (delegate as! LogViewsManagerDelegate).didToggledWatchlist(toggled: (response?.watching)!)
                }
                let str = responseData.watching! ? "добавлен в" : "удален из"
                let banner = StatusBarNotificationBanner(title: "Сериал \(str) \"Я смотрю\"", style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
            } else if response?.status == 0 {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "Невозможно добавить в Watchlist. \(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
}
