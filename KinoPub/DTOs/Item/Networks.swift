//
//  Networks.swift
//  KinoPub
//
//  Created by Евгений Дац on 22.12.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import ObjectMapper

public class Networks: Mappable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let id = "id"
        static let name = "name"
    }
    
    // MARK: Properties
    public var id: Int?
    public var name: String?
    
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
        id <- map[SerializationKeys.id]
        name <- map[SerializationKeys.name]
    }
}
