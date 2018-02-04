import UIKit
import Crashlytics

protocol ProfileModelDelegate: class {
    func didUpdateProfile(model: ProfileModel)
}

class ProfileModel {
    weak var delegate: ProfileModelDelegate?
    var user: User?
    var device: Device?

    let accountManager: AccountManager
    let accountNetworkingService: AccountNetworkingService

    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        accountNetworkingService = AccountNetworkingService(requestFactory: accountManager.requestFactory)
    }

    func loadProfile() {
        accountNetworkingService.receiveUserProfile(completed: { [weak self] (profile, _) in
            guard let strongSelf = self else { return }
            strongSelf.user = profile?.user
            strongSelf.logUser()
            strongSelf.delegate?.didUpdateProfile(model: strongSelf)
        })
    }

    func loadCurrentDevice() {
        accountNetworkingService.receiveCurrentDevice { [weak self] (device, _) in
            guard let strongSelf = self else { return }
            strongSelf.device = device?.device
            strongSelf.delegate?.didUpdateProfile(model: strongSelf)
        }
    }
    
    private func logUser() {
        Crashlytics.sharedInstance().setUserIdentifier(UIDevice.current.identifierForVendor?.uuidString)
        Crashlytics.sharedInstance().setUserName(user?.username)
    }
}
