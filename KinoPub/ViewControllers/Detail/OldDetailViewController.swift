import UIKit
import AlamofireImage
//import FXBlurView
import EZPlayer
import SwiftyUserDefaults
import TMDBSwift
import SnapKit
import LKAlertController
import CustomLoader
import InteractiveSideMenu
import NTDownload
import NotificationBannerSwift

class OldDetailViewController: UIViewController, SideMenuItemContent {
    let model = Container.ViewModel.videoItem()
    fileprivate let bookmarksModel = Container.ViewModel.bookmarks()
    fileprivate let logViewsManager = Container.Manager.logViews

    fileprivate let mediaManager = Container.Manager.media
    
    var offsetHeaderStop: CGFloat = 176  // At this offset the Header stops its transformations
    var distanceWLabelHeader: CGFloat = 30 // The distance between the top of the screen and the top of the White Label
    // MARK: Outlet properties
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ruTitleLabel: UILabel!
    @IBOutlet weak var enTitleLabel: UILabel!
    @IBOutlet weak var segmentedView: UIView!

    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    // MARK: class properties
    var image: UIImage?

    let control = UIRefreshControl()
    var refreshing: Bool = false
    var cleaned: Bool = false
    var headerBlurImageView: UIImageView!
    var headerImageView: FadeImageView!
    var buttonView: UIView!
    var playButton: UIButton!
    let downloader = ImageDownloader()
    var episodeLabel: BorderedLabel!

    // MARK: Table properties
    var ratingCell: RatingTableViewCell!
    var descCell: DescTableViewCell!
    var infoCell: InfoTableViewCell!
    var seasonCell: SeasonTableViewCell?
    var castCell: CastTableViewCell!

    // MARK: The view
    override func viewDidLoad() {
        super.viewDidLoad()
        configHeaderHeight()
        configOffset()

        view.backgroundColor = UIColor.kpBackground

        logViewsManager.addDelegate(delegate: self)
        model.delegate = self
        bookmarksModel.delegate = self
        mediaManager.delegate = self

        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = .kpOffWhite
        if #available(iOS 10.0, *) {
            tableView.refreshControl = control
        } else {
            tableView.addSubview(control)
        }
        
        
        configTableView()
        configHeaderView()
        configTitle()
        loadData()
        config()
        
        navigationController?.navigationBar.tintColor = UIColor.kpLightGreen
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Share-50")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(shareLink(_:)))//UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareLink))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.kpLightGreen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cleanNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanNavBar()
        endLoad()
    }

    override func viewDidLayoutSubviews() {
        configHeaderHeight()
        configOffset()
        let frame = CGRect(x: headerView.bounds.origin.x, y: headerView.bounds.origin.y, width: view.bounds.width, height: headerView.bounds.height)
        headerImageView.frame = frame
        headerBlurImageView.frame = frame
        
        buttonView.center = CGPoint(x: headerImageView.frame.width / 2, y: headerImageView.frame.height / 2)
        playButton.frame = buttonView.frame
    }
    
    func configHeaderHeight() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            headerViewHeightConstraint.constant = 420
