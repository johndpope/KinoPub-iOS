import UIKit
import InteractiveSideMenu
import CustomLoader
import AlamofireImage
import TMDBSwift
import LKAlertController
import GradientLoadingBar
import NTDownload
import NotificationBannerSwift

class DetailViewController: UIViewController, SideMenuItemContent {
    let model = Container.ViewModel.videoItem()
    private let bookmarksModel = Container.ViewModel.bookmarks()
    private let logViewsManager = Container.Manager.logViews
    private let mediaManager = Container.Manager.media
    
    // MARK: class properties
    var offsetHeaderStop: CGFloat = 176  // At this offset the Header stops its transformations
    var distanceWLabelHeader: CGFloat = 30 // The distance between the top of the screen and the top of the White Label
    let control = UIRefreshControl()
    var refreshing: Bool = false
    var image: UIImage?
    var downloader = ImageDownloader.default
    var navigationBarHide = true
    var titleColor = UIColor.clear
    var storedOffsets = [Int: CGFloat]()
    
    let gradientLoadingBar = GradientLoadingBar()
    
    // MARK: Outlet properties
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var posterView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var containerInMainView: UIView!
    @IBOutlet weak var ruTitleLabel: UILabel!
    @IBOutlet weak var enTitleLabel: UILabel!
    @IBOutlet weak var yearAndCountriesLabel: UILabel!
    @IBOutlet weak var watchedView: UIView!
    @IBOutlet weak var inAirView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var downloadButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TMDBConfig.apikey = Config.themoviedb.key
        
        navigationController?.navigationBar.clean(navigationBarHide)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: titleColor]
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }

        configView()
        configTableView()
        configTitle()
        delegates()
        configHeaderImageView()
        configPullToRefresh()
        configAfterRefresh()
        loadData()
        model.loadSimilarsVideo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.clean(navigationBarHide)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: titleColor]
        self.title = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configOffset()
    }
    
    override func viewWillLayoutSubviews() {
//        tableView.tableFooterView?.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(195))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.kpOffWhite]
        navigationController?.navigationBar.clean(false)
        super.viewWillDisappear(animated)
        endLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func sizeFooterToFit() {
        if let footerView = tableView.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            
            tableView.tableFooterView = footerView
        }
    }
    
    // MARK: - Configs
    func configView() {
        view.backgroundColor = .kpBackground
        watchedView.backgroundColor = .kpMarigold
        ruTitleLabel.textColor = .kpOffWhite
        enTitleLabel.textColor = .kpGreyishBrown
        yearAndCountriesLabel.textColor = .kpGreyishTwo
        inAirView.backgroundColor = .kpOffWhite
        episodeLabel.textColor = .kpOffWhite
        playButton.isHidden = true
        
        posterView.dropShadow(color: UIColor.black, opacity: 0.3, offSet: CGSize(width: 0, height: 2), radius: 6, scale: true)
    }
    
    func delegates() {
        tableView.delegate = self
        tableView.dataSource = self
        logViewsManager.addDelegate(delegate: self)
        model.delegate = self
        bookmarksModel.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(modelDidUpdate), name: NSNotification.Name.VideoItemDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name.PlayDidFinish, object: nil)
    }

    func configTableView() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
