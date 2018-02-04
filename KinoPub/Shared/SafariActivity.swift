import UIKit

class SafariActivity: UIActivity {
    var url: URL?
    
    public override var activityImage: UIImage? {
        return UIImage(named: "SafariActivity")!
    }
    
    public override var activityTitle: String? {
        return "Открыть в Safari"
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let url = item as? URL, UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let url = item as? URL, UIApplication.shared.canOpenURL(url) {
                self.url = url
            }
        }
    }
    
    override func perform() {
        var completed = false
        
        if let url = url {
            completed = UIApplication.shared.openURL(url)
        }
        
        activityDidFinish(completed)
    }
}
