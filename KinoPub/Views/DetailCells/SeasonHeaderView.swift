//
//  SeasonHeaderView.swift
//  KinoPub
//
//  Created by Евгений Дац on 08.07.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class SeasonHeaderView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .kpBlackTwo
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topLeft, .bottomLeft], radius: 6)
    }
    
}
