import Foundation
import ObjectMapper

public class CollectionsResponse: Mappable {

    private struct SerializationKeys {
        static let items = "items"
        static let status = "status"
        static let pagination = "pagination"
    }
    
    // MARK: Properties
    public var items: [Collections]!
    public var status: Int!
    public var pagination: Pagination!
    
    public required init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        items <- map[SerializationKeys.items]
        status <- map[SerializationKeys.status]
        pagination <- map[SerializationKeys.pagination]
    }
}
