import Foundation
import Alamofire
import Crashlytics

class RequestFactory {
    var account: KinopubAccount? {
        return accountManager!.account
    }

    let baseAPIURL: String

    var accountManager: AccountManager?
    var authorizedSessionManager: SessionManager?

    init() {
        baseAPIURL = Config.kinopub.base
    }

    func receiveDeviceCodeRequest() -> DataRequest {
        let parameters = ["grant_type": "device_code",
                          "client_id": Config.shared.kinopubClientId,
                          "client_secret": Config.shared.kinopubClientSecret
        ]
        let requestUrl = baseAPIURL + "oauth2/device"
        return Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
    }

    func receiveCheckCodeApproveRequest(_ code: String) -> DataRequest {
        let parameters = ["grant_type": "device_token",
                          "client_id": Config.shared.kinopubClientId,
                          "client_secret": Config.shared.kinopubClientSecret,
                          "code": code
            ]
        let requestUrl = baseAPIURL + "oauth2/device"
        return Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
    }

    func notifyAboutDeviceRequest() -> DataRequest {
        let parameters = ["title": Config.shared.clientTitle,
                          "hardware": UIDevice().model,
                          "software": UIDevice().systemName + "/" + UIDevice().systemVersion + " KinoPub-iOS/dats.xyz"
        ]
        let requestUrl = baseAPIURL + "v1/device/notify"
        return sessionManager().request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
    }

    func receiveItemsRequest(withParameters parameters: [String: String], from: String?) -> DataRequest {
        var fromString = ""
        if from != nil {
            fromString = "/" + from!
        }
        let requestUrl = baseAPIURL + "v1/items" + fromString
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }
    
    func receiveSimilarItemsRequest(id: String) -> DataRequest {
        let parameters = ["id": id]
        let requestUrl = baseAPIURL + "v1/items/similar"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }

    func changeWatchingStatusRequest(id: Int, video: Int?, season: Int, status: Int?) -> DataRequest {
        var parameters = ["id": String(id),
                          "season": String(season)
//                          "status": String(describing: status)
        ] as [String: String]
        if video != nil {
            parameters["video"] = "\(video!)"
        }
        let requestUrl = baseAPIURL + "v1/watching/toggle"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }

    func changeMarktimeRequest(id: Int, time: TimeInterval, video: Int, season: Int?) -> DataRequest {
        let parameters = ["id": String(id),
                          "video": String(video),
                          "season": "\(season ?? 0)",
                          "time": String(time)
            ] as [String: String]
        let requestUrl = baseAPIURL + "v1/watching/marktime"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }

    func receiveWatchingSeriesRequest(_ subscribed: Int) -> DataRequest {
        let parameters = ["subscribed": String(subscribed)] as [String: String]
        let requestUrl = baseAPIURL + "v1/watching/serials"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }

