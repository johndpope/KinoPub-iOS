import Foundation
import ObjectMapper

public class Seasons: Mappable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let episodes = "episodes"
        static let number = "number"
        static let title = "title"
        static let watching = "watching"
    }
    
    // MARK: Properties
    public var episodes: [Episodes]!
    public var number: Int!
    public var title: String!
    public var watching: Watching!
    
    
    public required init?(map: Map) {
        
    }
    
    
    public func mapping(map: Map) {
        episodes <- map[SerializationKeys.episodes]
        number <- map[SerializationKeys.number]
        title <- map[SerializationKeys.title]
        watching <- map[SerializationKeys.watching]
    }
}
