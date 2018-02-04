import Foundation
import Alamofire
import AlamofireObjectMapper

class LogViewsNetworkingService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func changeWatchingStatus(id: Int, video: Int?, season: Int, status: Int?, completed: @escaping (_ responseObject: WatchingToggle?, _ error: Error?) -> Void) {
        requestFactory.changeWatchingStatusRequest(id: id, video: video, season: season, status: status)
            .validate()
            .responseObject { (response: DataResponse<WatchingToggle>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    completed(nil, error)
                }
        }
    }
    
    func changeWatchlist(id: String, completed: @escaping (_ responseObject: WatchingToggle?, _ error: Error?) -> Void) {
        requestFactory.changeWatchlistRequest(id: id)
            .validate()
            .responseObject { (response: DataResponse<WatchingToggle>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    completed(nil, error)
                }
        }
    }
    
    func changeMarktime(id: Int, time: TimeInterval, video: Int, season: Int?, completed: @escaping (_ responseObject: WatchingToggle?, _ error: Error?) -> Void) {
        requestFactory.changeMarktimeRequest(id: id, time: time, video: video, season: season)
            .validate()
            .responseObject { (response: DataResponse<WatchingToggle>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    completed(nil, error)
                }
        }
    }
}