//            self.view.layoutIfNeeded()
            headerView.height = 420
        }
    }
    
    func configOffset() {
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            offsetHeaderStop = headerView.height - (navBarHeight + UIApplication.shared.statusBarFrame.height)
        }
        distanceWLabelHeader = UIApplication.shared.statusBarFrame.height + 10
    }

    @objc func refresh() {
        model.mediaItems.removeAll()
        loadData()
        config()
        control.endRefreshing()
    }
    
    func beginLoad() {
        refreshing = true
        _ = LoadingView.system(withStyle: .whiteLarge).show(inView: headerImageView)
    }
    
    func endLoad() {
        headerImageView.removeLoadingViews(animated: true)
        refreshing = false
    }

    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: String(describing:RatingTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing:RatingTableViewCell.self))
        tableView.register(UINib(nibName: String(describing:DescTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing:DescTableViewCell.self))
        tableView.register(UINib(nibName: String(describing:InfoTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: InfoTableViewCell.self))
        tableView.register(UINib(nibName: String(describing:CastTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: CastTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing:SeasonTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: SeasonTableViewCell.self))
    }

    func cleanNavBar() {
        !cleaned ? navigationController?.navigationBar.clean(true) : navigationController?.navigationBar.clean(false)
        cleaned.toggle()
    }

    // Header - Image
    func configHeaderView() {
        let frame = CGRect(x: headerView.bounds.origin.x, y: headerView.bounds.origin.y, width: view.bounds.width, height: headerView.bounds.height)
        headerImageView = FadeImageView(frame: frame)
        headerBlurImageView = UIImageView(frame: frame)

        headerImageView.image = image
        posterImageView.image = image
//        headerBlurImageView.image = image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)

        headerImageView.contentMode = .scaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)

        headerBlurImageView.contentMode = .scaleAspectFill
        headerBlurImageView.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        buttonView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: headerImageView.frame.height / 2,
                                              height: headerImageView.frame.height / 2
        ))
        buttonView.center = CGPoint(x: headerImageView.frame.width / 2, y: headerImageView.frame.height / 2)

        buttonView.layer.cornerRadius = buttonView.frame.width / 2
        buttonView.clipsToBounds = true
        buttonView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        buttonView.isHidden = true

        playButton = UIButton(frame: buttonView.frame)
        playButton.isHidden = true
        setButtonImage(playButton, "Play Filled-100")
        playButton.tintColor = UIColor.kpLightGreen
        playButton.addTarget(self, action: #selector(playButtonAction), for: UIControlEvents.touchUpInside)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(playButtonLongTap(_:)))
        playButton.addGestureRecognizer(longGesture)
        headerView.isUserInteractionEnabled = true
        posterImageView.isUserInteractionEnabled = true
        
        headerView.insertSubview(buttonView, belowSubview: headerBlurImageView)
        headerView.insertSubview(playButton, belowSubview: headerLabel)

        headerView.clipsToBounds = true
        
        configEpisodeLabel()
    }
    
    func configTitle() {
        if let title = model.item.title?.components(separatedBy: " / ") {
            ruTitleLabel.text = title[0]
            headerLabel.text = title[0]
            model.mediaItem.title = title[0]
            enTitleLabel.text = title.count > 1 ? title[1] : ""
        }
    }
    
    func loadData() {
        beginLoad()
        model.loadItemsInfo()
    }
    
    func config() {
        model.mediaItem.id = model.item.id
        configWatchlistButton()
        configBookmarkButton()
        configDownloadButton()
        receiveTMDBBackgroundImage()
        configPosterWatched()
        tableView?.reloadData()
    }

    func receiveTMDBBackgroundImage() {
        if let imdbID = model.item.imdb {
            TMDBConfig.apikey = Config.themoviedb.key
            FindMDB.find(id: imdbID.fullIMDb, external_source: .imdb_id, completion: { (_, results) in
                if let results = results {
                    if let urlString = results.movie_results.first?.backdrop_path {
                        //                            self.receiveTMDBMore(with: tmdbID)
                        self.downloadImage(from: URL(string: Config.themoviedb.backdropBase + urlString)!)
                    } else if let urlString = results.tv_results.first?.backdrop_path, let tmdbID = results.tv_results.first?.id {
                        self.receiveTMDBMore(with: tmdbID)
                        self.downloadImage(from: URL(string: Config.themoviedb.backdropBase + urlString)!)
                    } else {
                        self.receivePosterImage()
                    }
                }
            })
        } else {
            receivePosterImage()
        }
    }

    func downloadImage(from url: URL) {
        downloader.download(URLRequest(url: url), completion: { [weak self] (response) in
            guard let strongSelf = self else { return }
            if let image = response.result.value {
                strongSelf.configureHeaderImage(with: image)
                return
            }
        })
    }
    
    func receivePosterImage() {
        if let poster = model.item.posters?.big {
            downloader.download(URLRequest(url: URL(string: poster)!), completion: { (response) in
                if let image = response.result.value {
                    self.posterImageView.image = image
                    self.configureHeaderImage(with: image)
                }
            })
        }
    }
    
    func configureHeaderImage(with image: UIImage) {
        headerImageView.image = image
//        headerBlurImageView.image = image.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
    }
    
    func receiveTMDBMore(with tmdbID: Int) {
        TVMDB.tv( tvShowID: tmdbID, language: "ru") { (_, series) in
            if let series = series {
                let networkLabel = BorderedLabel()
                self.headerImageView.addSubview(networkLabel)
                networkLabel.snp.makeConstraints({ (make) in
                    make.right.equalTo(self.headerImageView.snp.right).offset(-5)
                    make.bottom.equalTo(self.headerImageView.snp.bottom).offset(-8)
                })
                networkLabel.text = series.networks.first?.name
                networkLabel.textColor = UIColor.white
                networkLabel.font = networkLabel.font.withSize(18)
                networkLabel.layer.borderWidth = 1.0
                networkLabel.layer.cornerRadius = 8
                networkLabel.layer.borderColor = UIColor.white.cgColor
            }
        }
    }

    
    func configPosterWatched() {
        posterImageView?.removeSubviews()
        if let watch = model.item?.videos?.first?.watching?.status, watch == Status.watched {
            let posterWatchedImageView = UIImageView(image: UIImage(named: "poster_watched"))
            posterWatchedImageView.frame = CGRect(x: posterImageView.bounds.origin.x, y: posterImageView.bounds.origin.y, width: posterImageView.frame.width, height: posterImageView.frame.height)
            posterImageView.addSubview(posterWatchedImageView)
        }
    }

    func configWatchlistButton() {
        watchlistButton?.tintColor = UIColor.kpLightGreen
        (model.item?.inWatchlist)! ? setButtonImage(watchlistButton, "btn-unwatch") : setButtonImage(watchlistButton, "btn-watch")
        watchlistButton.isEnabled = true
        
        if let watch = model.item?.videos?.first?.watching?.status {
            switch watch {
            case Status.watched:
                setButtonImage(watchlistButton, "btn-unwatch")
            default:
                setButtonImage(watchlistButton, "btn-watch")
            }
        }
    }
    
    func setButtonImage(_ button: UIButton?, _ image: String) {
        button?.setImage(UIImage(named: image)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func configBookmarkButton() {
            bookmarkButton?.tintColor = UIColor.kpLightGreen
            if let _itemFolders = model.item.bookmarks, _itemFolders.count > 0 {
                setButtonImage(bookmarkButton, "Bookmark Ribbon Filled-50")
                let str = _itemFolders.count > 1 ? "... " : " "
                bookmarkButton?.setTitle(" " + _itemFolders[0].title! + str, for: .normal)
                
                bookmarkButton?.titleLabel?.layer.borderWidth = 1.0
                bookmarkButton?.titleLabel?.layer.cornerRadius = 8
                bookmarkButton?.titleLabel?.layer.borderColor = UIColor.kpLightGreen.cgColor
            } else {
                setButtonImage(bookmarkButton, "Bookmark Ribbon-50")
                bookmarkButton?.setTitle(nil, for: .normal)
            }
    }
    
    func configDownloadButton() {
        if model.item?.type == ItemType.shows.rawValue || model.item?.type == ItemType.docuserial.rawValue || model.item?.type == ItemType.tvshows.rawValue {
            downloadButton?.isHidden = true
        } else {
            downloadButton?.isHidden = false
        }
        downloadButton?.tintColor = UIColor.kpLightGreen
        setButtonImage(downloadButton, "Download-50")
    }
    
    func configEpisodeLabel() {
        episodeLabel = BorderedLabel()
        headerImageView.addSubview(episodeLabel)
        episodeLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.headerImageView.snp.left).offset(5)
            make.bottom.equalTo(self.headerImageView.snp.bottom).offset(-8)
        })
        episodeLabel.textColor = UIColor.white
        episodeLabel.font = episodeLabel.font.withSize(18)
        episodeLabel.layer.borderWidth = 1.0
        episodeLabel.layer.cornerRadius = 8
        episodeLabel.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func shareLink(_ sender: UIBarButtonItem) {
        let url = URL(string: "\(Config.shared.kinopubDomain)/item/view/\((model.item?.id)!)")
        let activityViewController = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showDownloadAction(with url: String, quality: String, inView view: UIView) {
        let name = (self.model.item?.title?.replacingOccurrences(of: "/ ", with: "("))! + ") (\(quality)).mp4"
        let poster = self.model.item?.posters?.small
        Share().showActions(url: url, title: name, quality: quality, poster: poster!, inView: view)
    }
    
    func showBookmarkFolders() {
        _ = LoadingView.system(withStyle: .white).show(inView: bookmarkButton)
        bookmarksModel.loadBookmarks { [weak self] (bookmarks) in
            guard let strongSelf = self else { return }
            let action = ActionSheet(message: "Выберите папку")
            for folder in bookmarks! {
                var folderTitle = folder.title!
                var style: UIAlertActionStyle = .default
                for itemFolder in strongSelf.model.item.bookmarks! {
                    if itemFolder.title == folder.title {
                        folderTitle = "✓ " + folderTitle
                        style = .destructive
                    }
                }
                action.addAction(folderTitle, style: style, handler: { (_) in
                    strongSelf.bookmarksModel.toggleItemToFolder(item: String((strongSelf.model.item.id)!), folder: String((folder.id)!))
                })
            }
            action.addAction("Отмена", style: .cancel)
            action.setPresentingSource(strongSelf.bookmarkButton)
            action.show()
            strongSelf.bookmarkButton.removeLoadingViews(animated: true)
        }
    }
    
    func showQualitySelectAction(inView view: UIView, play: Bool = false) {
        let actionVC = ActionSheet(message: "Выберите качество")
        guard let files = model.files else { return }
        for file in files {
            actionVC.addAction(file.quality!, style: .default, handler: { (_) in
                if play {
                    var urlString = ""
                    if Config.shared.streamType == "http" {
                        urlString = (file.url?.http)!
                    } else if Config.shared.streamType == "hls" {
                        urlString = (file.url?.hls)!
                    }
                    self.model.mediaItem.url = URL(string: urlString)
                    self.playVideo()
                } else {
                    self.showDownloadAction(with: (file.url?.http)!, quality: file.quality!, inView: view)
                }
            })
        }
        actionVC.addAction("Отменить", style: .cancel)
        actionVC.setPresentingSource(view)
        actionVC.show()
    }
    
    func playVideo() {
        if model.mediaItem.url != nil {
            if let _watchingTime = model.item?.videos?.first?.watching?.time, model.item?.subtype != ItemType.ItemSubtype.multi.rawValue {
                model.watchingTime = _watchingTime
            }
            if model.watchingTime > 0 {
                mediaManager.playVideo(mediaItems: model.mediaItems, userinfo: ["watchingTime": TimeInterval(model.watchingTime)])
            } else {
                mediaManager.playVideo(mediaItems: model.mediaItems, userinfo: nil)
            }
        } else {
            Alert(title: "Ошибка", message: "Что-то пошло не так")
                .showOkay()
        }
    }

    // MARK: Buttons
    @objc func playButtonAction(_ sender: UIButton) {
        if Config.shared.streamType == "hls4" {
            playVideo()
        } else {
            showQualitySelectAction(inView: playButton, play: true)
        }
    }

    @objc func playButtonLongTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            showQualitySelectAction(inView: playButton)        }
    }

    @IBAction func tapInWatchlistButton(_ sender: UIButton) {
        if model.item?.type == ItemType.shows.rawValue || model.item?.type == ItemType.docuserial.rawValue || model.item?.type == ItemType.tvshows.rawValue {
            logViewsManager.changeWatchlist(id: model.item.id?.string ?? "")
        } else {
            logViewsManager.changeWatchingStatus(id: model.item?.id ?? 0, video: nil, season: 0, status: nil)
        }
    }

    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        showBookmarkFolders()
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        showQualitySelectAction(inView: downloadButton)
    }
    
    // MARK: Navigation
    static func storyboardInstance() -> OldDetailViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? OldDetailViewController
    }
    
    @objc func showSeasonVC(_ sender: KPGestureRecognizer) {
        if let seasonVC = SeasonTableViewController.storyboardInstance() {
//            if let indexPathRow = sender.indexPathRow {
                seasonVC.model.item = model.item
//                seasonVC.model.indexPathSeason = indexPathRow
//            }
            navigationController?.pushViewController(seasonVC, animated: true)
        }
    }

    // MARK: Interface buttons

    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return .landscape
