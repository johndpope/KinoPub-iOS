import Foundation
import ObjectMapper

public class Trailer: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let id = "id"
    static let url = "url"
  }

  // MARK: Properties
  public var id: String?
  public var url: String?

  
  public required init?(map: Map) {

  }

  
  public func mapping(map: Map) {
    id <- map[SerializationKeys.id]
    url <- map[SerializationKeys.url]
  }
}
