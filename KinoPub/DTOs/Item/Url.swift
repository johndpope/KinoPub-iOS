import Foundation
import ObjectMapper

public class Url: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let hls4 = "hls4"
    static let hls = "hls"
    static let http = "http"
  }

  // MARK: Properties
  public var hls4: String?
  public var hls: String?
  public var http: String?

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
    hls4 <- map[SerializationKeys.hls4]
    hls <- map[SerializationKeys.hls]
    http <- map[SerializationKeys.http]
  }
}
