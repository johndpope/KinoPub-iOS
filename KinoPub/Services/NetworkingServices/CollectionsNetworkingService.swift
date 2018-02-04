import Foundation
import Alamofire
import AlamofireObjectMapper

class CollectionsNetworkingService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveCollections(page: String, completed: @escaping (_ responseObject: CollectionsResponse?, _ error: Error?) -> Void) {
        requestFactory.receiveCollectionsRequest(page: page)
            .validate()
            .responseObject { (response: DataResponse<CollectionsResponse>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                case .failure(let error):
                    completed(nil, error)
                }
        }
    }
}
