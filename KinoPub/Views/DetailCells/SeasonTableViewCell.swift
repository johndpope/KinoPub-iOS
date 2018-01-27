import UIKit
import SwiftyUserDefaults

class SeasonTableViewCell: UITableViewCell {
    private var model: VideoItemModel!
    var indexPathSeason: Int!

    @IBOutlet weak var episodesCollectionView: UICollectionView! {
        didSet {
            episodesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 8)
        }
    }

    @IBOutlet weak var constraintHeightCollectionView: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clear

//        constraintHeightCollectionView.constant =  ScreenSize.SCREEN_WIDTH * 0.20

        episodesCollectionView.register(UINib(nibName: String(describing: EpisodesCollectionViewCell.self), bundle: Bundle.main),
                                forCellWithReuseIdentifier: String(describing: EpisodesCollectionViewCell.self))
        
        let layout = episodesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: 76, height: 100)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(withModel model: VideoItemModel, index: Int) {
        self.model = model
        indexPathSeason = index
        episodesCollectionView.reloadData()
    }

}

extension SeasonTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard model != nil else { return 0 }
        if model.item?.videos != nil {
            return model.item.videos?.count ?? 0
        }
        return model.getSeason(indexPathSeason)?.episodes?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.episodesCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EpisodesCollectionViewCell.self), for: indexPath) as! EpisodesCollectionViewCell
        cell.config(withModel: model, episode: indexPath.row, inSeason: indexPathSeason)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        self.episodesCollectionView.register(UINib(nibName: String(describing: SeasonHeaderView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: SeasonHeaderView.self))
        switch kind {
        case UICollectionElementKindSectionHeader:
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: SeasonHeaderView.self), for: indexPath) as! SeasonHeaderView
            
            sectionHeaderView.label.text = "\(model.getSeason(indexPathSeason)?.number ?? 0)"
            return sectionHeaderView
        default:
            return UICollectionReusableView()
        }
    }
}

extension SeasonTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

//        let screenwith  = ScreenSize.SCREEN_WIDTH
//        let colum: Float = 6.0, spacing: Float = 8.0
//        let value = floorf((Float(screenwith) - (colum - 1) * spacing) / colum)
//        let cellHeight = constraintHeightCollectionView.constant
//        let cellWidth = CGFloat(value + (value / 1.3 ))

        return  CGSize(width: 121, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

}