//        }else {
//            return .portrait
//        }
        return UIInterfaceOrientationMask.all
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .landscapeRight
        } else {
            return .portrait
        }
    }

    // MARK: - StatusBar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIColor.averageColor(fromImage: image).isLight() ? .default : .lightContent
    }

}

// MARK: Table View Data Source
extension OldDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            if let count = model.item?.seasons?.count {
                return count
            } else if let count = model.item?.videos?.count, count > 1 {
                return 1
            }
            return 0
        } else if section == 3 {
            if model.item?.cast == "", model.item?.director == "" {
                return 0
            }
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            ratingCell = tableView.dequeueReusableCell(withIdentifier: String(describing:RatingTableViewCell.self), for: indexPath) as! RatingTableViewCell
            ratingCell.selectionStyle = .none
            ratingCell.configure(withItem: model.item!)
            return ratingCell
        case 1:
            descCell = tableView.dequeueReusableCell(withIdentifier: String(describing:DescTableViewCell.self), for: indexPath) as! DescTableViewCell
            descCell.selectionStyle = .none
            descCell.configure(withItem: model.item!)
            return descCell
        case 2:
            infoCell = tableView.dequeueReusableCell(withIdentifier: String(describing: InfoTableViewCell.self), for: indexPath) as! InfoTableViewCell
            infoCell.selectionStyle = .none
            infoCell.configure(with: model.item!)
            return infoCell
        case 3:
            castCell = tableView.dequeueReusableCell(withIdentifier: CastTableViewCell.reuseIdentifier, for: indexPath) as! CastTableViewCell
            castCell.selectionStyle = .none
            castCell.configure(with: model.item?.cast, directors: model.item?.director)
            return castCell
        case 4:
            seasonCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SeasonTableViewCell.self), for: indexPath) as? SeasonTableViewCell
            seasonCell?.selectionStyle = .none
            seasonCell?.config(withModel: model, index: indexPath.row)
            let tap = KPGestureRecognizer(target: self, action: #selector(showSeasonVC(_:)))
            seasonCell?.addGestureRecognizer(tap)
            tap.indexPathRow = indexPath.row
            
            return seasonCell!
        default:
            print("!EMPTY!")
            return UITableViewCell()
        }
        
    }
}

