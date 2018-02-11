import UIKit
import EZPlayer
import LKAlertController
import SwiftyUserDefaults
import AVFoundation
import MediaPlayer
import SubtleVolume
import NDYoutubePlayer

import AVKit

protocol MediaManagerDelegate: class {
    func playDidFinish(model: MediaManager)
}


class MediaManager {
    fileprivate let logViewsManager = Container.Manager.logViews
    private var timeObserver: Any?
    var fullScreenViewController: DTSPlayerFullScreenViewController?
    var playerCustom: EZPlayer?
    var playerNative: AVQueuePlayer?
    var mediaItems = [MediaItem]()
    var playerItems = [AVPlayerItem]()
    
    var fixReadyToPlay: Bool = false
    var time: TimeInterval = 0
    var volume: SubtleVolume?
    var isLive = false

    weak var delegate: MediaManagerDelegate?

    static let shared = MediaManager()
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDisplayFromDefaults), name: UserDefaults.didChangeNotification, object: nil)

            // Custom
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.EZPlayerPlaybackDidFinish, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerTimeDidChange(_:)), name: NSNotification.Name.EZPlayerPlaybackTimeDidChange, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerStatusDidChange(_:)), name: NSNotification.Name.EZPlayerStatusDidChange, object: playerCustom)

            // Native
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerNative?.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidClosed(_:)), name: NSNotification.Name.DTSPlayerViewControllerDismissed, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerTimeDidChange(_:)), name: NSNotification.Name.DTSPlayerPlaybackTimeDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addPlayerItemTimeObserver(){
        self.timeObserver = self.playerNative?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(Config.shared.delayViewMarkTime, CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { time in
            NotificationCenter.default.post(name: .DTSPlayerPlaybackTimeDidChange, object: self, userInfo:nil)
        })
    }
    
    func playYouTubeVideo(withID id: String) {
        releaseNativePlayer()
        releasePlayer()
        NDYoutubeClient.shared.getVideoWithIdentifier(videoIdentifier: id) { [weak self] (video, error) in
            guard let video = video else {
                Alert(title: "Ошибка", message: "Трейлер не найден. \n По возможности сообщите в стол заказов в Telegram.")
                .showOkay()
                return
            }
            guard let streamURLs = video.streamURLs else { return }
            if let videoString = streamURLs[NDYouTubeVideoQuality.NDYouTubeVideoQualityHD720.rawValue] ?? streamURLs[NDYouTubeVideoQuality.NDYouTubeVideoQualityMedium360.rawValue] ?? streamURLs[NDYouTubeVideoQuality.NDYouTubeVideoQualitySmall240.rawValue] {
                let mediaItems = [MediaItem(url: URL(string: videoString as! String)!, title: nil, video: nil, id: nil, season: nil, watchingTime: nil)]
                self?.playVideo(mediaItems: mediaItems)
            }
        }
    }
    
    func playVideo(mediaItems: [MediaItem], userinfo: [AnyHashable : Any]? = nil, isLive: Bool = false) {
        releaseNativePlayer()
        releasePlayer()
        self.isLive = isLive
        self.mediaItems = mediaItems
        
        for item in mediaItems {
            playerItems.append(AVPlayerItem(url: item.url!))
        }
        
        Defaults[.isCustomPlayer] ? playWithCustomPlayer(mediaItems: mediaItems, userinfo: userinfo) : playWithNativePlayer(mediaItems: playerItems, userinfo: userinfo)
    }
    
    // Native Player
    func playWithNativePlayer(mediaItems: [AVPlayerItem], userinfo: [AnyHashable : Any]? = nil) {
        guard let activityViewController = DTSPlayerUtils.activityViewController() else { return }
//        playerNative = AVPlayer(url: mediaItem.url!)
        
        playerNative = AVQueuePlayer(items: mediaItems)
        
        playerNative?.allowsExternalPlayback = true
        playerNative?.usesExternalPlaybackWhileExternalScreenIsActive = true
        self.time = Date().timeIntervalSinceReferenceDate
        !isLive ? addPlayerItemTimeObserver() : nil
        fullScreenViewController = DTSPlayerFullScreenViewController()
        fullScreenViewController?.player = playerNative
        fullScreenViewController?.showsPlaybackControls = true
        activityViewController.present(fullScreenViewController!, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fullScreenViewController?.player!.play()
            guard !strongSelf.isLive else { return }
            if let item = strongSelf.playerNative?.currentItem, let index = strongSelf.playerItems.index(of: item), let timeToSeek = strongSelf.mediaItems[index].watchingTime {
                Alert(message: "Продолжить с \(timeToSeek.timeIntervalAsString("hh:mm:ss"))?")
                    .tint(.kpBlack)
                    .addAction("Нет", style: .cancel)
                    .addAction("Да", style: .default, handler: { (_) in
                        strongSelf.fullScreenViewController?.player?.seek(to: CMTime(seconds: timeToSeek, preferredTimescale: 1))
                    }).show(animated: true)
            }
        }
    }
    
    //Custom Player
    func playWithCustomPlayer(mediaItems: [MediaItem], userinfo: [AnyHashable : Any]? = nil ) {
        self.playerCustom = EZPlayer()

        self.playerCustom!.backButtonBlock = { fromDisplayMode in
            if fromDisplayMode == .embedded {
                self.releasePlayer()
            } else if fromDisplayMode == .fullscreen {
                    self.releasePlayer()

            } else if fromDisplayMode == .float {
                self.releasePlayer()
            }

        }
        
        if mediaItems.first?.title != nil {
            self.playerCustom!.playWithURL((mediaItems.first?.url)!, embeddedContentView: nil, title: mediaItems.first?.title)
        } else {
            self.playerCustom!.playWithURL((mediaItems.first?.url)!, embeddedContentView: nil)
        }

        self.playerCustom!.fullScreenPreferredStatusBarStyle = .lightContent

        updateDisplayFromDefaults()

        configVolumeView()
    }
    
    @objc func playPauseToggle() {
        guard let player = self.playerCustom else {
            return
        }
        if player.isPlaying {
            player.pause()
            changeMarkTime(force: true)
        } else {
            player.play()
        }
    }

    func releasePlayer() {
        self.playerCustom?.stop()
        self.playerCustom?.view.removeFromSuperview()
        self.playerCustom = nil
        if playerNative == nil {
            self.mediaItems.removeAll()
        }
        self.fixReadyToPlay = false
        self.time = 0
    }
    
    func releaseNativePlayer() {
        if self.fullScreenViewController != nil {
            self.fullScreenViewController?.dismiss(animated: true, completion: {
                
            })
            self.playerNative?.pause()
            self.mediaItems.removeAll()
            self.playerItems.removeAll()
            self.playerNative = nil
            if self.timeObserver != nil{
                self.playerNative?.removeTimeObserver(self.timeObserver!)
                self.timeObserver = nil
            }
            self.time = 0
        }
    }

    func configVolumeView() {
        volume = SubtleVolume(style: .plain)
        volume?.frame = CGRect(x: 0, y: 20, width: (playerCustom?.view.frame.size.width)!, height: 2)
        volume?.autoresizingMask = [.flexibleWidth]
        volume?.barTintColor = .kpMarigold
        volume?.animation = .fadeIn
        playerCustom?.view.addSubview(volume!)
    }

    func changeMarkTime(force: Bool = false) {
        guard !isLive else { return }
        guard Config.shared.logViews else { return }
        let _time = Date().timeIntervalSinceReferenceDate
        guard _time - self.time >= Config.shared.delayViewMarkTime || force else { return }
        if let item = playerNative?.currentItem, let index = playerItems.index(of: item) {
            if let id = mediaItems[index].id, let video = mediaItems[index].video {
                logViewsManager.changeMarktime(id: id, time: (playerNative?.currentTime)!, video: video, season: mediaItems[index].season)
                self.time = Date().timeIntervalSinceReferenceDate
            }
        } else if playerCustom != nil, let id = mediaItems[0].id, let video = mediaItems[0].video {
            logViewsManager.changeMarktime(id: id, time: (playerCustom?.currentTime)!, video: video, season: mediaItems[0].season)
            self.time = Date().timeIntervalSinceReferenceDate
        }
//        if let id = mediaItem?.id, let video = mediaItem?.video {
//            logViewsManager.changeMarktime(id: id, time: playerCustom?.currentTime ?? (playerNative?.currentTime)!, video: video, season: mediaItem?.season)
//            self.time = Date().timeIntervalSinceReferenceDate
//        }
    }

    @objc func updateDisplayFromDefaults() {

        self.playerCustom?.canSlideProgress = Defaults[.canSlideProgress]

        var left: EZPlayerSlideTrigger = .volume
        var right: EZPlayerSlideTrigger = .brightness

        switch Defaults[.leftSlideTrigger] {
        case "none": left = .none
        case "volume": left = .volume
        case "brightness": left = .brightness
        default:  left = .volume
        }
        
        switch Defaults[.rightSlideTrigger] {
        case "none": right = .none
        case "volume": right = .volume
        case "brightness": right = .brightness
        default:  right = .brightness
        }

        self.playerCustom?.slideTrigger = (left:left, right:right)

    }

    @objc  func playerDidPlayToEnd(_ notifiaction: Notification) {
        changeMarkTime(force: true)
        self.releasePlayer()
        if let item = playerNative?.currentItem, let index = playerItems.index(of: item), index >= playerItems.count - 1 {
            self.releaseNativePlayer()
        }
        NotificationCenter.default.post(name: .PlayDidFinish, object: self, userInfo:nil)
    }
    
    @objc  func playerDidClosed(_ notifiaction: Notification) {
//        self.releaseNativePlayer()
        changeMarkTime(force: true)
        NotificationCenter.default.post(name: .PlayDidFinish, object: self, userInfo:nil)
    }

    @objc func playerTimeDidChange(_ notifiaction: Notification) {
            changeMarkTime()
    }

    @objc func playerStatusDidChange(_ notifiaction: Notification) {
        if let item = notifiaction.object as? EZPlayer {
            if item.state == .readyToPlay, let timeToSeek = mediaItems.first?.watchingTime, !fixReadyToPlay {
                fixReadyToPlay = true
                Alert(message: "Продолжить с \(timeToSeek.timeIntervalAsString("hh:mm:ss"))?")
                    .tint(.kpBlack)
                .addAction("Нет", style: .cancel)
                .addAction("Да", style: .default, handler: { (_) in
                    self.playerCustom?.seek(to: timeToSeek)
                }).show(animated: true)
            }
        }
    }
}

