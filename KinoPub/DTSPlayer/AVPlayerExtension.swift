//
//  AVPlayerExtension.swift
//  KinoPub
//
//  Created by Евгений Дац on 15.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import AVFoundation

extension AVPlayer {
    ///
    public var durationWatched: TimeInterval {
        var duration: TimeInterval = 0
        if let events = self.currentItem?.accessLog()?.events {
            for event in events {
                duration += event.durationWatched
            }
        }
        return duration
    }
    
    /// Total time
    public var duration: TimeInterval? {
        if let  duration = self.currentItem?.duration  {
            return CMTimeGetSeconds(duration)
        }
        return nil
    }
    
    /// Playing time
    public var currentTime: TimeInterval? {
        return CMTimeGetSeconds(self.currentTime())
    }
}
