import UIKit
import AlamofireImage
import EZPlayer
import LKAlertController
import NTDownload
import NotificationBannerSwift

class EpisodesCollectionViewCell: UICollectionViewCell {
    private var model: VideoItemModel!
    private let mediaManager = try! AppDelegate.assembly.resolve() as MediaManager
    private let logViewsManager = try! AppDelegate.assembly.resolve() as LogViewsManager
    
    var indexPathSeason: Int!
    var indexPathEpisode: Int!
    var mediaItem = MediaItem()

    @IBOutlet weak var thumbImageView: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var episodeNumberLabel: UILabel!
    @IBOutlet weak var episodeNumberView: UIView!
    @IBOutlet weak var watchedView: UIView!
    @IBOutlet weak var watchedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .kpBlackTwo
        configureLabels()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonAction(_:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(playButtonLongTapAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(tapGesture)
        contentView.addGestureRecognizer(longGesture)
    }
    
    func config(withModel model: VideoItemModel, episode: Int, inSeason season: Int) {
        self.model = model
        indexPathSeason = season
        indexPathEpisode = episode
        watchedView.isHidden = true
        progressBar.isHidden = true
        progressBar.progressTintColor = .kpMarigold
//        progressBar.transform = progressBar.transform.scaledBy(x: 1.0, y: 5.7)
        mediaItem.id = model.item.id
        if let thumb = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.thumbnail, thumb != "" {
            thumbImageView.af_setImage(withURL: URL(string: thumb)!,
                                       placeholderImage: UIImage(named: "episode.png"),
                                       imageTransition: .crossDissolve(0.2),
                                       runImageTransitionIfCached: false)
        }
        
        if var title = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.title,
            let number = model.getEpisode(indexPathEpisode, forSeason: indexPathSeason)?.number {
            episodeNumberLabel.text = "\(number)"
            if title == "" {
                title = "Episode \(number)"
            }
//            titleLabel.text = "\(title)"
            mediaItem.title = "s\(model.getSeason(indexPathSeason)?.number ?? 0)e\(number) - \(title)"
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
            watchedView.isHidden = false
            watchedView.backgroundColor = .kpMarigold
            watchedLabel.text = " ПРОСМОТРЕНО "
        case .watching:
            watchedView.isHidden = false
            watchedView.backgroundColor = .kpGreyishTwo
            watchedLabel.text = " НЕДОСМОТРЕНО "
        case .unwatched:
            watchedView.isHidden = true
        }
        
        if let time = watch.time, time != 0 {
            mediaItem.watchingTime = time.double
        } else {
            mediaItem.watchingTime = nil
        }

//        if status == .watching {
//            if let duration = episode.duration, duration > 0, let time = watch.time {
//                model.watchingTime = time
//                progressBar.isHidden = false
//                let progressed: Float = Float(time) / Float(duration)
//                progressBar.setProgress(progressed, animated: true)
//            } else {
//                progressBar.isHidden = true
//            }
//        } else {
//            progressBar.isHidden = true
//        }
    }

    func configureLabels() {
        episodeNumberLabel.textColor = .kpBlack
        episodeNumberView.backgroundColor = .kpOffWhite
        watchedView.backgroundColor = .kpMarigold
        watchedLabel.textColor = .kpBlack
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
    
    func changeWatchingStatus() {
        (parentViewController as? DetailViewController)?.beginLoad()
        logViewsManager.changeWatchingStatus(id: mediaItem.id!, video: mediaItem.video!, season: mediaItem.season!, status: nil)
    }

    @objc func playButtonLongTapAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            ActionSheet()
                .tint(.kpBlack)
                .addAction("Отметить", style: .default, handler: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    strongSelf.changeWatchingStatus()
//                    self.watchedLabel.isHidden.toggle()
                })
                .addAction("Скачать", style: .default, handler: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    strongSelf.showDownloadAlert()
                })
                .addAction("Отменить", style: .cancel)
                .setPresentingSource(contentView)
                .show()
        }
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
