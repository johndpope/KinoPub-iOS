import UIKit
import LKAlertController
import SwiftyUserDefaults
import InteractiveSideMenu

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, SideMenuItemContent {

    let tabBarOrderKey = "tabBarOrderKey"

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        registerSettingsBundle()
        configureVtewControllers()
        setUpTabBarItemTags()
        getSavedTabBarItemsOrder()

        tabBar.tintColor = UIColor.kpLightGreen
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        configureMoreViewController()
    }
    

    func configureVtewControllers() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let n1 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController
        let n2 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController
        let n3 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController
        let n4 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController
        let n5 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController
        let n6 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController
        let n7 = storyBoard.instantiateViewController(withIdentifier: "ItemNavVC") as! NavigationController

        n1.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "Фильмы", image: UIImage(named: "Movie-50"), selectedImage: UIImage(named: "Movie Filled-50"))
        n2.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "Сериалы", image: UIImage(named: "TV Show-50"), selectedImage: UIImage(named: "TV Show Filled-50"))
        n3.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "Мультфильмы", image: UIImage(named: "Minion 2-50"), selectedImage: UIImage(named: "Minion 2 Filled-50"))
        n4.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "Док. фильмы", image: UIImage(named: "Documentary-50"), selectedImage: UIImage(named: "Documentary Filled-50"))
        n5.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "Док. сериалы", image: UIImage(named: "Documentary2-50"), selectedImage: UIImage(named: "Documentary2 Filled-50"))
        n6.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "ТВ Шоу", image: UIImage(named: "Retro TV-50"), selectedImage: UIImage(named: "Retro TV Filled-50"))
        n7.viewControllers.first?.tabBarItem = UITabBarItem.init(title: "Концерты", image: UIImage(named: "Drum Set-50"), selectedImage: UIImage(named: "Drum Set Filled-50"))

        self.viewControllers = [n1, n2, n3, n4, n5, n6, n7]
    }

    func configureMoreViewController() {
        moreNavigationController.navigationBar.barStyle = .black
        moreNavigationController.navigationBar.tintColor = UIColor.white
        moreNavigationController.topViewController?.view.backgroundColor = UIColor.kpBackground
        (moreNavigationController.topViewController?.view as? UITableView)?.separatorStyle = .none
        (moreNavigationController.topViewController?.view as? UITableView)?.tintColor = UIColor.lightGray
        if let cells = (moreNavigationController.topViewController?.view as? UITableView)?.visibleCells {
            for cell in cells {
                cell.backgroundColor = UIColor.clear
                cell.textLabel?.textColor = UIColor.lightGray
            }
        }
    }

    func setUpTabBarItemTags() {
        var tag = 0
        if let viewControllers = viewControllers {
            for view in viewControllers {
                view.tabBarItem.tag = tag
                tag += 1
            }
        }
    }

    func getSavedTabBarItemsOrder() {
        var newViewControllerOrder = [UIViewController]()
        if let initialViewControllers = viewControllers {
            if let tabBarOrder = UserDefaults.standard.object(forKey: tabBarOrderKey) as? [Int] {
                if tabBarOrder.count > (viewControllers?.count)! {
                    UserDefaults.standard.set(nil, forKey: tabBarOrderKey)
                    return
                }
                for tag in tabBarOrder {
                    newViewControllerOrder.append(initialViewControllers[tag])
                }
                
                if newViewControllerOrder.count == viewControllers?.count {
                    setViewControllers(newViewControllerOrder, animated: false)
                }
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        var orderedTagItems = [Int]()
        if changed {
            for viewController in viewControllers {
                let tag = viewController.tabBarItem.tag
                orderedTagItems.append(tag)

            }
            UserDefaults.standard.set(orderedTagItems, forKey: tabBarOrderKey)
            print(orderedTagItems)
        } else {
            print("not changed")
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        (tabBarController.view.subviews[1].subviews[1] as? UINavigationBar)?.barStyle = .black
        (tabBarController.view.subviews[1].subviews[1] as? UINavigationBar)?.tintColor = UIColor.white
        tabBarController.view.subviews[1].backgroundColor = UIColor.kpBackground
        tabBarController.view.subviews[1].tintColor = UIColor.kpLightGreen
    }

    func registerSettingsBundle() {
        let appDefaults = [String: AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }

    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        if let selectedViewController = self.selectedViewController {
            return selectedViewController.shouldAutorotate
        } else {
            return  super.shouldAutorotate
        }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let selectedViewController = self.selectedViewController{
            return selectedViewController.supportedInterfaceOrientations
        }else{
            return  super.supportedInterfaceOrientations
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        
        if let selectedViewController = self.selectedViewController{
            return selectedViewController.preferredInterfaceOrientationForPresentation
        }else{
            return  super.preferredInterfaceOrientationForPresentation
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let selectedViewController = self.selectedViewController {
            return selectedViewController.preferredStatusBarStyle
        } else {
            return  super.preferredStatusBarStyle
        }
    }

}
