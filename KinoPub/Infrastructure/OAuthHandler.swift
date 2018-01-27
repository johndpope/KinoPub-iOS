import Foundation
import Alamofire
import AlamofireObjectMapper
import Crashlytics

protocol OAuthHandlerDelegate: class {
    func handlerDidUpdate(accessToken token: String, refreshToken: String)
    func handlerDidFailedToUpdateToken()
    func refreshTokenRequest() -> DataRequest
}

class OAuthHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ success: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void

    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()

    private let lock = NSLock()

    private var accessToken: String

    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []

    weak var delegate: OAuthHandlerDelegate?

    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    // MARK: - RequestAdapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let url = urlRequest.url, !url.path.hasPrefix("oauth2") {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        return urlRequest
    }

    // MARK: - RequestRetrier
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }

        Answers.logCustomEvent(withName: "RequestRetrier", customAttributes: ["ERROR:": error, "Status Code": (request.task?.response as? HTTPURLResponse)?.statusCode ?? "unknown"])

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.delegate?.handlerDidUpdate(accessToken: accessToken, refreshToken: refreshToken)
                    }

                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()

                    if !succeeded {
                        strongSelf.delegate?.handlerDidFailedToUpdateToken()
                    }
                }
            }
        } else {
            completion(false, 0.0)
        }
    }

    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }

        isRefreshing = true
        let request = delegate!.refreshTokenRequest()
        request.validate()
            .responseObject { (response: DataResponse<TokenResponse>) in
                switch response.result {
                case .success:
                    let tokens = response.result.value!
                    completion(true, tokens.accessToken, tokens.refreshToken)
                    break
                case .failure:
                    completion(false, nil, nil)
                    Answers.logCustomEvent(withName: "refreshTokens", customAttributes: ["Error": response.error ?? "unknown"])
                    break
                }
        }
    }
}
