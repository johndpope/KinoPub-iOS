import Foundation

struct Filter: ReflectedStringConvertible {
    
    var genres: Set<Genres>?
    var countries: Set<Countries>?
    var subtitles: SubtitlesList?
    var year: String?
    var yearsDict: [String : String]?
    var sort: SortOption!
    var sortAsc: Bool
    
    static var defaultFilter: Filter {
        let filter = Filter(genres: nil, countries: nil, subtitles: nil, year: nil, yearsDict: nil, sort: SortOption.updated, sortAsc: false)
        return filter
    }
    
    var isSet: Bool {
        if genres != nil || countries != nil || subtitles != nil || year != nil || sort != SortOption.updated || sortAsc {
            return true
        }
        return false
    }
    
}

extension Filter: Equatable {
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return lhs.genres == rhs.genres && lhs.yearsDict! == rhs.yearsDict!
    }
}

extension Filter {
    var parameters: [String : String]? {
        var param = [String : String]()
        if let genres = genres {
            param["genre"] = genres.toString
        }
        if let countries = countries {
            param["country"] = countries.toString
        }
        if let subtitles = subtitles {
            param["subtitles"] = subtitles.id
        }
        if let year = year {
            switch year {
            case "Не важно":
                param["year"] = ""
            case "Период":
                if var yearsDict = yearsDict {
                    if let year1 = yearsDict["from"]?.int, let year2 = yearsDict["to"]?.int, year1 > year2 {
                        yearsDict.swap("from", "to")
                    }
                    param["year"] = yearsDict.toString
                }
            default:
                param["year"] = year
            }
        }
        param["sort"] = sortAsc ? sort.asc() : sort.desc()
        
        return param.count > 0 ? param : nil
    }
}
