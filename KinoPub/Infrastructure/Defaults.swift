//
//  Defaults.swift
//  KinoPub
//
//  Created by hintoz on 03.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let accessToken = DefaultsKey<String?>("accessToken")
    static let refreshToken = DefaultsKey<String?>("refreshToken")

    static let streamType = DefaultsKey<String>("streamType")
    static let logViews = DefaultsKey<Bool>("logViews")
    static let isCustomPlayer = DefaultsKey<Bool>("isCustomPlayer")
    static let canSlideProgress = DefaultsKey<Bool>("canSlideProgress")
    static let leftSlideTrigger = DefaultsKey<String>("leftSlideTrigger")
    static let rightSlideTrigger = DefaultsKey<String>("rightSlideTrigger")

    static let canSortSeasons = DefaultsKey<Bool>("canSortSeasons")
    static let canSortEpisodes = DefaultsKey<Bool>("canSortEpisodes")

    static let showRatringInPoster = DefaultsKey<Bool>("showRatringInPoster")
    static let clientTitle = DefaultsKey<String>("clientTitle")
    static let menuItem = DefaultsKey<Int>("menuItem")
    
    // Config
    static let kinopubClientId = DefaultsKey<String>("kinopubClientId")
    static let kinopubClientSecret = DefaultsKey<String>("kinopubClientSecret")
    static let kinopubDomain = DefaultsKey<String>("kinopubDomain")
    static let delayViewMarkTime = DefaultsKey<TimeInterval>("delayViewMarkTime")
}
