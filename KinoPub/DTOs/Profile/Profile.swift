import Foundation
import ObjectMapper

public class Profile: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let avatar = "avatar"
    static let name = "name"
  }

  // MARK: Properties
  public var avatar: String?
  public var name: String?

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
    avatar <- map[SerializationKeys.avatar]
    name <- map[SerializationKeys.name]
  }
}
