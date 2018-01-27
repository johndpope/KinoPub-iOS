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

    public required init?(map: Map) {

    }

    public func mapping(map: Map) {
        refreshToken <- map[SerializationKeys.refreshToken]
        accessToken <- map[SerializationKeys.accessToken]
        expiresIn <- map[SerializationKeys.expiresIn]
    }
}
