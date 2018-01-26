//
//  Item.swift
//
//  Created by hintoz on 26.03.17
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public class Item: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let countries = "countries"
    static let bookmarks = "bookmarks"
    static let imdb = "imdb"
    static let posters = "posters"
    static let langs = "langs"
    static let finished = "finished"
    static let imdbVotes = "imdb_votes"
    static let type = "type"
    static let voice = "voice"
    static let subtitles = "subtitles"
    static let id = "id"
    static let ac3 = "ac3"
    static let director = "director"
    static let videos = "videos"
    static let quality = "quality"
    static let qualitySeries = "quality"
    static let imdbRating = "imdb_rating"
    static let duration = "duration"
    static let title = "title"
    static let cast = "cast"
    static let poorQuality = "poor_quality"
    static let subtype = "subtype"
    static let ratingPercentage = "rating_percentage"
    static let genres = "genres"
    static let kinopoiskVotes = "kinopoisk_votes"
    static let rating = "rating"
    static let advert = "advert"
    static let tracklist = "tracklist"
    static let views = "views"
    static let kinopoiskRating = "kinopoisk_rating"
    static let year = "year"
    static let ratingVotes = "rating_votes"
    static let kinopoisk = "kinopoisk"
    static let comments = "comments"
    static let trailer = "trailer"
    static let plot = "plot"

    static let inWatchlist = "in_watchlist"
    static let subscribed = "subscribed"
    static let seasons = "seasons"

    static let total = "total"
    static let watched = "watched"
    static let new = "new"
  }

  // MARK: Properties
  public var countries: [Countries]?
  public var bookmarks: [Bookmarks]?
  public var imdb: Int?
  public var posters: Posters?
  public var langs: Int?
  public var finished: Bool? = false
  public var imdbVotes: Int?
  public var type: String?
  public var voice: String?
  public var subtitles: String?
  public var id: Int?
  public var ac3: Int?
  public var director: String?
  public var videos: [Episodes]?
  public var quality: Int?
  public var qualitySeries: String?
  public var imdbRating: Float?
  public var duration: Duration?
  public var title: String?
  public var cast: String?
  public var poorQuality: Bool? = false
  public var subtype: String?
  public var ratingPercentage: String?
  public var genres: [Genres]?
  public var kinopoiskVotes: Int?
  public var rating: Int?
  public var advert: Bool? = false
  public var tracklist: [Any]?
  public var views: Int?
  public var kinopoiskRating: Float?
  public var year: Int?
  public var ratingVotes: String?
  public var kinopoisk: Int?
  public var comments: Int?
  public var trailer: Trailer?
  public var plot: String?

  public var inWatchlist: Bool? = false
  public var subscribed: Bool? = false
  public var seasons: [Seasons]?
    
    public var networks: String?

    public var total: Int?
    public var watched: Int?
    public var new: Int?

  // MARK: ObjectMapper Initializers
  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public required init?(map: Map) {

  }

  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public func mapping(map: Map) {
    countries <- map[SerializationKeys.countries]
    bookmarks <- map[SerializationKeys.bookmarks]
    imdb <- map[SerializationKeys.imdb]
    posters <- map[SerializationKeys.posters]
    langs <- map[SerializationKeys.langs]
    finished <- map[SerializationKeys.finished]
    imdbVotes <- map[SerializationKeys.imdbVotes]
    type <- map[SerializationKeys.type]
    voice <- map[SerializationKeys.voice]
    subtitles <- map[SerializationKeys.subtitles]
    id <- map[SerializationKeys.id]
    ac3 <- map[SerializationKeys.ac3]
    director <- map[SerializationKeys.director]
    videos <- map[SerializationKeys.videos]
    quality <- map[SerializationKeys.quality]
    qualitySeries <- map[SerializationKeys.qualitySeries]
    imdbRating <- map[SerializationKeys.imdbRating]
    duration <- map[SerializationKeys.duration]
    title <- map[SerializationKeys.title]
    cast <- map[SerializationKeys.cast]
    poorQuality <- map[SerializationKeys.poorQuality]
    subtype <- map[SerializationKeys.subtype]
    ratingPercentage <- map[SerializationKeys.ratingPercentage]
    genres <- map[SerializationKeys.genres]
    kinopoiskVotes <- map[SerializationKeys.kinopoiskVotes]
    rating <- map[SerializationKeys.rating]
    advert <- map[SerializationKeys.advert]
    tracklist <- map[SerializationKeys.tracklist]
    views <- map[SerializationKeys.views]
    kinopoiskRating <- map[SerializationKeys.kinopoiskRating]
    year <- map[SerializationKeys.year]
    ratingVotes <- map[SerializationKeys.ratingVotes]
    kinopoisk <- map[SerializationKeys.kinopoisk]
    comments <- map[SerializationKeys.comments]
    trailer <- map[SerializationKeys.trailer]
    plot <- map[SerializationKeys.plot]

    inWatchlist <- map[SerializationKeys.inWatchlist]
    subscribed <- map[SerializationKeys.subscribed]
    seasons <- map[SerializationKeys.seasons]

    total <- map[SerializationKeys.total]
    watched <- map[SerializationKeys.watched]
    new <- map[SerializationKeys.new]
  }
}
