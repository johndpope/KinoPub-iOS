import Foundation
import ObjectMapper

public class Subscription: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let days = "days"
    static let endTime = "end_time"
    static let active = "active"
  }

  // MARK: Properties
  public var days: Float?
  public var endTime: Int?
  public var active: Bool? = false

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
    days <- map[SerializationKeys.days]
    endTime <- map[SerializationKeys.endTime]
    active <- map[SerializationKeys.active]
  }
}
