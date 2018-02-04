import Foundation
import ObjectMapper

public class Countries: Mappable, Hashable, Equatable, CustomStringConvertible {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let id = "id"
        static let title = "title"
    }
    
    // MARK: Properties
    public var id: Int!
    public var title: String!
    
    public var hashValue: Int {
        return self.id!
    }
    public var description: String {
        return title!
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        title <- map[SerializationKeys.title]
    }
}

public func ==(lhs: Countries, rhs: Countries) -> Bool {
    return lhs.id == rhs.id
}
