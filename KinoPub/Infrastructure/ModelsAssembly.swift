import Foundation
import Dip

class ModelsAssembly {
    static func assembly() -> DependencyContainer {
        return DependencyContainer { container in
            unowned let container = container

            container.register(ComponentScope.singleton) {
                AccountManagerImp() as AccountManager
            }
            container.register(ComponentScope.singleton) {
                LogViewsManagerImp() as LogViewsManager
            }
            container.register(ComponentScope.singleton) {
                MediaManager() as MediaManager
            }
            container.register { try AuthModel(accountManager: container.resolve()) }
            container.register { try VideoItemsModel(accountManager: container.resolve()) }
            container.register { try VideoItemModel(accountManager: container.resolve()) }
            container.register { try BookmarksModel(accountManager: container.resolve()) }
            container.register { try CollectionModel(accountManager: container.resolve()) }
            container.register { try FilterModel(accountManager: container.resolve()) }
            container.register { try ProfileModel(accountManager: container.resolve()) }

        }
    }
    
    static let mediaManager = MediaManager()
    static let accountManager: AccountManager = AccountManagerImp()
    static let logViewsManager: LogViewsManager = LogViewsManagerImp()
    
    static let authModel = { AuthModel(accountManager: accountManager) }
    static let videoItemModel = { VideoItemModel(accountManager: accountManager) }
    static let videoItemsModel = { VideoItemsModel(accountManager: accountManager) }
    static let bookmarksModel = { BookmarksModel(accountManager: accountManager) }
    static let collectionModel = { CollectionModel(accountManager: accountManager) }
    static let filterModel = { FilterModel(accountManager: accountManager) }
    static let profileModel = { ProfileModel(accountManager: accountManager) }
    
}
