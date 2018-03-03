import UIKit
import DGCollectionViewPaginableBehavior
import InteractiveSideMenu

class ActorCollectionViewController: ContentCollectionViewController, SideMenuItemContent {
    let viewModel = Container.ViewModel.videoItems()
    
    let behavior = DGCollectionViewPaginableBehavior()
    let control = UIRefreshControl()
    var refreshing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configNavBar()
        configCollectionView()
    }
    
    func configNavBar() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
    }

    func configCollectionView() {
        collectionView?.backgroundColor = .kpBackground
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
    
    @objc func refresh() {
        refreshing = true
        viewModel.refresh()
        refreshing = false
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) {
            self.collectionView?.reloadData()
        }
        control.endRefreshing()
    }
    
    // MARK: - Navigation
    static func storyboardInstance() -> ActorCollectionViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? ActorCollectionViewController
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                if let image = cell.posterImageView.image {
                    showDetailVC(with: viewModel.videoItems[indexPath.row], andImage: image)
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
}

// MARK: UICollectionViewDataSource
extension ActorCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.videoItems.count + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < viewModel.videoItems.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier, for: indexPath) as! LoadingItemCollectionViewCell
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        cell.set(item: viewModel.videoItems[indexPath.row])
        return cell
    }
}

// MARK: DGCollectionViewPaginableBehaviorDelegate
extension ActorCollectionViewController: DGCollectionViewPaginableBehaviorDelegate {
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
        return viewModel.countPerPage()
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        viewModel.loadVideoItems { [viewModel] (resultCount) in
            // Workaround to fix a bug in `DGCollectionViewPaginableBehavior` library
            let done = viewModel.page > viewModel.totalPages
            if done {
                // Force "done" call inside library
                completion(nil, 0)
            } else {
                completion(nil, resultCount ?? 0)
            }
        }
    }
}

// MARK: VideoItemsModel Delegate
extension ActorCollectionViewController: VideoItemsModelDelegate {
    func didUpdateItems(model: VideoItemsModel) {
        collectionView?.reloadData()
    }
}
