import Foundation
import Alamofire
import AlamofireObjectMapper

class TVNetworkingService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveTVChanels(completed: @escaping (_ responseArray: Array<Channels>?, _ error: Error?) -> Void) {
        requestFactory.receiveTVChanelsRequest()
            .validate()
            .responseArray(keyPath: "channels") { (response: DataResponse<[Channels]>) in
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
