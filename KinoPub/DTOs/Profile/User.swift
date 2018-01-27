import Foundation
import ObjectMapper

public class User: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let regDate = "reg_date"
    static let subscription = "subscription"
    static let settings = "settings"
    static let username = "username"
    static let profile = "profile"
  }

  // MARK: Properties
  public var regDate: Int?
  public var subscription: Subscription?
  public var settings: Settings?
  public var username: String?
  public var profile: Profile?

  
  public required init?(map: Map) {

  }

  
  public func mapping(map: Map) {
    regDate <- map[SerializationKeys.regDate]
    subscription <- map[SerializationKeys.subscription]
    settings <- map[SerializationKeys.settings]
    username <- map[SerializationKeys.username]
    profile <- map[SerializationKeys.profile]
  }
}
