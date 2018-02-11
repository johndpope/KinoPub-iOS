import Foundation
import NotificationBannerSwift

protocol TVModelDelegate: class {
    func didUpdateChannels(model: TVModel)
}

class TVModel {
    var sportChannels = [Channels]()
    
    let accountManager: AccountManager
    let networkingService: TVNetworkingService
    weak var delegate: TVModelDelegate?
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = TVNetworkingService(requestFactory: accountManager.requestFactory)
    }
    
    func loadSportChannels() {
        networkingService.receiveTVChanels { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let responseData = response {
                strongSelf.sportChannels = responseData
                strongSelf.delegate?.didUpdateChannels(model: strongSelf)
            } else {
                let banner = NotificationBanner(title: "Ошибка", subtitle: "\(error?.localizedDescription ?? "")", style: .danger)
                banner.show(queuePosition: .front)
            }
        }
    }
}