//        let fixWrapper = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 195))
//        let tableFooterView: TableFooterView = TableFooterView.fromNib()
//        tableFooterView.autoresizingMask = [.flexibleWidth]
//        fixWrapper.addSubview(tableFooterView)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UINib(nibName: String(describing: RatingTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: RatingTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ButtonsTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: ButtonsTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: DescTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: DescTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: InfoTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: InfoTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: SeasonTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: SeasonTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: TrailerTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: TrailerTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: CastTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: CastTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: SimilarTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: SimilarTableViewCell.self))
    }
    
    func configOffset() {
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            offsetHeaderStop = headerView.bounds.height - (navBarHeight + UIApplication.shared.statusBarFrame.height)
        }
        distanceWLabelHeader = UIApplication.shared.statusBarFrame.height + 10
    }
    
    func configPullToRefresh() {
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = .kpOffWhite
        if #available(iOS 10.0, *) {
            tableView.refreshControl = control
        } else {
            tableView.addSubview(control)
        }
    }
    
    func configTitle() {
        if let title = model.item.title?.components(separatedBy: " / ") {
            ruTitleLabel.attributedText = title[0].attributedString
            ruTitleLabel.numberOfLines = 0
            ruTitleLabel.addCharactersSpacing(0.4)
            self.title = title[0]
//            model.mediaItem.title = title[0]
            enTitleLabel.text = title.count > 1 ? title[1] : ""
            enTitleLabel.numberOfLines = 0
            enTitleLabel.addCharactersSpacing(-0.4)
        }
    }
    
    func configYearAndCountries() {
        if let year = model.item.year, let countries = model.item.countries {
            yearAndCountriesLabel.isHidden = false
            var yearAndCountries = "\(year)"
            for country in countries {
                yearAndCountries += ", \(country.title ?? "")"
            }
            yearAndCountriesLabel.attributedText = yearAndCountries.attributedString
            yearAndCountriesLabel.numberOfLines = 0
            yearAndCountriesLabel.addCharactersSpacing(-0.1)
        } else {
            yearAndCountriesLabel.isHidden = true
        }
    }
    
    func configureHeaderImage(with image: UIImage) {
        headerImageView.image = image
    }
    
    func configHeaderImageView() {
        headerImageView.image = image
        posterImageView.image = image
        headerView.clipsToBounds = true
    }
    
    func configPosterWatched() {
        if let watch = model.item?.videos?.first?.watching?.status, watch == Status.watched {
            watchedView.isHidden = false
        } else {
            watchedView.isHidden = true
        }
    }
    
    func configInAirView() {
        inAirView.isHidden = true
        guard model.item.type == ItemType.shows.rawValue ||
            model.item.type == ItemType.docuserial.rawValue ||
            model.item.type == ItemType.tvshows.rawValue else { return }
        inAirView.isHidden = model.item.finished! ? true : false
    }
    
    func configPlayButton() {
        playButton.isHidden = model.mediaItems.first?.url != nil ? false : true
    }
    
    func configEpisodeLabel() {
        if let season = model.mediaItems.first?.season, let number = model.mediaItems.first?.video {
            episodeLabel.attributedText = "Сезон \(season), серия \(number)".attributedString
//            episodeLabel.addLineHeight(min: 20, max: 20)
            
        } else {
            episodeLabel.text = ""
        }
    }
    
    func configBarButtonItems() {
        
    }
    
    func configAfterRefresh() {
        configYearAndCountries()
        receiveTMDBBackgroundImage()
        configPosterWatched()
        configInAirView()
        configPlayButton()
        configEpisodeLabel()
        tableView.reloadData()
    }
    
    func loadData() {
        beginLoad()
        model.loadItemsInfo()
    }
    
    func beginLoad() {
        refreshing = true
        gradientLoadingBar.show()
    }
    
    func endLoad() {
        gradientLoadingBar.hide()
        refreshing = false
    }
    
    @objc func refresh() {
        model.mediaItems.removeAll()
        loadData()
        configAfterRefresh()
        control.endRefreshing()
    }
    
    @objc func modelDidUpdate() {
        configAfterRefresh()
        endLoad()
    }
    
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
        return [.all]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .landscapeRight
        } else {
            return .portrait
        }
    }

}

