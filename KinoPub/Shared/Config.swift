import UIKit
import SwiftyUserDefaults
import FirebaseRemoteConfig

protocol ConfigDelegate: class {
    func configDidLoad()
//    weak var delegate: ConfigDelegate?
}

class Config {
    static let shared = Config()
    var remoteConfig: RemoteConfig!
    weak var delegate: ConfigDelegate?
    
//    let defaultValues = [
//        "kinopubClientId" : UserDefaults.standard.object(forKey: "kinopubClientId") as? NSObject ?? kinopub.clientId as NSObject,
//        "kinopubClientSecret" : UserDefaults.standard.object(forKey: "kinopubClientSecret") as? NSObject ?? kinopub.clientSecret as NSObject,
//        "delayViewMarkTime" : UserDefaults.standard.object(forKey: "delayViewMarkTime") as? NSObject ?? 180 as NSObject,
//        "kinopubDomain" : UserDefaults.standard.object(forKey: "kinopubDomain") as? NSObject ?? kinopub.domain as NSObject
//    ]
    
    let defaultValues = [
        "kinopubClientId" : Defaults[.kinopubClientId] as NSObject,
        "kinopubClientSecret" : Defaults[.kinopubClientSecret] as NSObject,
        "delayViewMarkTime" : Defaults[.delayViewMarkTime] as NSObject,
        "kinopubDomain" : Defaults[.kinopubDomain] as NSObject
                         ]

    var appVersion: String {
        if let dictionary = Bundle.main.infoDictionary {
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            return "Версия \(version), билд \(build)"
        }
        return ""
    }
    
    var kinopubClientId: String {
        return remoteConfig["kinopubClientId"].stringValue ?? kinopub.clientId
    }
    
    var kinopubClientSecret: String {
        return remoteConfig["kinopubClientSecret"].stringValue ?? kinopub.clientSecret
    }
    
    var delayViewMarkTime: TimeInterval {
        return remoteConfig["delayViewMarkTime"].numberValue as? TimeInterval ?? 180
    }
    
    var kinopubDomain: String {
        return remoteConfig["kinopubDomain"].stringValue ?? kinopub.domain
    }
    
    var clientTitle: String {
        return Defaults[.clientTitle]
    }
    
    var menuItem: Int {
        return Defaults[.menuItem]
    }
    
    var streamType: String {
        return Defaults[.streamType]
    }
    
    var logViews: Bool {
        return Defaults[.logViews]
    }
    
    var canSortSeasons: Bool {
        return Defaults[.canSortSeasons]
    }
    
    var canSortEpisodes: Bool {
        return Defaults[.canSortEpisodes]
    }
    
    var menuVisibleContentWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1.6
        } else {
            return 5
        }
    }
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(defaultValues)
        fetchRemoteConfig()
    }
    
    func fetchRemoteConfig() {
        #if DEBUG
            // FIXME: Remove before production!
            let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
            remoteConfig.configSettings = remoteConfigSettings!
        #endif
        
        remoteConfig.fetch(withExpirationDuration: 0) { [unowned self] (status, error) in
            guard error == nil else {
                print("Error fetch remote config: \(error?.localizedDescription ?? "unknown")")
                return
            }
            self.writeInUserDefaults()
            self.remoteConfig.activateFetched()
            self.delegate?.configDidLoad()
        }
    }
    
    func writeInUserDefaults() {
        Defaults[.kinopubClientId] = remoteConfig["kinopubClientId"].stringValue!
        Defaults[.kinopubClientSecret] = remoteConfig["kinopubClientSecret"].stringValue!
        Defaults[.delayViewMarkTime] = remoteConfig["delayViewMarkTime"].numberValue as! TimeInterval
        Defaults[.kinopubDomain] = remoteConfig["kinopubDomain"].stringValue!
    }
    
    struct MenuItems {
        let id: String
        let name: String
        let icon: String
        let tag: Int?
        
        // Content Menu
        static var mainVC: MenuItems {
            return MenuItems(id: "HomeNavVc", name: "Главная", icon: "Main", tag: nil)
        }
        static var filmsVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Фильмы", icon: "Movies", tag: TabBarItemTag.movies.getValue())
        }
        static var seriesVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Сериалы", icon: "Series", tag: TabBarItemTag.shows.getValue())
        }
        static var cartoonsVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Мультфильмы", icon: "Cartoons", tag: TabBarItemTag.cartoons.getValue())
        }
        static var docMoviesVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Документальные фильмы", icon: "Documentary Movie", tag: TabBarItemTag.documovie.getValue())
        }
        static var docSeriesVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Документальные сериалы", icon: "Documentary Series", tag: TabBarItemTag.docuserial.getValue())
        }
        static var tvShowsVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "ТВ шоу", icon: "Television", tag: TabBarItemTag.tvshow.getValue())
        }
        static var concertsVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Концерты", icon: "Concert", tag: TabBarItemTag.concert.getValue())
        }
        static var collectionsVC: MenuItems {
            return MenuItems(id: "CollectionsNavVC", name: "Подборки", icon: "Collection", tag: TabBarItemTag.collections.getValue())
        }
        static var movies4kVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "4K", icon: "4K", tag: TabBarItemTag.movies4k.getValue())
        }
        static var movies3dVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "3D", icon: "3D", tag: TabBarItemTag.movies3d.getValue())
        }
        
        // User Menu
        static var watchlistVC: MenuItems {
            return MenuItems(id: "ItemNavVC", name: "Я смотрю", icon: "Eye", tag: TabBarItemTag.watchlist.getValue())
        }
        static var bookmarksVC: MenuItems {
            return MenuItems(id: "BokmarksNavVC", name: "Закладки", icon: "Folder", tag: nil)
        }
        static var downloadsVC: MenuItems {
            return MenuItems(id: "DownloadNavVC", name: "Загрузки", icon: "Download", tag: nil)
        }
        
        // Settings Menu
        static var settingsVC: MenuItems {
            return MenuItems(id: "SettingsNavVC", name: "Настройки", icon: "Settings", tag: nil)
        }
        
        static let userMenu = [watchlistVC, bookmarksVC, downloadsVC]
        static let contentMenu = [mainVC, filmsVC, seriesVC, cartoonsVC, docMoviesVC, docSeriesVC, tvShowsVC, concertsVC, collectionsVC, movies4kVC, movies3dVC]
        static let settingsMenu = [settingsVC]
        static let all = userMenu + contentMenu + settingsMenu
    }

}
