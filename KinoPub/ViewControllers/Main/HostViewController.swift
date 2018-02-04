//
// HostViewController.swift
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
import RevealingSplashView
import InteractiveSideMenu
import SwiftyUserDefaults
import LKAlertController

/*
 HostViewController is container view controller, contains menu controller and the list of relevant view controllers.

 Responsible for creating and selecting menu items content controlers.
 Has opportunity to show/hide side menu.
 */
class HostViewController: MenuContainerViewController {
    fileprivate let accountManager = Container.Manager.account
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    let menu = Config.MenuItems.all

    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        setDefaults()
        
        accountManager.addDelegate(delegate: self)

        let screenSize: CGRect = UIScreen.main.bounds
        self.transitionOptions = TransitionOptions(duration: 0.4, contentScale: 1, visibleContentWidth: screenSize.width / Config.shared.menuVisibleContentWidth)

        // Instantiate menu view controller by identifier
        self.menuViewController = self.storyboard!.instantiateViewController(withIdentifier: "NavigationMenu") as! MenuViewController

        // Gather content items controllers
        self.contentViewControllers = contentControllers()

        // Select initial content controller. It's needed even if the first view controller should be selected.
        if Config.shared.menuItem > contentViewControllers.count - 1 {
            Defaults[.menuItem] = Config.MenuItems.userMenu.count
        }
        if let navVC = contentViewControllers[Config.shared.menuItem] as? NavigationController, let iVC = navVC.viewControllers.first as? ItemsCollectionViewController {
            self.selectContentViewController(contentViewControllers[Config.shared.menuItem])
            iVC.itemsTag = menu[Config.shared.menuItem].tag!
        } else {
            self.selectContentViewController(contentViewControllers[Config.shared.menuItem])
        }
        
        showSplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        chechAccount()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        /*
         Options to customize menu transition animation.
         */
        var options = TransitionOptions()

        // Animation duration
        options.duration = size.width < size.height ? 0.4 : 0.6
        
        options.contentScale = 1

        // Part of item content remaining visible on right when menu is shown
        options.visibleContentWidth = size.width / Config.shared.menuVisibleContentWidth
        self.transitionOptions = options
    }
    
    func chechAccount() {
        if !accountManager.hasAccount {
            showAuthViewController()
        } else {
        }
    }
    
    func showAuthViewController() {
        if let authViewController = AuthViewController.storyboardInstance() {
            present(authViewController, animated: true, completion: nil)
        } else {
            Alert(title: "Ошибка", message: "Что-то пошло не так.")
                .showOkay()
        }
    }
    
    func registerSettingsBundle() {
        let appDefaults = [String: AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    func setDefaults() {
        if UserDefaults.standard.object(forKey: "showRatringInPoster") == nil {
            Defaults[.showRatringInPoster] = true
        }
        
        if UserDefaults.standard.object(forKey: "logViews") == nil {
            Defaults[.logViews] = true
        }
        
        if UserDefaults.standard.object(forKey: "leftSlideTrigger") == nil {
            Defaults[.leftSlideTrigger] = "none"
        }
        
        if UserDefaults.standard.object(forKey: "rightSlideTrigger") == nil {
            Defaults[.rightSlideTrigger] = "none"
        }
        
        if UserDefaults.standard.object(forKey: "streamType") == nil {
            Defaults[.streamType] = "hls4"
        }
        
        if UserDefaults.standard.object(forKey: "clientTitle") == nil {
            Defaults[.clientTitle] = UIDevice().name
        }
        
        if UserDefaults.standard.object(forKey: "menuItem") == nil {
            Defaults[.menuItem] = Config.MenuItems.userMenu.count
        }
    }
    
    func showSplashView() {
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Icon-App-iTunes")!,
                                                      iconInitialSize: CGSize(width: 192, height: 192),
                                                      backgroundColor: UIColor.kpBackground)
        
        //Adds the revealing splash view as a sub view
        contentViewControllers[Config.shared.menuItem].view.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.startAnimation {
            print("Completed")
        }
    }

    private func contentControllers() -> [UIViewController] {
        var contentList = [UIViewController]()

        /*
         Instantiate items controllers from storyboard.
         */
        for menuItem in menu {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: menuItem.id) {
                contentList.append(viewController)
            }
        }

        return contentList
    }
    
    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        return true
    }
}

extension HostViewController: AccountManagerDelegate {
    func accountManagerDidLogout(accountManager: AccountManager) {
        showAuthViewController()
    }
}

