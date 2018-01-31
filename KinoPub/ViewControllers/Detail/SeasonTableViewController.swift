import UIKit
import SwiftyUserDefaults
import LKAlertController
import NTDownload
import NotificationBannerSwift
import GradientLoadingBar

class SeasonTableViewController: UITableViewController {
    var model: VideoItemModel!
    fileprivate let logViewsManager = Container.Manager.logViews
    fileprivate let mediaManager = Container.Manager.media
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    let control = UIRefreshControl()
    var refreshing: Bool = false
    var indexPathSeason: Int!
    let gradientLoadingBar = GradientLoadingBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(endLoad), name: NSNotification.Name.VideoItemDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name.PlayDidFinish, object: nil)
        if let title = model.getSeason(indexPathSeason)?.title, title != "" {
            self.title = title
        } else {
            self.title = "Сезон \(model.getSeason(indexPathSeason)?.number ?? 0)"
        }

        logViewsManager.addDelegate(delegate: self)
        
        configTable()
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            tableView.refreshControl = control
        } else {
            tableView.addSubview(control)
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func config() {
        model.loadItemsInfo()
    }
    
    func configTable() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.kpBackground
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .kpGreyishBrown
        tableView.register(UINib(nibName: String(describing: EpisodeTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: EpisodeTableViewCell.self))
    }
    
    @objc func refresh() {
        refreshing = true
        config()
    }
    
    func beginLoad() {
        refreshing = true
        gradientLoadingBar.show()
    }
    
    @objc func endLoad() {
        tableView.reloadData()
        refreshing = false
        control.endRefreshing()
        gradientLoadingBar.hide()
    }

    @IBAction func watchButtonTap(_ sender: UIBarButtonItem) {
        showMoreAction()
    }
    
    func showMoreAction() {
        ActionSheet()
        .tint(.kpBlack)
        .addAction("Отметить весь сезон", style: .default) { (_) in
            self.watchAllSeason()
        }
        .addAction("Скачать весь сезон", style: .default) { (_) in
            self.showDownloadAlert(season: true)
        }
        .addAction("Отмена", style: .cancel)
        .setBarButtonItem(moreButton)
        .show()
    }
    
    func watchAllSeason() {
        Alert(message: "Отметить весь сезон?")
            .tint(.kpBlack)
            .addAction("Нет", style: .cancel)
            .addAction("Да", style: .default) { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.logViewsManager.changeWatchingStatus(id: strongSelf.model.item?.id ?? 0, video: nil, season: strongSelf.model.getSeason(strongSelf.indexPathSeason)?.number ?? 0, status: nil)
            }
            .show(animated: true)
    }
    
    func downloadSeason(index: Int, quality: String) {
        for episode in (model.getSeason(indexPathSeason)?.episodes)! {
            let name = (self.model.item?.title?.replacingOccurrences(of: "/ ", with: "("))! + ") (s\(self.model.getSeason(indexPathSeason)?.number ?? 0)e\(episode.number ?? 0))"  + " (\(quality)).mp4"
            let poster = self.model.item?.posters?.small
            let url = episode.files?[index].url?.http
            NTDownloadManager.shared.addDownloadTask(urlString: url!, fileName: name, fileImage: poster)
        }
        let banner = StatusBarNotificationBanner(title: "Сезон добавлен в загрузки", style: .success)
        banner.duration = 1
        banner.show(queuePosition: .front)
    }
    
    func showDownloadAlert(at indexPath: IndexPath? = nil, episode: Episodes? = nil, season: Bool = false) {
        let actionVC = ActionSheet(message: "Выберите качество")
        actionVC.tint(.kpBlack)
        if episode != nil {
            for file in (episode?.files)! {
                actionVC.addAction(file.quality!, style: .default, handler: { (_) in
                    self.showDownloadAction(with: (file.url?.http)!, episode: episode!, quality: file.quality!, at: indexPath!)
                })
            }
            actionVC.setPresentingSource(self.tableView.cellForRow(at: indexPath!)!)
        } else if season {
            for (index, file) in (self.model.getSeason(indexPathSeason)?.episodes?.first?.files?.enumerated())! {
                actionVC.addAction(file.quality!, style: .default, handler: { (action) in
                    self.downloadSeason(index: index, quality: file.quality!)
                })
            }
            actionVC.setBarButtonItem(moreButton)
        }
        actionVC.addAction("Отменить", style: .cancel)
        actionVC.show()
    }
    
    func showDownloadAction(with url: String, episode: Episodes, quality: String, at indexPath: IndexPath) {
        let name = (self.model.item?.title?.replacingOccurrences(of: " /", with: ";"))! + "; Сезон \(self.model.getSeason(indexPathSeason)?.number ?? 0), Эпизод \(episode.number ?? 0)."  + "\(quality).mp4"
        let poster = self.model.item?.posters?.small
        Share().showActions(url: url, title: name, quality: quality, poster: poster!, inView: self.tableView.cellForRow(at: indexPath)!)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if model.item?.videos != nil {
            return model.item.videos?.count ?? 0
        }
        return model.getSeason(indexPathSeason)?.episodes?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EpisodeTableViewCell.self), for: indexPath) as! EpisodeTableViewCell
        cell.config(withModel: model, episode: indexPath.row, inSeason: indexPathSeason)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let watchAction = UITableViewRowAction(style: .default, title: "Отметить") { [weak self] (_, indexPath) in
            guard let strongSelf = self else { return }
            let video = strongSelf.model.getSeason(strongSelf.indexPathSeason)?.episodes?[indexPath.row].number ?? strongSelf.model.item?.videos?[indexPath.row].number
            strongSelf.logViewsManager.changeWatchingStatus(id: (strongSelf.model.item?.id)!, video: video, season: strongSelf.model.getSeason(strongSelf.indexPathSeason)?.number ?? 0, status: nil)
        }
        
        watchAction.backgroundColor = .kpGreyishTwo
        
        return [watchAction]
    }
    

    // MARK: - StatusBar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Navigation
    static func storyboardInstance() -> SeasonTableViewController? {
        let storyboard = UIStoryboard(name: String(describing: DetailViewController.self), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? SeasonTableViewController
    }

}

extension SeasonTableViewController: LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager) {
        refresh()
    }
}
