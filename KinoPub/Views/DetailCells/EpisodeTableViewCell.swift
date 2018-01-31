import UIKit
import AlamofireImage
import LKAlertController
import NTDownload
import NotificationBannerSwift

class EpisodeTableViewCell: UITableViewCell {
    private var model: VideoItemModel!
    fileprivate let mediaManager = Container.Manager.media
    fileprivate let logViewsManager = Container.Manager.logViews
    
    var indexPathSeason: Int!
    var indexPathEpisode: Int!
    var mediaItem = MediaItem()

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var episodeNumberLabel: UILabel!
    @IBOutlet weak var ruTitleLabel: UILabel!
    @IBOutlet weak var enTitleLabel: UILabel!
    @IBOutlet weak var watchedLabel: UILabel!
    @IBOutlet weak var watchedView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var watchButton: UIButton!
    
    @IBAction func watchButtonTapped(_ sender: Any) {
        changeWatchStatus()
    }
    @IBAction func downloadButtonTapped(_ sender: Any) {
        showDownloadAlert()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configView() {
        episodeNumberLabel.textColor = .kpGreyishBrown
        ruTitleLabel.textColor = .kpOffWhite
        enTitleLabel.textColor = .kpGreyishBrown
        watchedView.backgroundColor = .kpMarigold
        watchedLabel.textColor = .kpBlack
        downloadButton.setImage(UIImage(named: "Download")?.withRenderingMode(.alwaysTemplate), for: .normal)
        downloadButton.tintColor = .kpOffWhite
        watchButton.tintColor = .kpOffWhite
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(tapGesture)
    }
    
    func config(withModel model: VideoItemModel, episode: Int, inSeason season: Int) {
        self.model = model
        indexPathSeason = season
        indexPathEpisode = episode
        mediaItem.id = model.item.id
        
        if let thumb = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.thumbnail, thumb != "" {
            thumbnailImageView.af_setImage(withURL: URL(string: thumb)!,
                                       placeholderImage: UIImage(named: "episode.png"),
                                       imageTransition: .crossDissolve(0.2),
                                       runImageTransitionIfCached: false)
        }
        if var title = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.title?.components(separatedBy: " / "), let number = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.number {
            if title[0] == "" {
                title[0] = "Episode \(number)"
            }
            episodeNumberLabel.text = "ЭПИЗОД \(number)"
            ruTitleLabel.text = "\(title[0])"
            enTitleLabel.text = title.count > 1 ? title[1] : ""
            
            mediaItem.title = "s\(model.getSeason(indexPathSeason)?.number ?? 0)e\(number) - \(title[0])"
            mediaItem.video = number
            mediaItem.season = model.getSeason(indexPathSeason)?.number ?? 0
        }
        if let url = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.files?.first?.url?.hls4 {
            mediaItem.url = URL(string: url)
        }
        
        if let watching = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.watching {
            updateWatchStatus(watch: watching, episode: model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)!)
        }
    }
    
    func updateWatchStatus(watch: Watching, episode: Episodes) {
        guard let status = watch.status else {return}
        switch status {
        case .watched:
            watchButton.setImage(UIImage(named: "Eye Fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            watchedView.isHidden = false
            watchedView.backgroundColor = .kpMarigold
            watchedLabel.text = " ПРОСМОТРЕНО "
        case .watching:
            watchButton.setImage(UIImage(named: "Eye")?.withRenderingMode(.alwaysTemplate), for: .normal)
            watchedView.isHidden = false
            watchedView.backgroundColor = .kpGreyishTwo
            watchedLabel.text = " НЕДОСМОТРЕНО "
        case .unwatched:
            watchButton.setImage(UIImage(named: "Eye")?.withRenderingMode(.alwaysTemplate), for: .normal)
            watchedView.isHidden = true
        }
        
        if let time = watch.time, time != 0 {
            mediaItem.watchingTime = time
        }
    }
    
    func playVideo() {
        if mediaItem.url != nil {
            mediaManager.playVideo(mediaItems: [mediaItem], userinfo: nil)
        } else {
            Alert(title: "Ошибка", message: "Что-то пошло не так")
                .showOkay()
        }
    }
    
    @objc func playButtonAction(_ sender: UIGestureRecognizer) {
        if Config.shared.streamType == "hls4" {
            playVideo()
        } else {
            showDownloadAlert(play: true)
        }
    }
    
    func changeWatchStatus() {
        (parentViewController as? SeasonTableViewController)?.beginLoad()
        logViewsManager.changeWatchingStatus(id: mediaItem.id!, video: mediaItem.video, season: mediaItem.season!, status: nil)
    }
    
    func showDownloadAlert(play: Bool = false) {
        let actionVC = ActionSheet(message: "Выберите качество")
        actionVC.tint(.kpBlack)
        for file in (model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.files)! {
            actionVC.addAction(file.quality!, style: .default, handler: { [weak self] (_) in
                guard let strongSelf = self else { return }
                if play {
                    var urlString = ""
                    if Config.shared.streamType == "http" {
                        urlString = (file.url?.http)!
                    } else if Config.shared.streamType == "hls" {
                        urlString = (file.url?.hls)!
                    }
                    strongSelf.mediaItem.url = URL(string: urlString)
                    strongSelf.playVideo()
                } else {
                    strongSelf.showDownloadAction(with: (file.url?.http)!, quality: file.quality!)
                }
            })
        }
        actionVC.addAction("Отменить", style: .cancel)
        actionVC.setPresentingSource(contentView)
        actionVC.show()
    }
    
    func showDownloadAction(with url: String, quality: String) {
        let name = (self.model.item?.title?.replacingOccurrences(of: " /", with: ";"))! + "; Сезон \(self.model.getSeason(indexPathSeason)?.number ?? 0), Эпизод \(model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.number ?? 0)."  + "\(quality).mp4"
        let poster = self.model.item?.posters?.small
        Share().showActions(url: url, title: name, quality: quality, poster: poster!, inView: contentView)
    }
    
}
