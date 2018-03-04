import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var voiceLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var qualityLabel: UILabel!
    @IBOutlet weak var networksLabel: UILabel!

    @IBOutlet weak var genreTitleLabel: UILabel!
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var voiceTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var qualityTitleLabel: UILabel!
    @IBOutlet weak var networksTitleLabel: UILabel!
    
    @IBOutlet weak var voiceStasckView: UIStackView!
    @IBOutlet weak var networksStasckView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear
        configureLabels()
    }

    func configure(with item: Item) {
        if let genres = item.genres {
            genreLabel.text = genres.flatMap{$0.title}.joined(separator: ", ")
        }
        
        var epDuration = ""
        var allDuration = ""
        if item.type == ItemType.shows.rawValue ||
            item.type == ItemType.docuserial.rawValue ||
            item.type == ItemType.tvshows.rawValue {
            epDuration = "Серия: "
            allDuration = "Сериал: "
        }

        if let duration = item.duration?.average {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            
            var string = "\(epDuration)"
            let formattedString = formatter.string(from: TimeInterval(duration))!
            string += formattedString

            if let durTotal = item.duration?.total, duration != durTotal {
                string += "\n\(allDuration)"
                let formattedString = formatter.string(from: TimeInterval(durTotal))!
                string += formattedString
            }

            durationLabel.text = string
        }

        if let voice = item.voice, voice != "" {
            voiceStasckView.isHidden = false
            voiceLabel.text = voice
        } else {
            voiceStasckView.isHidden = true
        }
        
        if let networks = item.networks {
            networksStasckView.isHidden = false
            networksLabel.text = networks
        } else {
            networksStasckView.isHidden = true
        }

        if let subs = item.subtitles {
            var subsString = ""
            if let subsArray = item.videos?.first?.subtitles {
                for sub in subsArray {
                    guard let lang = sub.lang else { continue }
                    if subsString != "" { subsString += ", " }
                    subsString += lang.description
                }
            }
            if subsString != "" {
                subLabel.text = subsString
            } else if Int(subs)! >= 1 {
                subLabel.text = "Присутствуют"
            } else {
                subLabel.text = "Отсутствуют"
            }
        }

        if let quality = item.quality {
            qualityLabel.text = "\(quality)p"
        } else if let quality = item.qualitySeries {
            qualityLabel.text = "\(quality)p"
        }

    }

    func configureLabels() {
        genreLabel.textColor = .kpGreyishTwo
        durationLabel.textColor = .kpGreyishTwo
        voiceLabel.textColor = .kpGreyishTwo
        subLabel.textColor = .kpGreyishTwo
        qualityLabel.textColor = .kpGreyishTwo
        networksLabel.textColor = .kpGreyishTwo

        genreTitleLabel.textColor = .kpGreyishBrown
        durationTitleLabel.textColor = .kpGreyishBrown
        voiceTitleLabel.textColor = .kpGreyishBrown
        subTitleLabel.textColor = .kpGreyishBrown
        qualityTitleLabel.textColor = .kpGreyishBrown
        networksTitleLabel.textColor = .kpGreyishBrown
    }

}
