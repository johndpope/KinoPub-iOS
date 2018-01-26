//
//  Share.swift
//  KinoPub
//
//  Created by Евгений Дац on 04.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import LKAlertController
import NotificationBannerSwift
import NTDownload

class Share {
    let pasteboard = UIPasteboard.general
    
    func showActions(url: String, title: String, quality: String, poster: String, inView view: UIView? = nil, forButton button: UIBarButtonItem? = nil) {
        let action = ActionSheet()
        action.tint(.kpBlack)
        action.addAction("Скачать", style: .default, handler: { (_) in
            NTDownloadManager.shared.addDownloadTask(urlString: url, fileName: title, fileImage: poster)
            let banner = StatusBarNotificationBanner(title: "Добавлено в загрузки", style: .success)
            banner.duration = 1
            banner.show(queuePosition: .front)
        })
        action.addAction("Открыть в", style: .default, handler: { (_) in
            self.openInAppScheme(url: url, title: title, quality: quality, inView: view, forButton: button)
        })
        action.addAction("Копировать ссылку", style: .default, handler: { (_) in
            self.pasteboard.string = url
        })
        action.addAction("Отменить", style: .cancel)
        if let button = button {
            action.setBarButtonItem(button)
        } else if let view = view {
            action.setPresentingSource(view)
        }
        action.show()
    }
    
    func openInAppScheme(url: String, title: String, quality: String, inView view: UIView?, forButton button: UIBarButtonItem?) {
        let action = ActionSheet()
        action.tint(.kpBlack)
        action.addAction("Открыть в VLC", style: .default, handler: { (_) in
            let urlApp = URL(string: "vlc-x-callback://x-callback-url/download?url=" +
                url +
                "&filename=" +
                (title.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed))!)
            if UIApplication.shared.canOpenURL(urlApp!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlApp!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlApp!)
                }
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id650377962")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id650377962")!)
                }
            }
            
        })
        action.addAction("Открыть в Infuse", style: .default, handler: { (_) in
            let urlApp = URL(string: "infuse://x-callback-url/play?url=" + url)
            if UIApplication.shared.canOpenURL(urlApp!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlApp!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlApp!)
                }
                self.pasteboard.string = url
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id1136220934")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1136220934")!)
                }
            }
        })
        action.addAction("Открыть в Documents", style: .default, handler: { (_) in
            let urlApp = URL(string: url.replacingOccurrences(of: "https://", with: "rhttp://"))
            if UIApplication.shared.canOpenURL(urlApp!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlApp!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlApp!)
                }
                self.pasteboard.string = (title.replacingOccurrences(of: " / ", with: ".")) + ".mp4"
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id364901807")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id364901807")!)
                }
            }
        })
        action.addAction("Открыть в nPlayer", style: .default, handler: { (_) in
            let urlApp = URL(string: url.replacingOccurrences(of: "https://", with: "nplayer-http://"))
            if UIApplication.shared.canOpenURL(urlApp!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlApp!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlApp!)
                }
                self.pasteboard.string = url
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id1078835991")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1078835991")!)
                }
            }
        })
        action.addAction("Отменить", style: .cancel)
        if let button = button {
            action.setBarButtonItem(button)
        } else if let view = view {
            action.setPresentingSource(view)
        }
        action.show()
    }
}
