import UIKit
import NTDownload
import AlamofireImage
import CircleProgressView

class DownloadingTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "DownloadingTableViewCell"

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var qualityLabel: UILabel!
    @IBOutlet weak var enNameLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!
    
    var fileInfo: NTDownloadTask? {
        didSet {
            let title = fileInfo?.fileName.replacingOccurrences(of: ".mp4", with: "").components(separatedBy: "; ")
            nameLabel.text = title?[0]
            if title!.count > 1, title!.count > 2 {
                enNameLabel.text = title?[1]
                enNameLabel.isHidden = false
                let info = title![2].components(separatedBy: ".")
                if info.count > 1 {
                    seasonLabel.text = info[0]
                    seasonLabel.isHidden = false
                    qualityLabel.text = "  " + info[1] + "  "
                    qualityLabel.isHidden = false
                } else {
                    qualityLabel.text = "  " + info[0] + "  "
                    qualityLabel.isHidden = false
                }
            } else if title!.count > 1, title!.count < 3 {
                let info = title![1].components(separatedBy: ".")
                if info.count > 1 {
                    seasonLabel.text = info[0]
                    seasonLabel.isHidden = false
                    qualityLabel.text = "  " + info[1] + "  "
                    qualityLabel.isHidden = false
                } else {
                    qualityLabel.text = "  " + info[0] + "  "
                    qualityLabel.isHidden = false
                }
            }
            
            progressView.progress = Double((fileInfo?.progress)!)
            
            posterImageView.af_setImage(withURL: URL(string: (fileInfo?.fileImage)!)!,
                                       placeholderImage: UIImage(named: "poster-placeholder.png"),
                                       imageTransition: .crossDissolve(0.2),
                                       runImageTransitionIfCached: false)

            guard let downloadedFileSize = fileInfo?.downloadedFileSize, let fileSize = fileInfo?.fileSize else {
                return
            }

            let downSize = downloadedFileSize.unit == "GB" ? "%.2f" : "%.0f"
            let size = fileSize.unit == "GB" ? "%.2f" : "%.0f"
            progressLabel.text = String(format: "  \(downSize) %@ / \(size) %@  ", downloadedFileSize.size, downloadedFileSize.unit, fileSize.size, fileSize.unit)
            
            changeIcon()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configView() {
        enNameLabel.isHidden = true
        seasonLabel.isHidden = true
        qualityLabel.isHidden = true
        
        backgroundColor = .clear
        nameLabel.textColor = .kpOffWhite
        enNameLabel.textColor = .kpGreyishBrown
        seasonLabel.textColor = .kpGreyishTwo
        
        qualityLabel.textColor = .kpBlack
        qualityLabel.backgroundColor = .kpGreyishTwo
        
        progressLabel.textColor = .kpBlack
        progressLabel.backgroundColor = .kpGreyishTwo
        progressLabel.text = ""
        
        progressView.centerFillColor = .kpBackground
        progressView.centerImage = UIImage(named: "Download Start")?.imageWithInset(UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36))?.withRenderingMode(.alwaysTemplate).tint(.kpMarigold, blendMode: CGBlendMode.normal)
        progressView.trackBackgroundColor = .kpGreyishBrown
        progressView.trackFillColor = .kpMarigold
    }
    
    func changeIcon() {
        if fileInfo?.status == NTDownloadStatus.NTPauseDownload {
            progressView.centerImage = UIImage(named: "Download Start")?.imageWithInset(UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36))?.withRenderingMode(.alwaysTemplate).tint(.kpMarigold, blendMode: CGBlendMode.normal)
        } else if fileInfo?.status == NTDownloadStatus.NTDownloading {
            progressView.centerImage = UIImage(named: "Download Pause")?.imageWithInset(UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36))?.withRenderingMode(.alwaysTemplate).tint(.kpMarigold, blendMode: CGBlendMode.normal)
        }
    }
    
}
