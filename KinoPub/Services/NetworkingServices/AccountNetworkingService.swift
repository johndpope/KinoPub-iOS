import Foundation
import Alamofire
import AlamofireObjectMapper

class AccountNetworkingService {
    var requestFactory: RequestFactory

    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }

    func notifyAboutDevice(completed: @escaping (_ error: Error?) -> Void) {
        requestFactory.notifyAboutDeviceRequest().validate().responseJSON { response in
            switch response.result {
            case .success:
                completed(nil)
            case .failure(let error):
                completed(error)
            }
        }
    }

    func receiveCurrentDevice(completed: @escaping (_ responseObject: DeviceRequest?, _ error: Error?) -> Void) {
        requestFactory.receiveCurrentDeviceRequest()
            .validate().responseObject { (response: DataResponse<DeviceRequest>) in
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

    func unlinkDevice(completed: @escaping (_ error: Error?) -> Void) {
        requestFactory.unlinkDeviceRequest().validate().responseJSON { response in
            switch response.result {
            case .success:
                completed(nil)
            case .failure(let error):
                completed(error)
            }
        }
    }

    func receiveUserProfile(completed: @escaping (_ responseObject: ProfileRequest?, _ error: Error?) -> Void) {
        requestFactory.receiveUserProfileRequest()
            .validate().responseObject { (response: DataResponse<ProfileRequest>) in
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
