import UIKit

class ItemsTableViewCell: UITableViewCell {
    
    var items: [Item]?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var heightCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemsCollectionView: UICollectionView! {
        didSet {
            itemsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        setLayout()
    }
    
    func configView() {
        backgroundColor = .clear
        titleLabel.textColor = .kpOffWhite
        moreLabel.textColor = .kpTangerine
        itemsCollectionView.register(UINib(nibName: String(describing: ItemCollectionViewCell.self), bundle: Bundle.main),
                                     forCellWithReuseIdentifier: String(describing: ItemCollectionViewCell.self))
        
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE, .iPod5, .iPod6:
            moreLabel.text = "См. все"
        default:
            moreLabel.text = "Смотреть все"
        }
    }
    
    func setLayout() {
        let orientation = UIApplication.shared.statusBarOrientation
        if (orientation == .landscapeLeft || orientation == .landscapeRight), UIDevice.current.userInterfaceIdiom == .pad {
            heightCollectionViewConstraint.constant =  ScreenSize.SCREEN_WIDTH * 0.274
        } else if (orientation == .portrait || orientation == .portraitUpsideDown), UIDevice.current.userInterfaceIdiom == .pad {
            heightCollectionViewConstraint.constant =  ScreenSize.SCREEN_WIDTH * 0.4
        } else if orientation == .landscapeLeft || orientation == .landscapeRight {
            heightCollectionViewConstraint.constant =  ScreenSize.SCREEN_WIDTH * 0.4
        } else {
            heightCollectionViewConstraint.constant =  ScreenSize.SCREEN_WIDTH * 0.8
        }
    }
    
    func config(withItems items: [Item]) {
        self.items = items
        itemsCollectionView.reloadData()
    }
}

extension ItemsTableViewCell {
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        itemsCollectionView.delegate = dataSourceDelegate
        itemsCollectionView.dataSource = dataSourceDelegate
        itemsCollectionView.tag = row
        itemsCollectionView.setContentOffset(itemsCollectionView.contentOffset, animated:false)
        itemsCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { itemsCollectionView.contentOffset.x = newValue }
        get { return itemsCollectionView.contentOffset.x }
    }
}
