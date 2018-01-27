import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            iconImageView.tintColor = .kpMarigold
        } else {
            iconImageView.tintColor = .kpGreyishTwo
        }
    }
    
    func configView() {
        titleLabel.textColor = .kpOffWhite
        titleLabel.highlightedTextColor = .kpMarigold
        backgroundColor = .clear
        iconImageView.tintColor = .kpGreyishTwo
    }
    
    func config(withMenuItem item: Config.MenuItems) {
        titleLabel.text = item.name
        iconImageView.image = UIImage(named: item.icon)?.withRenderingMode(.alwaysTemplate)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}
