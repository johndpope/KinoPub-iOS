//
//  BookmarkTableViewCell.swift
//  KinoPub
//
//  Created by hintoz on 11.06.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        configView()
    }
    
    func configView() {
        titleLabel.textColor = .kpOffWhite
        countLabel.textColor = .kpGreyishTwo
        bookmarkImageView.image = bookmarkImageView.image?.withRenderingMode(.alwaysTemplate)
        bookmarkImageView.tintColor = .kpGreyishBrown
    }
    
    func config(withBookmark bookmark: Bookmarks) {
        titleLabel.text = bookmark.title
        countLabel.text = bookmark.count
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
