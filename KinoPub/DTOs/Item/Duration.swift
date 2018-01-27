import Foundation
import ObjectMapper

public class Duration: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let total = "total"
    static let average = "average"
  }

  // MARK: Properties
  public var total: Int?
  public var average: Int?

  
  public required init?(map: Map) {

  }

  
  public func mapping(map: Map) {
    total <- map[SerializationKeys.total]
    average <- map[SerializationKeys.average]
  }
}
