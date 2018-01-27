import UIKit
import DGCollectionViewPaginableBehavior
import AZSearchView
import InteractiveSideMenu
import GradientLoadingBar

class ItemsCollectionViewController: ContentCollectionViewController, SideMenuItemContent {
    let model = try! AppDelegate.assembly.resolve() as VideoItemsModel
    fileprivate let accountManager = try! AppDelegate.assembly.resolve() as AccountManager

    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
//    @IBOutlet weak var typeWatchlistSegmentedControl: UISegmentedControl!
    
//    var type: ItemType? {
//        didSet {
//            model.type = type
//        }
//    }
    var itemsTag: Int!
    let behavior = DGCollectionViewPaginableBehavior()
    let control = UIRefreshControl()
    
    var searchController: AZSearchViewController!
    var searchControllerNew: UISearchController!
    
    let gradientLoadingBar = GradientLoadingBar()
    var refreshing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        accountManager.addDelegate(delegate: self)
        model.delegate = self
        configSearch()
        configMenuIcon()

        collectionView?.backgroundColor = .kpBackground
        
        searchControllerNew = UISearchController(searchResultsController: nil)
        searchControllerNew.searchBar.tintColor = .kpOffWhite
        searchControllerNew.searchBar.placeholder = "Поиск"
        searchControllerNew.searchBar.keyboardAppearance = .dark
        
        if #available(iOS 11.0, *) {
            navigationItem.rightBarButtonItems = [filterButton]
            searchControllerNew.dimsBackgroundDuringPresentation = true
            searchControllerNew.obscuresBackgroundDuringPresentation = false
            searchControllerNew.searchBar.sizeToFit()
            //
            //        searchControllerNew.searchBar.becomeFirstResponder()
            
