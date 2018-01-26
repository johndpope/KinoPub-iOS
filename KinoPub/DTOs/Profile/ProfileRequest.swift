//
//  ProfileRequest.swift
//
//  Created by hintoz on 26.05.17
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public class ProfileRequest: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let status = "status"
    static let user = "user"
  }

  // MARK: Properties
  public var status: Int?
  public var user: User?

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
    user <- map[SerializationKeys.user]
  }
}
