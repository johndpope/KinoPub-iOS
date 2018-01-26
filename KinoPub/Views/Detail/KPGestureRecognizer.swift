//
//  KPGestureRecognizer.swift
//  KinoPub
//
//  Created by Евгений Дац on 08.07.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class KPGestureRecognizer: UITapGestureRecognizer {
    
    var url: URL?
    var indexPathRow: Int?
    
    var type: String?
    var from: String?
    var tag: TabBarItemTag?
    
    var item: Item?
    var collectionView: UICollectionView?
}
