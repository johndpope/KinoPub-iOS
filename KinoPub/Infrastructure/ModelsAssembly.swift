struct Container {
    struct Manager {
        static let media = MediaManager()
        static let account: AccountManager = AccountManagerImp()
        static let logViews: LogViewsManager = LogViewsManagerImp()
    }
    
    struct ViewModel {
        static let auth = { AuthModel(accountManager: Manager.account) }
        static let videoItem = { VideoItemModel(accountManager: Manager.account) }
        static let videoItems = { VideoItemsModel(accountManager: Manager.account) }
        static let bookmarks = { BookmarksModel(accountManager: Manager.account) }
        static let collection = { CollectionModel(accountManager: Manager.account) }
        static let filter = { FilterModel(accountManager: Manager.account) }
        static let profile = { ProfileModel(accountManager: Manager.account) }
        static let tv = { TVModel(accountManager: Manager.account) }
    }
}
