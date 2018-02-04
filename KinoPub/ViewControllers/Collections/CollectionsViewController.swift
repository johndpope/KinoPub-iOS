import UIKit
import DGCollectionViewPaginableBehavior
import InteractiveSideMenu

class CollectionsViewController: ContentCollectionViewController, SideMenuItemContent {
    fileprivate let model = Container.ViewModel.collection()
    
    let behavior = DGCollectionViewPaginableBehavior()
    let control = UIRefreshControl()
    var refreshing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.kpBackground
        title = "Подборки"

        collectionView?.delegate = behavior
        collectionView?.dataSource = self
        behavior.delegate = self
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        } else {
            // Fallback on earlier versions
        }
        
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = control
        } else {
            collectionView?.addSubview(control)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        refreshing = true
        model.refresh()
        refreshing = false
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) {
            self.collectionView?.reloadData()
        }
        control.endRefreshing()
    }

    
    // MARK: - Navigation
    @objc func tap(sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            showItemVC(with: model.collections[indexPath.row])
        }
    }
    
    func showItemVC(with collection: Collections) {
        if let itemsViewController = ItemsCollectionViewController.storyboardInstance() {
            itemsViewController.itemsTag = TabBarItemTag.collections.rawValue
            itemsViewController.title = collection.title
            itemsViewController.model.configFrom("collections")
            itemsViewController.model.setParameter("id", value: (collection.id?.string)!)
            itemsViewController.navigationItem.title = collection.title
            navigationController?.pushViewController(itemsViewController, animated: true)
        }
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (model.collections.count) + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < model.collections.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier, for: indexPath) as! LoadingItemCollectionViewCell
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        cell.configure(with: model.collections[indexPath.row])
        return cell
    }
    
    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - StatusBar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension CollectionsViewController: DGCollectionViewPaginableBehaviorDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var constant: CGFloat
        let orientation = UIApplication.shared.statusBarOrientation
        if (orientation == .landscapeLeft || orientation == .landscapeRight), UIDevice.current.userInterfaceIdiom == .pad {
            constant = 6.0
        } else if (orientation == .portrait || orientation == .portraitUpsideDown), UIDevice.current.userInterfaceIdiom == .pad {
            constant = 4.0
        } else if orientation == .landscapeLeft || orientation == .landscapeRight {
            constant = 4.0
        } else {
            constant = 2.0
        }
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / constant
        let height = width * 1.569
        return CGSize(width: width, height: height)
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, countPerPageInSection section: Int) -> Int {
        return 20
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        model.loadCollections { (count) in
            completion(nil, count ?? 0)
        }
    }
}
