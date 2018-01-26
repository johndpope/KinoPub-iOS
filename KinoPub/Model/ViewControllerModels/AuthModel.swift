//
//  AuthModel.swift
//  KinoPub
//
//  Created by hintoz on 03.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import LKAlertController

protocol AuthModelDelegate: class {
    func authModelDidAuth(authModel: AuthModel)
    func updateCode(authModel: AuthModel)
}

class AuthModel {
    let accountManager: AccountManager
    let authNetworkingService: AuthNetworkingService
    weak var delegate: AuthModelDelegate?

    var timerCheck: Timer?
    var timerLoad: Timer?
    var code: String?
    var userCode: String?

    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        authNetworkingService = AuthNetworkingService(requestFactory: accountManager.requestFactory)
        accountManager.addDelegate(delegate: self)
    }

    func loadDeviceCode(completed: @escaping ((AuthResponse) -> Void)) {
        invalidateTimer()
        authNetworkingService.receiveDeviceCode { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let authData = response {
                strongSelf.code = authData.code
                strongSelf.userCode = authData.userCode
                completed(authData)
                strongSelf.startTimerLoadCode(withInterval: authData.expiresIn)
                strongSelf.startTimerCheckCode(withInterval: authData.interval)
            } else {
                Alert(title: "Ошибка", message: error?.localizedDescription)
                    .showOkay()
            }
        }
    }

    func startTimerCheckCode(withInterval interval: Int?) {
        timerCheck = Timer.scheduledTimer(timeInterval: TimeInterval(interval ?? 0), target: self, selector: #selector(checkCodeValidation), userInfo: nil, repeats: true)
    }
    
    func startTimerLoadCode(withInterval interval: Int?) {
        timerLoad = Timer.scheduledTimer(timeInterval: TimeInterval(interval ?? 0), target: self, selector: #selector(loadNewCode), userInfo: nil, repeats: true)
    }

    func invalidateTimer() {
        if let uwTimer = timerCheck {
            if uwTimer.isValid {
                uwTimer.invalidate()
            }
        }
        if let uwTimer = timerLoad {
            if uwTimer.isValid {
                uwTimer.invalidate()
            }
        }
    }

    deinit {
        invalidateTimer()
    }
    
    @objc func loadNewCode() {
        invalidateTimer()
        delegate?.updateCode(authModel: self)
    }

    @objc func checkCodeValidation() {
        authNetworkingService.checkApproved(withCode: code!) { [weak self] (response, _) in
            guard let strongSelf = self else { return }
            if let tokenData = response {
                strongSelf.invalidateTimer()
                strongSelf.accountManager.createAccount(tokenData: tokenData)
            }
        }
    }
}

extension AuthModel: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        
        self.delegate?.authModelDidAuth(authModel: self)
    }
}
