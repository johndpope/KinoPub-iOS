//
// NavigationMenuViewController.swift
//
// Copyright 2017 Handsome LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import InteractiveSideMenu

/*
 Menu controller is responsible for creating its content and showing/hiding menu using 'menuContainerViewController' property.
 */
class NavigationMenuViewController: MenuViewController {
    fileprivate let model = Container.ViewModel.profile()

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let menu = Config.MenuItems.all

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.delegate = self
        model.loadProfile()
        configView()
        configTableView()
    }
    
    func configView() {
        userNameLabel.textColor = .kpOffWhite
        daysLabel.textColor = .kpGreyishTwo
        profileView.backgroundColor = .clear
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
    }
    
    func configTableView() {
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        tableFooterView.backgroundColor = .clear
        tableView.tableFooterView = tableFooterView
        tableView.backgroundColor = .kpBackground
        view.backgroundColor = .kpBackground
        tableView.register(UINib(nibName: String(describing: MenuTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MenuTableViewCell.self))
        
        //Select the initial row
        if Config.shared.menuItem > menu.count - 1 {
            tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: UITableViewScrollPosition.none)
        } else {
            var row: Int
            var section: Int
            section = Config.shared.menuItem > Config.MenuItems.userMenu.count - 1 ? 1 : 0
            row = Config.shared.menuItem > Config.MenuItems.userMenu.count - 1 ? Config.shared.menuItem - Config.MenuItems.userMenu.count : Config.shared.menuItem
            tableView.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
    }
    
    func configureProfile() {
        if let imageUrl = model.user?.profile?.avatar {
            profileImageView.af_setImage(withURL: URL(string: imageUrl + "?s=200&d=identicon")!)
        }
        if let usernameString = model.user?.username {
            userNameLabel.text = usernameString
        }

        if let days = model.user?.subscription?.days, days != 0.0 {
            daysLabel.text = "Подписка на \(Int(days)) " + Int(days).getNumEnding(fromArray: ["день", "дня", "дней"])
        } else if model.user?.subscription?.endTime == 0 {
            daysLabel.text = "Бесконечная подписка"
        } else if model.user?.subscription?.days == 0.0 {
            daysLabel.text = "Нет подписки"
        }
    }
    
    @objc func openProfile() {
        guard let menuContainerViewController = self.menuContainerViewController else { return }
        menuContainerViewController.selectContentViewController((self.storyboard?.instantiateViewController(withIdentifier: "ProfileNavVC"))!)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        menuContainerViewController.hideSideMenu()
    }
    
    // MARK: - StatusBar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

/*
 Extention of `NavigationMenuViewController` class, implements table view delegates methods.
 */
extension NavigationMenuViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Config.MenuItems.userMenu.count
        case 1:
            return Config.MenuItems.contentMenu.count
        case 2:
            return Config.MenuItems.settingsMenu.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuTableViewCell.self), for: indexPath) as! MenuTableViewCell
        
        var indexPathRow = indexPath.row
        if indexPath.section == 1 { indexPathRow += Config.MenuItems.userMenu.count }
        if indexPath.section == 2 { indexPathRow += Config.MenuItems.userMenu.count + Config.MenuItems.contentMenu.count }
        
        cell.config(withMenuItem: menu[indexPathRow])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuContainerViewController = self.menuContainerViewController else { return }
        
        var indexPathRow = indexPath.row
        if indexPath.section == 1 { indexPathRow += Config.MenuItems.userMenu.count }
        if indexPath.section == 2 { indexPathRow += Config.MenuItems.userMenu.count + Config.MenuItems.contentMenu.count }

        if let navVC = menuContainerViewController.contentViewControllers[indexPathRow] as? NavigationController, let iVC = navVC.viewControllers.first as? ItemsCollectionViewController {
            menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[indexPathRow])
            iVC.itemsTag = menu[indexPathRow].tag!
        } else {
           menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[indexPathRow])
        }
        menuContainerViewController.hideSideMenu()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenSize = UIScreen.main.bounds.width
        let headerView = UIView()
        let separator = UIView(frame: CGRect(x: 15, y: 14.5, width: screenSize - 30 - screenSize / Config.shared.menuVisibleContentWidth , height: 0.5))
        separator.backgroundColor = .kpOffWhiteSeparator
        headerView.backgroundColor = .clear
        headerView.addSubview(separator)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        return true
    }
}

extension NavigationMenuViewController: ProfileModelDelegate {
    func didUpdateProfile(model: ProfileModel) {
        configureProfile()
    }
}
