import Foundation
import NotificationBannerSwift

protocol FilterModelDelegate: class {
    func didUpdateItems(model: FilterModel)
}
class FilterModel {
    weak var delegate: FilterModelDelegate?
    var type: ItemType?
    var genres = [Genres]()
    var countries = [Countries]()
    var subtitles = [SubtitlesList]()
    var filter = Filter.defaultFilter
    
    let accountManager: AccountManager
    let networkingService: FilterNetworkingService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = FilterNetworkingService(requestFactory: accountManager.requestFactory)
//        accountManager.addDelegate(delegate: self)
    }
    
    func loadItemsGenres() {
        networkingService.receiveItemsGenres(type: type?.rawValue ?? "") { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response {
                strongSelf.genres.append(contentsOf: responseData)
                strongSelf.delegate?.didUpdateItems(model: strongSelf)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func loadItemsCountry() {
        networkingService.receiveItemsCountry { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response {
                strongSelf.countries = responseData
                strongSelf.delegate?.didUpdateItems(model: strongSelf)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
    
    func loadItemsSubtitles() {
        networkingService.receiveSubtitleItems { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response {
//                strongSelf.subtitles = responseData
                strongSelf.subtitles.append(SubtitlesList(id: "0", title: "Не важно"))
                strongSelf.subtitles.append(contentsOf: responseData)
                strongSelf.delegate?.didUpdateItems(model: strongSelf)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
}