    func receiveWatchingMovieRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/watching/movies"
        return sessionManager().request(requestUrl, method: .get)
    }

    func changeWatchlistRequest(id: String) -> DataRequest {
        let parameters = ["id": id] as [String: String]
        let requestUrl = baseAPIURL + "v1/watching/togglewatchlist"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }

    func receiveUserProfileRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/user"
        return sessionManager().request(requestUrl)
    }

    func receiveCurrentDeviceRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/device/info"
        return sessionManager().request(requestUrl)
    }

    func unlinkDeviceRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/device/unlink"
        return sessionManager().request(requestUrl, method: .post)
    }
    
    // MARK: - Bookmarks
    func receiveBookmarksRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/bookmarks"
        return sessionManager().request(requestUrl)
    }
    
    func receiveBookmarkItemsRequest(id: String, page: String) -> DataRequest {
        let parameters = ["page": page] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/" + id
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }
    
    func createBookmarkFolderRequest(title: String) -> DataRequest {
        let parameters = ["title": title] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/create"
        return sessionManager().request(requestUrl, method: .post, parameters: parameters)
    }
    
    func removeBookmarkFolderRequest(folder: String) -> DataRequest {
        let parameters = ["folder": folder] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/remove-folder"
        return sessionManager().request(requestUrl, method: .post, parameters: parameters)
    }
    
    func removeItemFromFolderRequest(item: String, folder: String) -> DataRequest {
        let parameters = ["folder": folder,
                          "item": item] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/remove-item"
        return sessionManager().request(requestUrl, method: .post, parameters: parameters)
    }
    
    func addItemToFolderRequest(item: String, folder: String) -> DataRequest {
        let parameters = ["folder": folder,
                          "item": item] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/add"
        return sessionManager().request(requestUrl, method: .post, parameters: parameters)
    }
    
    func toggleItemToFolderRequest(item: String, folder: String) -> DataRequest {
        let parameters = ["folder": folder,
                          "item": item] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/toggle-item"
        return sessionManager().request(requestUrl, method: .post, parameters: parameters)
    }
    
    func receiveItemFoldersRequest(item: String) -> DataRequest {
        let parameters = ["item": item] as [String: String]
        let requestUrl = baseAPIURL + "v1/bookmarks/get-item-folders"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }
    
    // MARK: - Collections
    func receiveCollectionsRequest(page: String) -> DataRequest {
        let parameters = ["page": page]
        let requestUrl = baseAPIURL + "v1/collections"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }
    
    func receiveItemsCollectionRequest(parameters: [String: String]) -> DataRequest {
        //let parameters = ["id": id]
        let requestUrl = baseAPIURL + "v1/collections/view"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }
    
    // MARK: - Filters
    func receiveGenresRequest(type: String) -> DataRequest {
        let parameters = ["type": type]
        let requestUrl = baseAPIURL + "v1/genres"
        return sessionManager().request(requestUrl, method: .get, parameters: parameters)
    }
    
    func receiveCountryRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/countries"
        return sessionManager().request(requestUrl, method: .get)
    }
    
    func receiveSubtitlesRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/subtitles"
        return sessionManager().request(requestUrl, method: .get)
    }
    
    // MARK: - TV
    func receiveTVChanelsRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/tv"
        return sessionManager().request(requestUrl, method: .get)
    }
    
    func receiveUserPalylistsRequest() -> DataRequest {
        let requestUrl = baseAPIURL + "v1/playlists"
        return sessionManager().request(requestUrl, method: .get)
    }
    
    // MARK: - Session Manager
    private func sessionManager() -> SessionManager {
        if authorizedSessionManager != nil {
            return authorizedSessionManager!
        }

        let configuration = URLSessionConfiguration.default
        let sessionManager = Alamofire.SessionManager(configuration: configuration)

        let authHandler = OAuthHandler(accessToken: account!.accessToken)
        authHandler.delegate = self
        sessionManager.adapter = authHandler
        sessionManager.retrier = authHandler
        authorizedSessionManager = sessionManager
        return authorizedSessionManager!
    }
}

extension RequestFactory: OAuthHandlerDelegate {
    func handlerDidUpdate(accessToken token: String, refreshToken: String) {
        accountManager!.silentlyUpdateAccountWith(accessToken: token, refreshToken: refreshToken)
        Answers.logLogin(withMethod: "token refresh", success: 1, customAttributes: nil)
        Answers.logCustomEvent(withName: "Token Refresh", customAttributes: ["Method": "handlerDidUpdate"])
    }

    func handlerDidFailedToUpdateToken() {
        accountManager!.logoutAccount()
        Answers.logLogin(withMethod: "token refresh", success: 0, customAttributes: nil)
        Answers.logCustomEvent(withName: "Token Refresh", customAttributes: ["Method": "handlerDidFailedToUpdateToken"])
    }

    func refreshTokenRequest() -> DataRequest {
        let parameters = ["grant_type": "refresh_token",
                          "client_id": Config.shared.kinopubClientId,
                          "client_secret": Config.shared.kinopubClientSecret,
                          "refresh_token": account?.refreshToken
        ] as! [String: String]
        let requestUrl = baseAPIURL + "oauth2/device"
        return Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
    }
}
