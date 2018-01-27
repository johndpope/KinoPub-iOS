import AVFoundation

extension AVPlayer {
    
    public var durationWatched: TimeInterval {
        var duration: TimeInterval = 0
        if let events = self.currentItem?.accessLog()?.events {
            for event in events {
                duration += event.durationWatched
            }
        }
        return duration
    }
    
    public var duration: TimeInterval? {
        if let  duration = self.currentItem?.duration  {
            return CMTimeGetSeconds(duration)
        }
        return nil
    }
    
    public var currentTime: TimeInterval? {
        return CMTimeGetSeconds(self.currentTime())
    }
}
