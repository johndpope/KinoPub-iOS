import UIKit

class KPGestureRecognizer: UITapGestureRecognizer {
    
    var url: URL?
    var indexPathRow: Int?
    
    var type: String?
    var from: String?
    var tag: TabBarItemTag?
    
    var item: Item?
    var collectionView: UICollectionView?
    
    var userView: UIView?
    var userinfo: [AnyHashable : Any]?
}
