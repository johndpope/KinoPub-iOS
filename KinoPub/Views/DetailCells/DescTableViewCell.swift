import UIKit
import Atributika

class DescTableViewCell: UITableViewCell {

    @IBOutlet weak var descTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var warnStasckView: UIStackView!
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var warnTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clear
        configureLabels()
    }

    func configure(withItem item: Item) {
        let plot = item.plot?.replacingOccurrences(of: "\r\n\r\n", with: "\n\n")
        if let desc = plot?.components(separatedBy: "\n\n") {
            let labelDanger = Style("span").font(.systemFont(ofSize: 15)).foregroundColor(.red)
            let labelInfo = Style("div").font(.systemFont(ofSize: 15)).foregroundColor(.red)
            let strDanger = Style("danger").font(.systemFont(ofSize: 15)).foregroundColor(.red)
            
            var descStr = ""
            var warn = ""
            
            if item.advert! {
                warn += "<danger>Присутствуют голосовые или текстовые вставки рекламы!</danger>"
            }
            if item.poorQuality! {
                if warn != "" { warn += "\n\n" }
                warn += "<danger>Фильм с сомнительным качеством картинки или звука, возможно наличие вшитых субтитров!</danger>"
            }
            
            if desc.count > 1 {
                for _desc in desc {
                    if _desc.first == "<" {
                        if warn != "" { warn += "\n\n" }
                        warn += _desc
                    } else {
                        if descStr != "" { descStr += "\n\n" }
                        descStr += _desc
                    }
                }
            } else {
                descStr += desc[0]
            }


            if warn != "" {
                warnLabel.attributedText = warn.style(tags: [labelDanger, labelInfo, strDanger]).attributedString
                warnStasckView.isHidden = false
            }
            
            if descStr != "" {
                descLabel.text = descStr
            }
        }
    }

    func configureLabels() {
        descLabel.textColor = .kpGreyishTwo
        descTitleLabel.textColor = .kpGreyishBrown
        warnLabel.textColor = .kpGreyishTwo
        warnTitleLabel.textColor = .kpGreyishBrown
        warnStasckView.isHidden = true
    }
}
