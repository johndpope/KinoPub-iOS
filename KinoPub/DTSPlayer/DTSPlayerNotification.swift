//
//  DTSPlayerNotification.swift
//  KinoPub
//
//  Created by Евгений Дац on 15.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation

public extension Notification.Name {
    ///
    static let DTSPlayerPlaybackTimeDidChange = Notification.Name(rawValue: "xyz.dtsplayer.DTSPlayerPlaybackTimeDidChange")
    
    ///
    static let DTSPlayerViewControllerDismissed = Notification.Name(rawValue: "com.dtsplayer.DTSPlayerViewControllerDismissed")
}
