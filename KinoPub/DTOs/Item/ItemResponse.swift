import Foundation
import ObjectMapper

public class ItemResponse: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let status = "status"
    static let item = "item"

    static let pagination = "pagination"
    static let items = "items"
  }

  // MARK: Properties
  public var status: Int?
  public var item: Item?

  public var pagination: Pagination?
  public var items: [Item]?

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
    status <- map[SerializationKeys.status]
    item <- map[SerializationKeys.item]

    pagination <- map[SerializationKeys.pagination]
    items <- map[SerializationKeys.items]
  }
}
