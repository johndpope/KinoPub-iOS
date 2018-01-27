import Foundation
import ObjectMapper

public class CollectionsResponse: Mappable {

    private struct SerializationKeys {
        static let items = "items"
        static let status = "status"
        static let pagination = "pagination"
    }
    
    // MARK: Properties
    public var items: [Collections]?
    public var status: Int?
    public var pagination: Pagination?
    
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
        items <- map[SerializationKeys.items]
        status <- map[SerializationKeys.status]
        pagination <- map[SerializationKeys.pagination]
    }
}