extension DetailViewController {
    func setButtonImage(_ button: UIButton?, _ image: String) {
        button?.setImage(UIImage(named: image)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func receiveTMDBBackgroundImage() {
        if let imdbID = model.item.imdb {
            FindMDB.find(id: imdbID.fullIMDb, external_source: .imdb_id, completion: { [weak self] (_, results) in
                guard let strongSelf = self else { return }
                if let results = results {
                    if let urlString = results.movie_results.first?.backdrop_path, let tmdbID = results.movie_results.first?.id {
                        strongSelf.receiveTMDBMoreForMovie(with: tmdbID)
                        strongSelf.downloadImage(from: URL(string: Config.themoviedb.backdropBase + urlString)!)
                    } else if let urlString = results.tv_results.first?.backdrop_path, let tmdbID = results.tv_results.first?.id {
                        strongSelf.receiveTMDBMore(with: tmdbID)
                        strongSelf.downloadImage(from: URL(string: Config.themoviedb.backdropBase + urlString)!)
                    } else {
                        strongSelf.receivePosterImage()
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
            downloader.download(URLRequest(url: URL(string: poster)!), completion: { [weak self] (response) in
                guard let strongSelf = self else { return }
                if let image = response.result.value {
                    strongSelf.posterImageView.image = image
                    strongSelf.configureHeaderImage(with: image)
                }
            })
        }
    }
    
    func receiveTMDBMore(with tmdbID: Int) {
        TVMDB.tv(tvShowID: tmdbID, language: "ru") { [weak self] (_, series) in
            guard let strongSelf = self else { return }
            if let series = series {
                var networks = ""
                for network in series.networks {
                    if networks != "" { networks += ", " }
                    networks += network.name!
                }
                if networks != "" {
                    strongSelf.model.item.networks = networks
                }
            }
        }
    }
    
    func receiveTMDBMoreForMovie(with tmdbID: Int) {
        print(tmdbID)
        MovieMDB.movie(movieID: tmdbID, language: "ru") { [weak self] (_, movies) in
            guard let strongSelf = self else { return }
            if let movies = movies {
                guard let productionCompanies = movies.production_companies else { return }
                var networks = ""
                for network in productionCompanies {
                    if networks != "" { networks += ", " }
                    networks += network.name!
                }
                if networks != "" {
                    strongSelf.model.item.networks = networks
                }
            }
        }
    }
    
    func playVideo() {
        if model.mediaItems.first?.url != nil {
            if Config.shared.streamType != "hls4" {
                mediaManager.playVideo(mediaItems: [model.mediaItems.first!], userinfo: nil)
            } else {
                mediaManager.playVideo(mediaItems: model.mediaItems, userinfo: nil)
            }
        } else {
            Alert(title: "Ошибка", message: "Что-то пошло не так")
                .showOkay()
        }
    }
    
    func showQualitySelectAction(inView view: UIView? = nil, forButton button: UIBarButtonItem? = nil, play: Bool = false, season: Int? = nil) {
        let actionVC = ActionSheet(message: "Выберите качество").tint(.kpBlack)
        
        if let season = season {
            for (index, file) in (model.getSeason(season)?.episodes?.first?.files?.enumerated())! {
                actionVC.addAction(file.quality!, style: .default, handler: { [weak self] (action) in
                    guard let strongSelf = self else { return }
                    strongSelf.downloadSeason(season: season, index: index, quality: file.quality!)
                })
            }
        } else {
            guard let files = model.files else { return }
            for file in files {
                actionVC.addAction(file.quality!, style: .default, handler: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    if play {
                        var urlString = ""
                        if Config.shared.streamType == "http" {
                            urlString = (file.url?.http)!
                        } else if Config.shared.streamType == "hls" {
                            urlString = (file.url?.hls)!
                        }
                        strongSelf.model.mediaItems[0].url = URL(string: urlString)
                        strongSelf.playVideo()
                    } else {
                        strongSelf.showDownloadAction(with: (file.url?.http)!, quality: file.quality!, inView: view, forButton: button)
                    }
                })
            }
        }
        actionVC.addAction("Отменить", style: .cancel)
        if let button = button {
            actionVC.setBarButtonItem(button)
        } else if let view = view {
            actionVC.setPresentingSource(view)
        }
        actionVC.show()
        Helper.hapticGenerate(style: .medium)
    }
    
    func showDownloadAction(with url: String, quality: String, inView view: UIView? = nil, forButton button: UIBarButtonItem? = nil) {
        let name = (self.model.item?.title?.replacingOccurrences(of: " /", with: ";"))! + "; \(quality).mp4"
        let poster = self.model.item?.posters?.small
        Share().showActions(url: url, title: name, quality: quality, poster: poster!, inView: view, forButton: button)
    }
    
    func showSelectSeasonAction(inView view: UIView? = nil, forButton button: UIBarButtonItem? = nil) {
        guard let seasons = model.item.seasons else { return }
        let actionVC = ActionSheet().tint(.kpBlack)
        
        for (index, season) in seasons.enumerated() {
            actionVC.addAction("Сезон \(season.number ?? 00)", style: .default, handler: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.showQualitySelectAction(inView: view, forButton: button, season: index)
            })
        }
        actionVC.addAction("Отменить", style: .cancel)
        if let button = button {
            actionVC.setBarButtonItem(button)
        } else if let view = view {
            actionVC.setPresentingSource(view)
        }
        actionVC.show()
        Helper.hapticGenerate(style: .medium)
    }
    
    func downloadSeason(season: Int, index: Int, quality: String) {
        for episode in (model.getSeason(season)?.episodes)! {
            let name = (self.model.item?.title?.replacingOccurrences(of: " /", with: ";"))! + "; Сезон \(self.model.getSeason(season)?.number ?? 0), Эпизод \(episode.number ?? 0)."  + "\(quality).mp4"
            let poster = self.model.item?.posters?.small
            let url = episode.files?[index].url?.http
            NTDownloadManager.shared.addDownloadTask(urlString: url!, fileName: name, fileImage: poster)
        }
        let banner = StatusBarNotificationBanner(title: "Сезон добавлен в загрузки", style: .success)
        banner.duration = 1
        banner.show(queuePosition: .front)
    }
}

// MARK: - Buttons
extension DetailViewController {
    @IBAction func playButtonTapped(_ sender: Any) {
        if Config.shared.streamType == "hls4" {
            playVideo()
        } else {
            showQualitySelectAction(inView: playButton, play: true)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        var sharingActivities = [UIActivity]()
        sharingActivities.append(SafariActivity())
        let url = URL(string: "\(Config.shared.kinopubDomain)/item/view/\((model.item?.id)!)")
        let activityViewController = UIActivityViewController(activityItems: [url!], applicationActivities: sharingActivities)
        activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        activityViewController.view.tintColor = .kpBlack
        self.present(activityViewController, animated: true, completion: nil)
        Helper.hapticGenerate(style: .medium)
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        if model.item?.type == ItemType.shows.rawValue ||
            model.item?.type == ItemType.docuserial.rawValue ||
            model.item?.type == ItemType.tvshows.rawValue {
            showSelectSeasonAction(forButton: downloadButton)
        } else {
            showQualitySelectAction(forButton: downloadButton)
        }
    }
}

// MARK: - Navigation
extension DetailViewController {
    static func storyboardInstance() -> DetailViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? DetailViewController
    }
    
    @objc func showSeasonVC(_ sender: KPGestureRecognizer) {
        if let seasonVC = SeasonTableViewController.storyboardInstance() {
            if let indexPathRow = sender.indexPathRow {
                seasonVC.model = model
                seasonVC.indexPathSeason = indexPathRow
            }
            navigationController?.pushViewController(seasonVC, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        let offset = scrollView.contentOffset.y
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN  ----------
        if offset < 0 {
            let headerScaleFactor: CGFloat = -(offset) / headerView.bounds.height
            let headerSizeVariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height) / 2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizeVariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerView.layer.transform = headerTransform
        }
            // SCROLL UP/DOWN ----------
        else {
            // Header ----------
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offsetHeaderStop, -offset), 0)

//            let alignToNameLabel = -offset - gradientView.frame.origin.y + headerView.frame.height + offsetHeaderStop
//            navigationBarBackgroundAlpha = min(1.0, (offset - alignToNameLabel) / distanceWLabelHeader)
            
//            if (offset > (-headerView.height + CGFloat(offsetHeaderStop * 2))) {
//                let alpha = (offset - (-headerView.height + CGFloat(offsetHeaderStop * 2))) / CGFloat(offsetHeaderStop)
//                navigationBarBackgroundAlpha = alpha
//            } else {
//                navigationBarBackgroundAlpha = 0
//            }
            
            if offset >= offsetHeaderStop - gradientView.height {
                navigationBarHide = false
                title = ruTitleLabel.text
            } else {
                title = nil
                navigationBarHide = true
            }
        }
        // Apply Transformations
        headerView.layer.transform = headerTransform
        navigationController?.navigationBar.clean(navigationBarHide)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: titleColor]
    }
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            if model.item.trailer == nil {
                return 0
            }
            return 1
        } else if section == 4 {
            if let count = model.item?.seasons?.count {
                return count
            } else if let count = model.item?.videos?.count, count > 1 {
                return 1
            }
            return 0
        } else if section == 6 {
            if model.item?.cast == "", model.item?.director == "" {
                return 0
            }
            return 1
        } else if section == 7 {
            if model.similarItems.count > 0 {
                return 1
            }
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RatingTableViewCell.self), for: indexPath) as! RatingTableViewCell
            cell.selectionStyle = .none
            cell.configure(withItem: model.item!)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ButtonsTableViewCell.self), for: indexPath) as! ButtonsTableViewCell
            cell.selectionStyle = .none
            cell.config(withModel: model, bookmarksModel: bookmarksModel)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DescTableViewCell.self), for: indexPath) as! DescTableViewCell
            cell.selectionStyle = .none
            cell.configure(withItem: model.item!)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InfoTableViewCell.self), for: indexPath) as! InfoTableViewCell
            cell.selectionStyle = .none
            cell.configure(with: model.item!)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: CastTableViewCell.reuseIdentifier, for: indexPath) as! CastTableViewCell
            cell.selectionStyle = .none
            cell.configure(with: model.item?.cast, directors: model.item?.director)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SeasonTableViewCell.self), for: indexPath) as! SeasonTableViewCell
            cell.selectionStyle = .none
            cell.config(withModel: model, index: indexPath.row)
            let tap = KPGestureRecognizer(target: self, action: #selector(showSeasonVC(_:)))
            cell.addGestureRecognizer(tap)
            tap.indexPathRow = indexPath.row
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrailerTableViewCell.self), for: indexPath) as! TrailerTableViewCell
            cell.selectionStyle = .none
            cell.config(withId: (model.item.trailer?.id)!)
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SimilarTableViewCell.self), for: indexPath) as! SimilarTableViewCell
            cell.selectionStyle = .none
            cell.config(withModel: model)
            return cell
        default:
            return UITableViewCell()
        }
        
    }
}

// MARK: - UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? SeasonTableViewCell else { return }
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? -15
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? SeasonTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}

// MARK: - VideoItemModelDelegate
extension DetailViewController: VideoItemModelDelegate {
    func didUpdateSimilar() {
        tableView.reloadData()
    }
}

// MARK: - BookmarksModelDelegate, LogViewsManagerDelegate
extension DetailViewController: BookmarksModelDelegate, LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager) {
        refresh()
    }
    
    func didAddedBookmarks() {
        refresh()
    }
    
    func didToggledWatchlist(toggled: Bool) {
        model.item?.inWatchlist = toggled
        refresh()
    }
}
