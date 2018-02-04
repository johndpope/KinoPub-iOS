import Foundation
import ObjectMapper

public class Watching: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let status = "status"
    static let time = "time"
  }

  // MARK: Properties
  public var status: Status!
  public var time: Double?

  
  public required init?(map: Map) {

  }

  
  public func mapping(map: Map) {
    status <- map[SerializationKeys.status]
    time <- map[SerializationKeys.time]
  }
}

public class WatchingToggle: Mappable {

    private struct SerializationKeys {
        static let status = "status"
        static let watched = "watched"
        static let watching = "watching"
        static let watching2 = "watching"
    }

    public var status: Int!
    public var watched: Int!
    public var watching: Bool!
    public var watching2: Watching!

    public required init?(map: Map) {

    }

    public func mapping(map: Map) {
        status <- map[SerializationKeys.status]
        watched <- map[SerializationKeys.watched]
        watching <- map[SerializationKeys.watching]
        watching2 <- map[SerializationKeys.watching2]
    }
}
