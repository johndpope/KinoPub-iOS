//
//  ModelsAssembly.swift
//  KinoPub
//
//  Created by hintoz on 03.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

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
}