//MARK: Table View Delegate
extension OldDetailViewController: UITableViewDelegate {
    
}

// MARK: Scroll view delegate
extension OldDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        
        var headerTrasform = CATransform3DIdentity
        
        // PULL DOWN  ----------
        if offset < 0 {
            let headerScaleFactor: CGFloat = -(offset) / headerView.bounds.height
            let headerSizeVariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height) / 2
            headerTrasform = CATransform3DTranslate(headerTrasform, 0, headerSizeVariation, 0)
            headerTrasform = CATransform3DScale(headerTrasform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
        }
            // SCROLL UP/DOWN ----------
        else {
            // Header ----------
            headerTrasform = CATransform3DTranslate(headerTrasform, 0, max(-offsetHeaderStop, -offset), 0)
            
            // ---------- Label
            let alignToNameLabel = -offset + ruTitleLabel.frame.origin.y + headerView.frame.height + offsetHeaderStop
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distanceWLabelHeader + offsetHeaderStop))
            
            // ---------- Blur
            headerBlurImageView?.alpha = min(1.0, (offset - alignToNameLabel) / distanceWLabelHeader)
            
            if offset <= offsetHeaderStop {
                headerView.layer.zPosition = 2
            }
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTrasform
        
        // Segmented View
        let segmentViewOffset = mainView.frame.height - segmentedView.frame.height - offset
        
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offsetHeaderStop), 0)
        
        segmentedView.layer.transform = segmentTransform
        
        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }
}

extension OldDetailViewController: VideoItemModelDelegate {
    func didUpdateSimilar() {
        
    }
    
    func didUpdateItem(model: VideoItemModel, error: Error?) {
        if let error = error {
            print(error)
        } else if model.mediaItem.url != nil {
            buttonView.isHidden = false
            playButton.isHidden = false
            if let season = model.mediaItems.first?.season, let number = model.mediaItems.first?.video {
                episodeLabel.text = "s\(season)e\(number)"
            } else {
                episodeLabel.text = ""
            }
        }
        config()
        endLoad()
    }
}

extension OldDetailViewController: BookmarksModelDelegate, LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager) {
        refresh()
    }
    
    func didAddedBookmarks() {
        refresh()
    }

    func didToggledWatchlist(toggled: Bool) {
        model.item?.inWatchlist = toggled
        configWatchlistButton()
    }
}

extension OldDetailViewController: MediaManagerDelegate {
    func playDidFinish(model: MediaManager) {
        refresh()
    }
}

