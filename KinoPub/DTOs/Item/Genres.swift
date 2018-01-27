import Foundation
import ObjectMapper

public class Genres: Mappable, Hashable, Equatable, CustomStringConvertible {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let id = "id"
    static let title = "title"
    
    static let type = "type"
  }

  // MARK: Properties
  public var id: Int?
  public var title: String?
    
    public var type: String?
    
    public var hashValue: Int {
        return self.id!
    }
    
    public var description: String {
        return title!
    }
    
    init(id: Int?, title: String?) {
        self.id = id
        self.title = title
    }

  
  public required init?(map: Map) {

  }

  
  public func mapping(map: Map) {
    id <- map[SerializationKeys.id]
    title <- map[SerializationKeys.title]
    
    type <- map[SerializationKeys.type]
  }
}

public func ==(lhs: Genres, rhs: Genres) -> Bool {
    return lhs.id == rhs.id
}
