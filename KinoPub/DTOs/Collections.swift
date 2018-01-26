//
//  Collections.swift
//
//  Created by Евгений Дац on 09.07.17
//  Copyright (c) Evgeny Dats. All rights reserved.
//

import Foundation
import ObjectMapper

public class Collections: Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let updated = "updated"
        static let posters = "posters"
        static let watchers = "watchers"
        static let views = "views"
        static let id = "id"
        static let created = "created"
        static let title = "title"
    }
    
    // MARK: Properties
    public var updated: Int?
    public var posters: Posters?
    public var watchers: Int?
    public var views: Int?
    public var id: Int?
    public var created: Int?
    public var title: String?
    
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
        updated <- map[SerializationKeys.updated]
        posters <- map[SerializationKeys.posters]
        watchers <- map[SerializationKeys.watchers]
        views <- map[SerializationKeys.views]
        id <- map[SerializationKeys.id]
        created <- map[SerializationKeys.created]
        title <- map[SerializationKeys.title]
    }
}
