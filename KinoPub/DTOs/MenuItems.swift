import Foundation

struct MenuItems: Codable, Equatable {
    let id: String
    let name: String
    let icon: String
    let tag: Int?
    
    // Content Menu
    static var mainVC: MenuItems {
        return MenuItems(id: "HomeNavVc", name: "Главная", icon: "Main", tag: nil)
    }
    static var filmsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Фильмы", icon: "Movies", tag: TabBarItemTag.movies.rawValue)
    }
    static var seriesVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Сериалы", icon: "Series", tag: TabBarItemTag.shows.rawValue)
    }
    static var cartoonsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Мультфильмы", icon: "Cartoons", tag: TabBarItemTag.cartoons.rawValue)
    }
    static var docMoviesVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Документальные фильмы", icon: "Documentary Movie", tag: TabBarItemTag.documovie.rawValue)
    }
    static var docSeriesVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Документальные сериалы", icon: "Documentary Series", tag: TabBarItemTag.docuserial.rawValue)
    }
    static var tvShowsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "ТВ шоу", icon: "Television", tag: TabBarItemTag.tvshow.rawValue)
    }
    static var concertsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Концерты", icon: "Concert", tag: TabBarItemTag.concert.rawValue)
    }
    static var collectionsVC: MenuItems {
        return MenuItems(id: "CollectionsNavVC", name: "Подборки", icon: "Collection", tag: TabBarItemTag.collections.rawValue)
    }
    static var movies4kVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "4K", icon: "4K", tag: TabBarItemTag.movies4k.rawValue)
    }
    static var movies3dVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "3D", icon: "3D", tag: TabBarItemTag.movies3d.rawValue)
    }
    static var tvSportVC: MenuItems {
        return MenuItems(id: "SportNavVC", name: "Спортивные каналы", icon: "Sports", tag: nil)
    }
    
    // User Menu
    static var watchlistVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Я смотрю", icon: "Eye", tag: TabBarItemTag.watchlist.rawValue)
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
    
    static let hiddenMenuItemsDefault = [movies4kVC, movies3dVC]
    static let configurableMenuItems = [filmsVC, seriesVC, cartoonsVC, docMoviesVC, docSeriesVC, tvShowsVC, concertsVC, collectionsVC, movies4kVC, movies3dVC, tvSportVC]
    static let jsonFileForHiddenMenuItems = "configMenu.json"
    
    static let userMenu = [watchlistVC, bookmarksVC, downloadsVC]
    static let contentMenu = [mainVC] + Config.shared.hiddenMenusService.loadConfigMenu()
    static let settingsMenu = [settingsVC]
    static let all = userMenu + contentMenu + settingsMenu
    
    static func ==(lhs: MenuItems, rhs: MenuItems) -> Bool {
        return lhs.name == rhs.name
    }
}
