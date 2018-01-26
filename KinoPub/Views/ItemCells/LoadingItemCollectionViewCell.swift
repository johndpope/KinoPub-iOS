//
//  LoadingItemCollectionViewCell.swift
//  KinoPub
//
//  Created by hintoz on 06.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class LoadingItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    static let reuseIdentifier = "LoadingItemCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadingIndicator.color = .kpOffWhite
    }

    func set(moreToLoad: Bool) {
        if moreToLoad {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
        }
    }

}
