//
//  ActorCollectionViewCell.swift
//  KinoPub
//
//  Created by hintoz on 27.04.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import Letters

class ActorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var namePersonLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        configureLabels()
    }

    func configure(with name: String) {
        if name != "" {
            namePersonLabel.isHidden = false
            namePersonLabel.text = name
            personImageView.setImage(string: name, color: .kpGreyishBrown, circular: true, textAttributes: [NSAttributedStringKey.foregroundColor: UIColor.kpOffWhite])
        } else {
            namePersonLabel.isHidden = true
        }
    }

    func configureLabels() {
        namePersonLabel.textColor = .kpOffWhite
    }

}
