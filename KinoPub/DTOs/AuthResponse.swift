import Foundation
import ObjectMapper

public class AuthResponse: Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let userCode = "user_code"
        static let verificationUri = "verification_uri"
        static let interval = "interval"
        static let code = "code"
        static let expiresIn = "expires_in"
    }

    // MARK: Properties
    public var userCode: String?
    public var verificationUri: String?
    public var interval: Int?
    public var code: String?
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
        userCode <- map[SerializationKeys.userCode]
        verificationUri <- map[SerializationKeys.verificationUri]
        interval <- map[SerializationKeys.interval]
        code <- map[SerializationKeys.code]
        expiresIn <- map[SerializationKeys.expiresIn]
    }
}
