import UIKit
import SafariServices

class AboutViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var devNameLabel: UILabel!
    @IBOutlet weak var devInfoLabel: UILabel!
    
    @IBOutlet weak var designerNameLabel: UILabel!
    @IBOutlet weak var designerInfoLabel: UILabel!
    
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var copyLabel: UILabel!
    
    @IBAction func donateButtonPressed(_ sender: Any) {
        openSafariVC(url: "http://dats.xyz/donate.html")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }

        configView()
    }

    func configView() {
        view.backgroundColor = .kpBackground
        
        iconImageView.dropShadow(color: .kpBlack, opacity: 0.3, offSet: CGSize(width: 0, height: 2), radius: 6, scale: true)
        
        titleLabel.textColor = .kpOffWhite
        versionLabel.textColor = .kpGreyishBrown
        infoLabel.textColor = .kpGreyishTwo
        
        devNameLabel.textColor = .kpMarigold
        devInfoLabel.textColor = .kpGreyishTwo
        
        designerNameLabel.textColor = .kpMarigold
        designerInfoLabel.textColor = .kpGreyishTwo
        
        donateButton.borderColor = .kpGreyishBrown
        donateButton.tintColor = .kpGreyishTwo
        
        copyLabel.textColor = .kpGreyishBrown
        
        versionLabel.text = Config.shared.appVersion
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(openDevSite))
        devNameLabel.isUserInteractionEnabled = true
        devNameLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(openDesSite))
        designerNameLabel.isUserInteractionEnabled = true
        designerNameLabel.addGestureRecognizer(tap2)
    }
    
    // MARK: - Navigation
    
    static func storyboardInstance() -> AboutViewController? {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AboutViewController
    }
    
    func openSafariVC(url: String) {
        let svc = SFSafariViewController(url: URL(string: url)!)
        self.present(svc, animated: true, completion: nil)
    }
    
    @objc func openDevSite() {
        openSafariVC(url: "http://dats.xyz")
    }
    
    @objc func openDesSite() {
        openSafariVC(url: "http://www.alexmarco.ru")
    }

}
