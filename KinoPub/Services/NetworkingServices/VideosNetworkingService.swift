import Foundation
import Alamofire
import AlamofireObjectMapper

class VideosNetworkingService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveItems(withParameters parameters: [String: String], from: String?, cancelPrevious: Bool = false, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        if cancelPrevious { stopAllSessions() }
        requestFactory.receiveItemsRequest(withParameters: parameters, from: from)
            .validate()
            .responseObject { (response: DataResponse<ItemResponse>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                    break
                case .failure(let error):
                    completed(nil, error)
                }
        }
    }
    
    func receiveWatchingSeries(_ subscribed: Int, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.receiveWatchingSeriesRequest(subscribed)
            .validate()
            .responseObject { (response: DataResponse<ItemResponse>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                    break
                case .failure(let error):
                    completed(nil, error)
                }
        }
    }
    
    func receiveWatchingMovie(completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.receiveWatchingMovieRequest()
            .validate()
            .responseObject { (response: DataResponse<ItemResponse>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                    break
                case .failure(let error):
                    completed(nil, error)
                }
        }
    }
    
    func receiveItemsCollection(parameters: [String : String], completed: @escaping (_ responseArray: Array<Item>?, _ error: Error?) -> Void) {
        requestFactory.receiveItemsCollectionRequest(parameters: parameters)
            .validate()
            .responseArray(keyPath: "items") { (response: DataResponse<[Item]>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completed(nil, error)
                }
        }
    }
    
    func receiveSimilarItems(id: String, completed: @escaping (_ responseArray: Array<Item>?, _ error: Error?) -> Void) {
        requestFactory.receiveSimilarItemsRequest(id: id)
            .validate()
            .responseArray(keyPath: "items") { (response: DataResponse<[Item]>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completed(nil, error)
                }
        }
    }
    
    private func stopAllSessions() {
        requestFactory.authorizedSessionManager?.session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach { $0.cancel() }
        })
    }
}
