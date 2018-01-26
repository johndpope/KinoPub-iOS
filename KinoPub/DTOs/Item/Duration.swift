//
//  Duration.swift
//
//  Created by hintoz on 05.03.17
//  Copyright (c) Evgeny Dats. All rights reserved.
//

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
    total <- map[SerializationKeys.total]
    average <- map[SerializationKeys.average]
  }
}