import Foundation
import ObjectMapper

public class Channels: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let current = "current"
    static let name = "name"
    static let id = "id"
    static let logos = "logos"
    static let embed = "embed"
    static let title = "title"
    static let stream = "stream"
    static let playlist = "playlist"
  }

  // MARK: Properties
  public var current: String?
  public var name: String?
  public var id: Int?
  public var logos: Logos?
  public var embed: String?
  public var title: String?
  public var stream: String?
  public var playlist: String?

  // MARK: ObjectMapper Initializers
  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public required init?(map: Map){

  }

  /// Map a JSON object to this class using ObjectMapper.
  ///
  /// - parameter map: A mapping from ObjectMapper.
  public func mapping(map: Map) {
    current <- map[SerializationKeys.current]
    name <- map[SerializationKeys.name]
    id <- map[SerializationKeys.id]
    logos <- map[SerializationKeys.logos]
    embed <- map[SerializationKeys.embed]
    title <- map[SerializationKeys.title]
    stream <- map[SerializationKeys.stream]
    playlist <- map[SerializationKeys.playlist]
  }

}
