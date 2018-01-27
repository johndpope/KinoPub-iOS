import Foundation
import Alamofire
import AlamofireObjectMapper

class FilterNetworkingService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveItemsGenres(type: String, completed: @escaping (_ responseArray: Array<Genres>?, _ error: Error?) -> Void) {
        requestFactory.receiveGenresRequest(type: type)
            .validate()
            .responseArray(keyPath: "items") { (response: DataResponse<[Genres]>) in
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
    
    func receiveItemsCountry(completed: @escaping (_ responseArray: Array<Countries>?, _ error: Error?) -> Void) {
        requestFactory.receiveCountryRequest()
            .validate()
            .responseArray(keyPath: "items") { (response: DataResponse<[Countries]>) in
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
    
    func receiveSubtitleItems(completed: @escaping (_ responseArray: Array<SubtitlesList>?, _ error: Error?) -> Void) {
        requestFactory.receiveSubtitlesRequest()
            .validate()
            .responseArray(keyPath: "items") { (response: DataResponse<[SubtitlesList]>) in
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
}