            searchControllerNew.searchResultsUpdater = self
            searchControllerNew.searchBar.delegate = self
            
            
            searchControllerNew.hidesNavigationBarDuringPresentation = true
            
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            
            let attributes = [
                NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite
                ]
            
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
            navigationItem.searchController = searchControllerNew
            
            
            definesPresentationContext = true
        } else {
            // Fallback on earlier versions
//            navigationItem.titleView = searchControllerNew.searchBar
//            searchControllerNew.searchBar.showsCancelButton = false
//            searchControllerNew.hidesNavigationBarDuringPresentation = false
            navigationItem.rightBarButtonItems = [filterButton, searchButton]
        }
        
        configTabBar()

        collectionView?.delegate = behavior
        collectionView?.dataSource = self
        behavior.delegate = self
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = control
        } else {
            collectionView?.addSubview(control)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        configFilterButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @objc func refresh() {
        refreshing = true
        searchControllerNew.isActive ? model.refreshSearch() : model.refresh()
        refreshing = false
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) {
            self.collectionView?.reloadData()
        }
        control.endRefreshing()
    }

    func configTabBar() {
        switch itemsTag {
        case TabBarItemTag.movies.getValue():
            model.type = ItemType.movies
            navigationItem.title = ItemType.movies.description
        case TabBarItemTag.shows.getValue():
            model.type = ItemType.shows
            navigationItem.title = ItemType.shows.description
        case TabBarItemTag.documovie.getValue():
            model.type = ItemType.documovie
            navigationItem.title = ItemType.documovie.description
        case TabBarItemTag.docuserial.getValue():
            model.type = ItemType.docuserial
            navigationItem.title = ItemType.docuserial.description
        case TabBarItemTag.concert.getValue():
            model.type = ItemType.concerts
            navigationItem.title = ItemType.concerts.description
        case TabBarItemTag.tvshow.getValue():
            model.type = ItemType.tvshows
            navigationItem.title = ItemType.tvshows.description
        case TabBarItemTag.collections.getValue():
            model.configFrom("collections")
            navigationItem.rightBarButtonItems = nil
            navigationItem.leftBarButtonItem = nil
        case TabBarItemTag.watchlist.getValue():
            model.configFrom("watching")
            navigationItem.title = "Я смотрю"
            navigationItem.rightBarButtonItems = nil
        case TabBarItemTag.cartoons.getValue():
            model.setParameter("genre", value: "23")
            navigationItem.title = "Мультфильмы"
//            navigationItem.rightBarButtonItems?[0].customView = UIView()
        case TabBarItemTag.movies4k.getValue():
            model.type = ItemType.movies4k
            navigationItem.title = ItemType.movies4k.description
        case TabBarItemTag.movies3d.getValue():
            model.type = ItemType.movies3d
            navigationItem.title = ItemType.movies3d.description
        case TabBarItemTag.newMovies.getValue():
            navigationItem.title = TabBarItemTag.newMovies.description
//            navigationItem.rightBarButtonItems?[1].customView = UIView()
            model.type = ItemType.movies
            model.setParameter("sort", value: "-created")
//            model.from = "fresh"
        case TabBarItemTag.newSeries.getValue():
            navigationItem.title = TabBarItemTag.newSeries.description
//            navigationItem.rightBarButtonItems?[1].customView = UIView()
            model.type = ItemType.shows
            model.setParameter("sort", value: "-created")
//            model.from = "fresh"
        case TabBarItemTag.hotMovies.getValue():
            navigationItem.title = TabBarItemTag.hotMovies.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.movies
            model.from = "hot"
        case TabBarItemTag.hotSeries.getValue():
            navigationItem.title = TabBarItemTag.hotSeries.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.shows
            model.from = "popular"
        case TabBarItemTag.freshMovies.getValue():
            navigationItem.title = TabBarItemTag.freshMovies.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.movies
            model.from = "fresh"
        case TabBarItemTag.freshSeries.getValue():
            navigationItem.title = TabBarItemTag.freshSeries.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.shows
            model.from = "fresh"
        default:
            break
        }
    }

    func configSearch() {
        searchController = AZSearchViewController(cellReuseIdentifier: String(describing: SearchResultTableViewCell.self),
                                                  cellNibName: String(describing: SearchResultTableViewCell.self))
        
        searchController.delegate = self
        searchController.dataSource = self
        searchController.searchBarPlaceHolder = "Поиск"
        searchController.navigationBarClosure = { bar in
            //The navigation bar's background color
            bar.barTintColor = .kpBackground
            
            bar.isTranslucent = false
            
            //The tint color of the navigation bar
            bar.tintColor = .kpOffWhite
        }
        searchController.emptyResultCellTextColor = .kpOffWhite
        searchController.minimalCharactersForSearch = 2
        searchController.infoCellText = "Введите более 2-х символов для поиска"
        searchController.emptyResultCellText = "Нет результатов поиска"
        searchController.searchBarBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
        searchController.searchBarTextColor = .kpOffWhite
        searchController.keyboardAppearnce = .dark
        searchController.separatorColor = .kpOffWhiteSeparator
        searchController.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        searchController.tableViewBackgroundColor = .kpBackground //UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeSearchBar(_:)))
        item.tintColor = .kpMarigold
        searchController.navigationItem.rightBarButtonItem = item
    }
    
    func configFilterButton() {
        filterButton?.image = model.filter.isSet ? UIImage(named: "Filters Fill") : UIImage(named: "Filters")
    }
    
    func configMenuIcon() {
        if let count = navigationController?.viewControllers.count, count > 1 {
            navigationItem.leftBarButtonItem = nil
        }
    }

    // MARK: - Buttons

    @IBAction func showSearchButtonTapped(_ sender: UIBarButtonItem) {
        searchController.show(in: self)
//        if navigationItem.titleView == nil {
//            navigationItem.titleView = searchControllerNew.searchBar
//        } else {
//            searchControllerNew.searchBar.clear()
//            searchControllerNew.dismiss(animated: true, completion: nil)
//            navigationItem.titleView = nil
//        }
    }

    @objc func closeSearchBar(_ sender: AnyObject?) {
//        self.tabBarController?.tabBar.isHidden = false
        searchController.dismiss(animated: true)
    }

    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
//        if let menuItemViewController = self.tabBarController as? SideMenuItemContent {
//            menuItemViewController.showSideMenu()
//        }
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        if let fvc = FilterViewController.storyboardInstance() {
            fvc.model.type = model.type
            fvc.model.filter = model.filter
            navigationController?.pushViewController(fvc, animated: true)
//            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @IBAction func typeWatchlistSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            model.configFrom("watching")
            refresh()
        case 1:
            model.configFrom("usedMovie")
            refresh()
        default:
            break
        }
    }
    
    func filterBack() {
        refresh()
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation
    static func storyboardInstance() -> ItemsCollectionViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? ItemsCollectionViewController
    }

    @objc func tap(sender: UITapGestureRecognizer) {
        guard (searchControllerNew.isActive ? model.resultItems.count : model.videoItems.count) > 0 else { return }
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                if let image = cell.posterImageView.image {
                    showDetailVC(with: searchControllerNew.isActive ? model.resultItems[indexPath.row] : model.videoItems[indexPath.row], andImage: image)
                }
            }
        }
    }

    func showDetailVC(with item: Item, andImage image: UIImage) {
        if let detailViewController = DetailViewController.storyboardInstance() {
            detailViewController.image = image
            detailViewController.model.item = item
            navigationController?.pushViewController(detailViewController, animated: true)
        }
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

// MARK: UICollectionViewDataSource
extension ItemsCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (searchControllerNew.isActive ? model.resultItems.count : model.videoItems.count) + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < (searchControllerNew.isActive ? model.resultItems.count : model.videoItems.count) else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier, for: indexPath) as! LoadingItemCollectionViewCell
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        cell.set(item: searchControllerNew.isActive ? model.resultItems[indexPath.row] : model.videoItems[indexPath.row])
        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//         guard let _cell = cell as? ItemCollectionViewCell else { return }
