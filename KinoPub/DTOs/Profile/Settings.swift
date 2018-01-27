import Foundation
import ObjectMapper

public class Settings: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let showErotic = "show_erotic"
    static let showUncertain = "show_uncertain"
  }

  // MARK: Properties
  public var showErotic: Bool? = false
  public var showUncertain: Bool? = false

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
    showErotic <- map[SerializationKeys.showErotic]
    showUncertain <- map[SerializationKeys.showUncertain]
  }
}
