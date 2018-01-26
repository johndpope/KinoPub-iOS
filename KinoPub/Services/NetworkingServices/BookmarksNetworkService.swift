//
//  BookmarksNetworkService.swift
//  KinoPub
//
//  Created by Евгений Дац on 04.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class BookmarksNetworkService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveBookmarks(completed: @escaping (_ responseArray: Array<Bookmarks>?, _ error: Error?) -> Void) {
        requestFactory.receiveBookmarksRequest()
            .validate()
            .responseArray(keyPath: "items") { (response: DataResponse<[Bookmarks]>) in
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
    
    func receiveBookmarkItems(id: String, page: String, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.receiveBookmarkItemsRequest(id: id, page: page)
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
    
    func createBookmarkFolder(title: String, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.createBookmarkFolderRequest(title: title)
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
    
    func removeBookmarkFolder(folder: String, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.removeBookmarkFolderRequest(folder: folder)
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
    
    func removeItemFromFolder(item: String, folder: String, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.removeItemFromFolderRequest(item: item, folder: folder)
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
    
    func addItemToFolder(item: String, folder: String, completed: @escaping (_ responseObject: ItemResponse?, _ error: Error?) -> Void) {
        requestFactory.addItemToFolderRequest(item: item, folder: folder)
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
    
    func toggleItemToFolder(item: String, folder: String, completed: @escaping (_ responseObject: BookmarksToggle?, _ error: Error?) -> Void) {
        requestFactory.toggleItemToFolderRequest(item: item, folder: folder)
            .validate()
            .responseObject { (response: DataResponse<BookmarksToggle>) in
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
    
    func receiveItemFolders(item: String, completed: @escaping (_ responseArray: Array<Bookmarks>?, _ error: Error?) -> Void) {
        requestFactory.receiveItemFoldersRequest(item: item)
            .validate()
            .responseArray(keyPath: "folders") { (response: DataResponse<[Bookmarks]>) in
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