//        _cell.configBlur()
//    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView!
        if (kind == UICollectionElementKindSectionHeader) {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath)
            reusableView = cell
        }
        if (kind == UICollectionElementKindSectionFooter) {
            reusableView = nil
        }
        
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if itemsTag == TabBarItemTag.watchlist.getValue(), !searchControllerNew.isActive {
            return CGSize(width: collectionView.width, height: 50)
        }
        return CGSize.zero
    }
}

// MARK: DGCollectionViewPaginableBehaviorDelegate
extension ItemsCollectionViewController: DGCollectionViewPaginableBehaviorDelegate {
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
        return model.countPerPage()
    }

    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        if searchControllerNew.isActive {
            guard searchControllerNew.searchBar.text!.count > 2 else {
                completion(nil, 0)
                return
            }
            model.loadSearchItems(searchControllerNew.searchBar.text!, iOS11: true, { (resultCount) in
                completion(nil, resultCount ?? 0)
            })
        } else {
            model.loadVideoItems { (resultCount) in
                completion(nil, resultCount ?? 0)
            }
        }
    }
}

// MARK: AZSearchView DataSource
extension ItemsCollectionViewController: AZSearchViewDataSource {
    func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    func results() -> [AnyObject] {
        return model.resultItems
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier) as! SearchResultTableViewCell
        cell.configure(with: model.resultItems[indexPath.row])
        return cell
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: AZSearchView Delegate
extension ItemsCollectionViewController: AZSearchViewDelegate {
    func searchView(_ searchView: AZSearchViewController, didSearchForText text: String) {
        searchView.searchBar.endEditing(true)
    }

    func searchView(_ searchView: AZSearchViewController, didTextChangeTo text: String, textLength: Int) {
        model.resultItems.removeAll()
        if textLength > 2 {
            gradientLoadingBar.show()
            searchController.emptyResultCellText = "загрузка..."
            model.loadSearchItems(text, { [weak self] _ in
                self?.searchController.emptyResultCellText = "Нет результатов поиска"
                searchView.reloadData()
                self?.gradientLoadingBar.hide()
            })
        }
        searchView.reloadData()
    }

    func searchView(_ searchView: UITableView, didSelectResultAt indexPath: IndexPath, object: AnyObject) {
        self.tabBarController?.tabBar.isHidden = false
        if let cell = searchView.cellForRow(at: indexPath) as? SearchResultTableViewCell {
            if let image = cell.posterImageView.image {
                self.searchController.dismiss(animated: true, completion: {
                    self.showDetailVC(with: object as! Item, andImage: image)
                })
            }
        }
    }

    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
}

// MARK: UISearchResultsUpdating
extension ItemsCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        collectionView?.reloadData()
        guard searchController.searchBar.text!.count > 2 else { return }
        model.refreshSearch()
//        model.resultItems.removeAll()
//        model.loadSearchItems(searchController.searchBar.text! ) { [weak self] _ in
//            guard let strongSelf = self else { return }
//            strongSelf.collectionView?.reloadData()
//        }
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) {
            self.collectionView?.reloadData()
        }
//        collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.resultItems.removeAll()
        behavior.reloadData()
        collectionView?.reloadData()
//        searchController.dismiss(animated: true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchController.show(in: self)
    }
    
    
}

// MARK: AccountManager Delegate
extension ItemsCollectionViewController: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        refresh()
    }
    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount) {
        refresh()
    }
}

// MARK: VideoItemsModel Delegate
extension ItemsCollectionViewController: VideoItemsModelDelegate {
    func didUpdateItems(model: VideoItemsModel) {
        collectionView?.reloadData()
    }
}
