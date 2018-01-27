import Foundation
import LKAlertController
import NotificationBannerSwift

protocol VideoItemModelDelegate: class {
//    func didUpdateItem(model: VideoItemModel, error: Error?)
    func didUpdateSimilar()
}

class VideoItemModel {
    weak var delegate: VideoItemModelDelegate?
    var item: Item!
    var mediaItem = MediaItem()
    var mediaItems = [MediaItem]()
    var files: [Files]?
    var parameters = [String: String]()
    var watchingTime: Int = 0
    var similarItems = [Item]()
    
    let accountManager: AccountManager
    let networkingService: VideosNetworkingService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = VideosNetworkingService(requestFactory: accountManager.requestFactory)
//        accountManager.addDelegate(delegate: self)
    }
    
    func getSeason(_ index: Int) -> Seasons? {
        return item?.seasons?[index]
    }
    
    func getEpisode(_ index: Int, forSeason seasonIndex: Int) -> Episodes? {
        return item.videos?[index] ?? item.seasons?[seasonIndex].episodes?[index]
    }
    
    func loadItemsInfo() {
        networkingService.receiveItems(withParameters: parameters, from: item.id?.string) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let itemData = response {
                strongSelf.item = itemData.item
                strongSelf.setLinks()
                strongSelf.checkDefaults()
                NotificationCenter.default.post(name: .VideoItemDidUpdate, object: self, userInfo:nil)
            } else {
                debugPrint("[!ERROR]: \(String(describing: error?.localizedDescription))")
                Alert(title: "Ошибка", message: error?.localizedDescription)
                    .showOkay()
            }
        }
    }
    
    func checkDefaults() {
        if Config.shared.canSortSeasons, let seasons = item.seasons {
            item.seasons = seasons.sorted { $0.number! > $1.number! }
        }
        if Config.shared.canSortEpisodes, let seasons = item.seasons {
            var _seasons = [Seasons]()
            for season in seasons {
                season.episodes = season.episodes?.sorted { $0.number! > $1.number! }
                _seasons.append(season)
            }
            item.seasons = seasons
        }
    }
    
    func loadSimilarsVideo() {
        networkingService.receiveSimilarItems(id: (item.id?.string)!) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let itemData = response {
                strongSelf.similarItems = itemData
                strongSelf.delegate?.didUpdateSimilar()
            } else {
                debugPrint("[!ERROR]: \(String(describing: error?.localizedDescription))")
                Alert(title: "Ошибка", message: error?.localizedDescription)
                    .showOkay()
            }
        }
    }
    
    private func setLinks() {
        var mediaItem = MediaItem()
        mediaItem.id = item.id
//        mediaItem.url = nil
        if let url = item.videos?.first?.files?.first?.url?.hls4,
            item.subtype != ItemType.ItemSubtype.multi.getValue() {
            files = item.videos?.first?.files
            mediaItem.title = item.title
            mediaItem.video = item.videos?.first?.number
            mediaItem.url = URL(string: url)
            if item.videos?.first?.watching?.status == Status.watching {
                mediaItem.watchingTime = (item.videos?.first?.watching?.time?.double)!
            }
            mediaItems.append(mediaItem)
//            delegate?.didUpdateItem(model: self, error: nil)
        } else {
            print("No unwrapping url")
            if let type = item.type, type == ItemType.movies.getValue()
                || type == ItemType.documovie.getValue()
                || type == ItemType.concerts.getValue(),
                item.subtype != ItemType.ItemSubtype.multi.getValue() {
                Alert(title: "Ошибка", message: "Не удалось получить ссылку на поток. Возможно, видео находится в обработке. Попробуйте позже.")
                    .showOkay()
            }
        }
        
        if item.subtype == ItemType.ItemSubtype.multi.getValue() {
            for episode in (item.videos)! {
                if episode.watching?.status == Status.watching {
                    mediaItem.watchingTime = (episode.watching?.time?.double)!
                }
                if episode.watching?.status == Status.unwatched ||  episode.watching?.status == Status.watching {
                    if var title = episode.title, let number = episode.number {
                        if title == "" {
                            title = "Episode \(number)"
                        }
                        mediaItem.video = number
                        mediaItem.title = "e\(number) - \(title)"
                    }
                    mediaItem.season = 0
                    mediaItem.url = URL(string: (episode.files?.first?.url?.hls4)!)
                    mediaItems.append(mediaItem)
                    files = episode.files
//                    break
                }
            }
//            delegate?.didUpdateItem(model: self, error: nil)
        }
        
        if item.type == ItemType.shows.getValue() || item.type == ItemType.docuserial.getValue() || item.type == ItemType.tvshows.getValue() {
            var foundSeason = false
            for season in (item.seasons)! {
                if season.watching?.status == Status.watching || season.watching?.status == Status.unwatched {
                    foundSeason = true
                    for episode in season.episodes! {
                        if episode.watching?.status == Status.watching {
                            mediaItem.watchingTime = (episode.watching?.time?.double)!
                        }
                        if episode.watching?.status == Status.unwatched ||  episode.watching?.status == Status.watching {
                            if var title = episode.title, let number = episode.number {
                                if title == "" {
                                    title = "Episode \(number)"
                                }
                                mediaItem.video = number
                                mediaItem.title = "s\(season.number ?? 0)e\(number) - \(title)"
                            }
                            mediaItem.season = season.number
                            mediaItem.url = URL(string: (episode.files?.first?.url?.hls4)!)
                            mediaItems.append(mediaItem)
                            files = episode.files
//                            break
                        }
                    }
                }
                if foundSeason {
//                    delegate?.didUpdateItem(model: self, error: nil)
                    break
                }
            }
        }
    }
}
