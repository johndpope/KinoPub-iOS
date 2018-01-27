import Foundation
import ObjectMapper
import Eureka

public class Subtitles: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let shift = "shift"
    static let embed = "embed"
    static let lang = "lang"
    static let url = "url"
  }

  // MARK: Properties
  public var shift: Int?
  public var embed: Bool? = false
  public var lang: SubLang?
  public var url: String?

  
  public required init?(map: Map) {

  }

  
  public func mapping(map: Map) {
    shift <- map[SerializationKeys.shift]
    embed <- map[SerializationKeys.embed]
    lang <- map[SerializationKeys.lang]
    url <- map[SerializationKeys.url]
  }
}

public class SubtitlesList: Mappable, Equatable, CustomStringConvertible, InputTypeInitiable {

    public required init?(string stringValue: String) {
        return nil
    }
    
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let id = "id"
        static let title = "title"
    }
    
    // MARK: Properties
    public var id: String?
    public var title: String?
    
    public var description: String {
        return title!
    }
    public var suggestionString: String {
        return self.id!
    }
    
    // MARK: ObjectMapper Initializers
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    public required init?(map: Map) {
        
    }
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    public func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        title <- map[SerializationKeys.title]
    }
}

public func ==(lhs: SubtitlesList, rhs: SubtitlesList) -> Bool {
    return lhs.id == rhs.id
}
