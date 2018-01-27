import Foundation
import ObjectMapper

public class DeviceRequest: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let device = "device"
    static let status = "status"
  }

  // MARK: Properties
  public var device: Device?
  public var status: Int?

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
    device <- map[SerializationKeys.device]
    status <- map[SerializationKeys.status]
  }
}
