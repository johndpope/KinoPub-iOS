//
//  Enums.swift
//  KinoPub
//
//  Created by hintoz on 18.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import Eureka

enum GenreType: String {
    case movie = "movie"
    case music = "music"
    case documentary = "docu"
    case tvshow = "tvshow"
}

enum ItemType: String, CustomStringConvertible {
    
    case movies = "movie"
    case shows = "serial"
    case tvshows = "tvshow"
    case movies3d = "3d"
    case concerts = "concert"
    case documovie = "documovie"
    case docuserial = "docuserial"
    case movies4k = "4k"
    
    var description: String {
        switch self {
        case .movies:
            return "Фильмы"
        case .shows:
            return "Сериалы"
        case .tvshows:
            return "ТВ-Шоу"
        case .movies3d:
            return "3D"
        case .concerts:
            return "Концерты"
        case .documovie:
            return "Документальные фильмы"
        case .docuserial:
            return "Документальные сериалы"
        case .movies4k:
            return "4K"
        }
    }
    
    init() {
        self = .movies
    }
    func getValue() -> String {
        return self.rawValue
    }
    func genre() -> GenreType {
        switch self {
        case .tvshows:
            return .tvshow
        case .movies, .shows, .movies3d, .movies4k:
            return .movie
        case .concerts:
            return .music
        case .documovie, .docuserial:
            return .documentary
        }
    }
    enum ItemSubtype: String {
        case multi = "multi"
        func getValue() -> String {
            return self.rawValue
        }
    }
}

public enum SubLang: String, CustomStringConvertible, Equatable {
    case rus = "rus"
    case eng = "eng"
    case ukr = "ukr"
    case fre = "fre"
    case ger = "ger"
    case spa = "spa"
    case ita = "ita"
    case por = "por"
    case fin = "fin"
    
    public var description: String {
        switch self {
        case .rus:
            return "Русские"
        case .eng:
            return "Английские"
        case .ukr:
            return "Украинские"
        case .fre:
            return "Французкие"
        case .ger:
            return "Немецкие"
        case .spa:
            return "Испанские"
        case .ita:
            return "Итальянские"
        case .por:
            return "Португальские"
        case .fin:
            return "Финские"
        }
    }
}

enum SortOption: String, CustomStringConvertible, InputTypeInitiable {
    
    init?(string stringValue: String) {
        return nil
    }
    
    case id
    case year
    case title
    case created
    case updated
    case rating
    case kinopoisk_rating
    case imdb_rating
    case views
    case watchers
    
    static let all = [updated, created, year, title, rating, kinopoisk_rating, imdb_rating, views, watchers]
    
    func name() -> String {
        switch self {
        case .id:
            return "по Id"
        case .year:
            return "по году выпуска"
        case .title:
            return "по названию"
        case .created:
            return "по дате добавления"
        case .updated:
            return "по дате обновления"
        case .rating:
            return "по рейтингу"
        case .kinopoisk_rating:
            return "по кинопоиску"
        case .imdb_rating:
            return "по imdb"
        case .views:
            return "по просмотрам"
        case .watchers:
            return "по кол-ву смотрящих"
        }
    }
    
    func desc() -> String {
        return "-\(self.rawValue)"
    }
    
    func asc() -> String {
        return self.rawValue
    }
    
    var description: String {
        return self.name()
    }
    
    var suggestionString: String {
        return self.rawValue
    }
}

enum TabBarItemTag: Int {
    case movies = 0
    case shows = 1
    case cartoons = 2
    case documovie = 3
    case docuserial = 4
    case tvshow = 5
    case concert = 6
    case bookmarks = 7
    case collections = 8
    case movies4k = 9
    case movies3d = 10
    case newMovies = 11
    case newSeries = 12
    case hotMovies = 13
    case hotSeries = 14
    case freshMovies = 15
    case freshSeries = 16
    
    case watchlist = 99

    func getValue() -> Int {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .newMovies:
            return "Новые фильмы"
        case .newSeries:
            return "Новые сериалы"
        case .hotMovies:
            return "Популярные фильмы"
        case .hotSeries:
            return "Популярные сериалы"
        case .freshMovies:
            return "Свежие фильмы"
        case .freshSeries:
            return "Свежие сериалы"
        default:
            return "default"
        }
    }
}

public enum Status: Int {
    case unwatched = -1
    case watching = 0
    case watched = 1
}

public enum Serial: Int {
    case watching = 1
    case used = 0
}

enum InWatchlist: String {
    case watching = "Смотрю"
    case willWatch = "Буду смотреть"

    func getValue() -> String {
        return self.rawValue
    }
}
