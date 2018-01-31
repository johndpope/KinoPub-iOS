import UIKit
import DGCollectionViewPaginableBehavior
import LKAlertController
import CustomLoader

class BookmarkCollectionViewController: ContentCollectionViewController {
    let viewModel = Container.ViewModel.bookmarks()
    
    let behavior = DGCollectionViewPaginableBehavior()
    let control = UIRefreshControl()
    var refreshing: Bool = false
    var editingFolder: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        model.delegate = self
        
        collectionView?.backgroundColor = UIColor.kpBackground
        title = viewModel.folder?.title
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillLayoutSubviews() {
        if editingFolder {
            for cell in (collectionView?.visibleCells)! {
                (cell as? ItemCollectionViewCell)?.editBookmarkView.isHidden = false
            }
        } else {
            for cell in (collectionView?.visibleCells)! {
                (cell as? ItemCollectionViewCell)?.editBookmarkView.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @objc func tap(sender: UITapGestureRecognizer) {
        guard !editingFolder else { return }
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                if let image = cell.posterImageView.image {
                    showDetailVC(with: viewModel.items[indexPath.row], andImage: image)
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
    
    func removeFromBookmark(item: Item, indexPath: IndexPath) {
        viewModel.items.remove(at: indexPath.row)
        collectionView?.deleteItems(at: [indexPath])
        viewModel.removeItemFromFolder(item: String((item.id)!), folder: String((viewModel.folder?.id)!))
        collectionView?.reloadData()
    }
    
    func showBookmarkFolders(_ indexPath: IndexPath) {
        let cell = collectionView?.cellForItem(at: indexPath) as! ItemCollectionViewCell
        _ = LoadingView.system(withStyle: .white).show(inView: cell.moveFromBookmarkButton)
        viewModel.loadBookmarks { [weak self] (bookmarks) in
            guard let strongSelf = self else { return }
            let action = ActionSheet(message: "Выберите папку").tint(.kpBlack)
            
            for folder in bookmarks! {
                if folder.title == strongSelf.title { continue }
                action.addAction(folder.title!, style: .default, handler: { (_) in
                    strongSelf.viewModel.toggleItemToFolder(item: String((strongSelf.viewModel.items[indexPath.row].id)!), folder: String((folder.id)!))
                    strongSelf.removeFromBookmark(item: strongSelf.viewModel.items[indexPath.row], indexPath: indexPath)
                })
            }
            action.addAction("Отмена", style: .cancel)
            action.setPresentingSource(cell.moveFromBookmarkButton)
            action.show()
            cell.moveFromBookmarkButton.removeLoadingViews(animated: true)
        }
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if !editingFolder {
            editingFolder = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped(_:)))
            navigationItem.rightBarButtonItem?.tintColor = .kpMarigold
        } else {
            editingFolder = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
            navigationItem.rightBarButtonItem?.tintColor = .kpOffWhite
        }
        collectionView?.setNeedsLayout()
    }
    
    // MARK: - Navigation

    static func storyboardInstance() -> BookmarkCollectionViewController? {
        let storyboard = UIStoryboard(name: "Bookmarks", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? BookmarkCollectionViewController
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

extension BookmarkCollectionViewController: ItemCollectionViewCellDelegate {
    func didPressDeleteButton(_ item: Item) {
        guard let index = viewModel.items.index(where: { $0 === item }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        Alert(message: "Удалить?")
            .tint(.kpBlack)
            .addAction("Отмена", style: .cancel)
            .addAction("Да", style: .default, handler: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.removeFromBookmark(item: strongSelf.viewModel.items[indexPath.row], indexPath: indexPath)
            })
            .show()
    }
    
    func didPressMoveButton(_ item: Item) {
        guard let index = viewModel.items.index(where: { $0 === item }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        showBookmarkFolders(indexPath)
    }
}

// MARK: UICollectionViewDataSource
extension BookmarkCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (viewModel.items.count) + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < viewModel.items.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier, for: indexPath) as! LoadingItemCollectionViewCell
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        cell.set(item: viewModel.items[indexPath.row])
        cell.delegate = self
//        cell.deleteFromBookmarkButton.tag = indexPath.row
//        cell.moveFromBookmarkButton.tag = indexPath.row
        cell.tag = indexPath.row
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension BookmarkCollectionViewController {
    
}

extension BookmarkCollectionViewController: DGCollectionViewPaginableBehaviorDelegate {
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
        viewModel.loadBookmarkItems { (count) in
            completion(nil, count ?? 0)
        }
    }
}

//extension BookmarkCollectionViewController: BookmarksModelDelegate {
//    func didUpdateItems(model: BookmarksModel) {
//        collectionView?.reloadData()
//    }
//}

