import UIKit
import LKAlertController
import NotificationBannerSwift
import NTDownload

class Share {
    enum PlayerApplication: String {
        case VLC        = "id650377962"
        case Infuse     = "id1136220934"
        case Documents  = "id364901807"
        case nPlayer    = "id1078835991"
        
        func convert(url: String, title: String? = nil) -> URL? {
            switch self {
            case .VLC:
                var urlString = "vlc-x-callback://x-callback-url/download?url=" + url
                if let title = title,
                    let encodedString = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    urlString += "&filename=\(encodedString)"
                }
            case .Infuse:
                return URL(string: "infuse://x-callback-url/play?url=" + url)
            case .Documents:
                return URL(string: url.replacingOccurrences(of: "https://", with: "rhttp://"))
            case .nPlayer:
                return URL(string: url.replacingOccurrences(of: "https://", with: "nplayer-http://"))
            }
            return URL(string: "")!
        }
        
        func appstoreURL() -> URL {
            return URL(string: "itms-apps://itunes.apple.com/app/\(rawValue)")!
        }
    }
    
    let pasteboard = UIPasteboard.general
    
    func showActions(url: String, title: String, quality: String, poster: String, inView view: UIView? = nil, forButton button: UIBarButtonItem? = nil) {
        let action = ActionSheet()
            .tint(.kpBlack)
            .addAction("Скачать", style: .default, handler: { (_) in
                NTDownloadManager.shared.addDownloadTask(urlString: url, fileName: title, fileImage: poster)
                let banner = StatusBarNotificationBanner(title: "Добавлено в загрузки", style: .success)
                banner.duration = 1
                banner.show(queuePosition: .front)
            })
            .addAction("Открыть в", style: .default, handler: { (_) in
                self.openInAppScheme(url: url, title: title, quality: quality, inView: view, forButton: button)
            })
            .addAction("Копировать ссылку", style: .default, handler: { (_) in
                self.pasteboard.string = url
            })
            .addAction("Отменить", style: .cancel)
        if let button = button {
            action.setBarButtonItem(button)
        } else if let view = view {
            action.setPresentingSource(view)
        }
        action.show()
        Helper.hapticGenerate(style: .medium)
    }
    
    func open(url rawUrl: String, player: PlayerApplication, pasteboardValue: String? = nil) {
        guard let url = player.convert(url: rawUrl) else { return }
        guard UIApplication.shared.canOpenURL(url) else {
            return UIApplication.shared.open(url: player.appstoreURL())
        }
        
        UIApplication.shared.open(url: url)
        pasteboardValue.map { self.pasteboard.string = $0}
    }
    
    func openInAppScheme(url: String, title: String, quality: String, inView view: UIView?, forButton button: UIBarButtonItem?) {
        let action = ActionSheet()
            .tint(.kpBlack)
            .addAction("Открыть в VLC", style: .default, handler: { [weak self] (_) in
                self?.open(url: url, player: .VLC)
            })
            .addAction("Открыть в Infuse", style: .default, handler: { [weak self] (_) in
                self?.open(url: url, player: .Infuse, pasteboardValue: url)
            })
            .addAction("Открыть в Documents", style: .default, handler: { [weak self] (_) in
                self?.open(url: url,
                           player: .Documents,
                           pasteboardValue: (title.replacingOccurrences(of: " / ", with: ".")) + ".mp4")
            })
            .addAction("Открыть в nPlayer", style: .default, handler: { [weak self] (_) in
                self?.open(url: url, player: .nPlayer, pasteboardValue: url)
            })
            .addAction("Отменить", style: .cancel)
        if let button = button {
            action.setBarButtonItem(button)
        } else if let view = view {
            action.setPresentingSource(view)
        }
        action.show()
        Helper.hapticGenerate(style: .medium)
    }
}
