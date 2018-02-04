import Foundation
import SwiftyUserDefaults
import KeychainSwift
import Alamofire

protocol AccountManager: class {
    var account: KinopubAccount? { get }
    var hasAccount: Bool { get }
    var requestFactory: RequestFactory { get }
    func addDelegate(delegate: AccountManagerDelegate)
    func createAccount(tokenData: TokenResponse)
    func silentlyUpdateAccountWith(accessToken token: String, refreshToken: String)
    func logoutAccount()
}

protocol AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount)
    func accountManagerDidLogout(accountManager: AccountManager)
    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount)
}

extension AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {

    }

    func accountManagerDidLogout(accountManager: AccountManager) {

    }

    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount) {

    }
}

class AccountManagerImp: AccountManager {
    var delegatesStorage = DelegatesStorage()
    let requestFactory: RequestFactory
    let accountNetworkingService: AccountNetworkingService
    let keychain: KeychainSwift

    var account: KinopubAccount?
    var hasAccount: Bool {
        return account != nil
    }

    init() {
        requestFactory = RequestFactory()
        accountNetworkingService = AccountNetworkingService(requestFactory: requestFactory)
        keychain = KeychainSwift()
        checkIfAccountExist()
    }

    func addDelegate(delegate: AccountManagerDelegate) {
        delegatesStorage.addDelegate(delegate: delegate as AnyObject)
    }

    func createAccount(tokenData: TokenResponse) {
        keychain.set(tokenData.accessToken!, forKey: "accessToken")
        keychain.set(tokenData.refreshToken!, forKey: "refreshToken")
        self.account = KinopubAccount(accessToken: tokenData.accessToken!, refreshToken: tokenData.refreshToken!)
        self.authAndNotifyDelegates()
    }

    func silentlyUpdateAccountWith(accessToken token: String, refreshToken: String) {
        keychain.set(token, forKey: "accessToken")
        keychain.set(refreshToken, forKey: "refreshToken")
        self.account = KinopubAccount(accessToken: token, refreshToken: refreshToken)
        delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
            (delegate as! AccountManagerDelegate).accountManagerDidUpdateToken(accountManager: self, forAccount: self.account!)
        }
    }

    func logoutAccount() {
        self.logoutAndNotifyDelegates()
    }

    private func checkIfAccountExist() {
        if let accessToken = keychain.get("accessToken") {
            self.account = KinopubAccount(accessToken: accessToken, refreshToken: keychain.get("refreshToken"))
            self.authAndNotifyDelegates()
        }
    }

    private func authAndNotifyDelegates() {
        requestFactory.accountManager = self
        delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
            (delegate as! AccountManagerDelegate).accountManagerDidAuth(accountManager: self, toAccount: self.account!)
        }
        self.notifyAboutDeviceIfRequired()
    }

    private func notifyAboutDeviceIfRequired() {
        if account == nil {
            return
        }
        accountNetworkingService.notifyAboutDevice { error in
            if let error = error {
                debugPrint("![ERROR] notifyAboutDevice. \(error.localizedDescription)")
            }
        }
    }

    private func logoutAndNotifyDelegates() {
        accountNetworkingService.unlinkDevice { (error) in
            if let error = error {
                debugPrint("![ERROR] unlinkDevice. \(error.localizedDescription)")
            }
        }
        keychain.clear()
        account = nil
        delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
            (delegate as! AccountManagerDelegate).accountManagerDidLogout(accountManager: self)
        }
    }
}
