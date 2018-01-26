//
//  TokenResponse.swift
//  KinoPub
//
//  Created by hintoz on 02.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import ObjectMapper

public class TokenResponse: Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let refreshToken = "refresh_token"
        static let accessToken = "access_token"
        static let expiresIn = "expires_in"
    }

    // MARK: Properties
    public var refreshToken: String?
    public var accessToken: String?
    public var expiresIn: Int?

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
        refreshToken <- map[SerializationKeys.refreshToken]
        accessToken <- map[SerializationKeys.accessToken]
        expiresIn <- map[SerializationKeys.expiresIn]
    }
}
