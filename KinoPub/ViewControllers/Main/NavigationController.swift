import UIKit
import InteractiveSideMenu

class NavigationController: UINavigationController, SideMenuItemContent {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .black
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        if self.topViewController != nil {
            return self.topViewController!.shouldAutorotate
        } else {
            return  super.shouldAutorotate
        }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if self.topViewController != nil{
            return self.topViewController!.supportedInterfaceOrientations
        }else{
            return  super.supportedInterfaceOrientations
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if self.topViewController != nil{
            return self.topViewController!.preferredInterfaceOrientationForPresentation
        }else{
            return  super.preferredInterfaceOrientationForPresentation
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController!.preferredStatusBarStyle
    }

}
