import Foundation
import LKAlertController
import NotificationBannerSwift

protocol BookmarksModelDelegate: class {
    func didUpdateBookmarks(model: BookmarksModel)
    func didUpdateItems(model: BookmarksModel)
    func didAddedBookmarks()
}

extension BookmarksModelDelegate {
    func didUpdateBookmarks(model: BookmarksModel) {
        
    }
    func didUpdateItems(model: BookmarksModel) {
        
    }
    func didAddedBookmarks() {
        
    }
}

class BookmarksModel {
    weak var delegate: BookmarksModelDelegate?
    var bookmarks = [Bookmarks]()
    var items = [Item]()
    var folder: Bookmarks?
    var page: Int = 1
    
    let accountManager: AccountManager
    let networkingService: BookmarksNetworkService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = BookmarksNetworkService(requestFactory: accountManager.requestFactory)
        //        accountManager.addDelegate(delegate: self)
    }
    
    func loadBookmarks(completed: @escaping (() -> Void)) {
        networkingService.receiveBookmarks { [weak self] (bookmarks, error) in
            guard let strongSelf = self else { return }
            if let itemsData = bookmarks {
                strongSelf.bookmarks = itemsData
                completed()
            } else {
                debugPrint("[!ERROR]: \(String(describing: error?.localizedDescription))")
                Alert(title: "Ошибка", message: error?.localizedDescription)
                    .showOkay()
                completed()
            }
        }
    }
    
    func loadBookmarks(completed: @escaping (([Bookmarks]?) -> Void)) {
        networkingService.receiveBookmarks { [weak self] (bookmarks, error) in
            guard let strongSelf = self else { return }
            if let itemsData = bookmarks {
                strongSelf.bookmarks = itemsData
                completed(itemsData)
            } else {
                debugPrint("[!ERROR]: \(String(describing: error?.localizedDescription))")
                Alert(title: "Ошибка", message: error?.localizedDescription)
                    .showOkay()
                completed(nil)
            }
        }
    }
    
    func loadBookmarkItems(completed: @escaping (_ count: Int?) -> ()) {
        networkingService.receiveBookmarkItems(id: (folder?.id?.string)!, page: page.string) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let itemsData = response {
                guard let items = itemsData.items else { return }
                strongSelf.page += 1
                strongSelf.items.append(contentsOf: items)
                strongSelf.delegate?.didUpdateItems(model: strongSelf)
                completed(itemsData.items?.count)
            } else {
                debugPrint("[!ERROR]: \(String(describing: error?.localizedDescription))")
                Alert(title: "Ошибка", message: error?.localizedDescription)
                    .showOkay()
                completed(nil)
            }
        }
    }
    
    func createBookmarkFolder(title: String) {
        networkingService.createBookmarkFolder(title: title) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response, responseData.status == 200 {
                let banner = StatusBarNotificationBanner(title: "Папка \"\(title)\" успешно создана", style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
                strongSelf.delegate?.didUpdateBookmarks(model: strongSelf)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "Невозможно создать папку. \(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func removeBookmarkFolder(folder: String) {
        networkingService.removeBookmarkFolder(folder: folder) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                let banner = StatusBarNotificationBanner(title: "Папка успешно удалена.", style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "Невозможно удалить папку. \(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func removeItemFromFolder(item: String, folder: String) {
        networkingService.removeItemFromFolder(item: item, folder: folder) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                let banner = StatusBarNotificationBanner(title: "Успешно удален.", style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "Невозможно удалить. \(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func addItemToFolder(item: String, folder: String) {
        networkingService.addItemToFolder(item: item, folder: folder) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response, responseData.status == 200 {
                let banner = StatusBarNotificationBanner(title: "Успешно добавлен.", style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
                strongSelf.delegate?.didAddedBookmarks()
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "Невозможно добавить. \(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func toggleItemToFolder(item: String, folder: String) {
        networkingService.toggleItemToFolder(item: item, folder: folder) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response, responseData.status == 200 {
                let str = responseData.exists! ? "Закладка добавлена." : "Закладка удалена."
                let banner = StatusBarNotificationBanner(title: str, style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
                strongSelf.delegate?.didAddedBookmarks()
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func getItemFolders(item: String, completed: @escaping (([Bookmarks]?) -> Void)) {
        networkingService.receiveItemFolders(item: item) { (response, error) in
            if let responseData = response {
                completed(responseData)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func refresh() {
        page = 1
        items.removeAll()
    }
    
}
