//
//  ProfileViewController.swift
//  KinoPub
//
//  Created by hintoz on 26.05.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import AlamofireImage
import LKAlertController
import InteractiveSideMenu
import SafariServices

class ProfileViewController: UITableViewController, ProfileModelDelegate, SideMenuItemContent {
    fileprivate let model = try! AppDelegate.assembly.resolve() as ProfileModel
    fileprivate let accountManager = try! AppDelegate.assembly.resolve() as AccountManager

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var uncertainDetailLabel: UILabel!
    @IBOutlet weak var eroticDetailLabel: UILabel!
    @IBOutlet weak var daySubscriptionDetailLabel: UILabel!
    @IBOutlet weak var endTimeDetailLabel: UILabel!
    @IBOutlet weak var deviceNameDetailLabel: UILabel!
    @IBOutlet weak var hardwareDetailLabel: UILabel!
    @IBOutlet weak var softwareDatailLabel: UILabel!
    
    @IBOutlet weak var goToSiteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        confugureNavBar()
        configureVC()

//        configureVersionInfo()

        model.delegate = self
        model.loadProfile()
        model.loadCurrentDevice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func confugureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Kinopub (Menu)")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(showMenu))
//        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Выход", style: .done, target: self, action: #selector(logOutButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.kpMarigold
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.tintColor = UIColor.white
    }

    func configureVC() {
        navigationController?.navigationBar.clean(true)
        view.backgroundColor = .kpBackground
        
        tableView.backgroundColor = .kpBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.separatorColor = UIColor.kpOffWhiteSeparator
        tableView.separatorStyle = .singleLine
        
        profileNameLabel.text = "Загрузка пользователя"
        profileNameLabel.textColor = .kpOffWhite
        usernameLabel.text = "подбираем ваш пароль..."
        usernameLabel.textColor = .kpGreyishTwo
//        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
//        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
        goToSiteButton.tintColor = .kpGreyishTwo
        goToSiteButton.borderColor = .kpGreyishBrown
    }

    func configureProfile() {
        if let imageUrl = model.user?.profile?.avatar {
            profileImageView.af_setImage(withURL: URL(string: imageUrl + "?s=200&d=identicon")!)
        }
        if let nameString = model.user?.profile?.name {
            profileNameLabel.text = nameString
        } else {
            profileNameLabel.text = nil
        }
        if let usernameString = model.user?.username {
            usernameLabel.text = usernameString
        }
        if let isUncertain = model.user?.settings?.showUncertain {
            uncertainDetailLabel.text = isUncertain ? "Вкл." : "Выкл."
        }
        if let isErotic = model.user?.settings?.showErotic {
            eroticDetailLabel.text = isErotic ? "Вкл." : "Выкл."
        }
        if let days = model.user?.subscription?.days, days != 0.0 {
            let tapDaysLabel = UITapGestureRecognizer(target: self, action: #selector(openSafariVC(_:)))
            daySubscriptionDetailLabel.isUserInteractionEnabled = true
            daySubscriptionDetailLabel.addGestureRecognizer(tapDaysLabel)
//            daySubscriptionDetailLabel.underlineTextStyle()
//            daySubscriptionDetailLabel.textColor = UIColor.kpLightGreen
            daySubscriptionDetailLabel.text = String(days)
        } else if model.user?.subscription?.endTime == 0 {
            daySubscriptionDetailLabel.text = "∞"
        } else if model.user?.subscription?.days == 0.0 {
            daySubscriptionDetailLabel.text = "0"
        }
        if let endTime = model.user?.subscription?.endTime, endTime != 0 {
            let format = DateFormatter()
            format.dateFormat = "dd.MM.yyyy"
            endTimeDetailLabel.text = format.string(from: Date(timeIntervalSince1970: TimeInterval(exactly: endTime)!))
        } else if model.user?.subscription?.endTime == 0 {
            endTimeDetailLabel.text = "∞"
        }
    }

    func configureDevice() {
        if let deviceName = model.device?.title {
            deviceNameDetailLabel.text = deviceName
        }
        if let hardware = model.device?.hardware {
            hardwareDetailLabel.text = hardware
        }
        if let software = model.device?.software {
            softwareDatailLabel.text = software
        }
    }

    func configureVersionInfo() {
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 52))
        tableViewFooter.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 8, y: 15, width: tableView.frame.width, height: 20))
        label.font = label.font.withSize(12)
        label.text = "Изменить информацио о профиле и настройки, а также оплатить сервис можно только на официальном сайте."
        label.textColor = UIColor.lightGray
        label.textAlignment = .center

        tableViewFooter.addSubview(label)

        tableView.tableFooterView  = tableViewFooter
    }
    
    @IBAction func goToSiteButtonPressed(_ sender: Any) {
        openUserProfile()
    }
    
    @objc func openSafariVC(_ sender: UITapGestureRecognizer) {
        let svc = SFSafariViewController(url: URL(string: "\(Config.shared.kinopubDomain)/donate")!)
        self.present(svc, animated: true, completion: nil)
    }
    
    func openUserProfile() {
        let svc = SFSafariViewController(url: URL(string: "\(Config.shared.kinopubDomain)/user/settings/profile")!)
        self.present(svc, animated: true, completion: nil)
    }

    @objc func logOutButtonTapped() {
        Alert(message: "Отвязать устройство?")
            .tint(.kpBlack)
            .addAction("Нет", style: .cancel)
            .addAction("Да", style: .default, handler: { (action) in
                self.accountManager.logoutAccount()
            }).show(animated: true)
//        Alert(message: "Скоро")
//        .showOkay()
    }

    // MARK: - Profile Model Delegate
    func didUpdateProfile(model: ProfileModel) {
        configureProfile()
        configureDevice()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 4
        }
        return 3
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.kpBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.kpGreyishBrown
    }

    // MARK: - Navigation
    static func storyboardInstance() -> ProfileViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ProfileViewController
    }

    @objc func showMenu() {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }

}
