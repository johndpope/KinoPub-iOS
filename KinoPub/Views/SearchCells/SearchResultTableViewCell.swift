//
//  SearchResultTableViewCell.swift
//  KinoPub
//
//  Created by hintoz on 03.05.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import AlamofireImage

class SearchResultTableViewCell: UITableViewCell {

    static let reuseIdentifier = "SearchResultTableViewCell"

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ruTitleLabel: UILabel!
    @IBOutlet weak var enTitleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var kpRatingLabel: UILabel!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var kinopubRatingLabel: UILabel!
    
    @IBOutlet weak var kinopoiskImageView: UIImageView!
    @IBOutlet weak var imdbImageView: UIImageView!
    @IBOutlet weak var kinopubImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        configView()
    }
    
    func configView() {
//        backgroundColor = .kpBackground
        
        ruTitleLabel.textColor = .kpOffWhite
        enTitleLabel.textColor = .kpGreyishBrown
        
        typeLabel.backgroundColor = .kpGreyishTwo
        typeLabel.textColor = .kpBlack
        
        kpRatingLabel.textColor = .kpGreyishTwo
        imdbRatingLabel.textColor = .kpGreyishTwo
        kinopubRatingLabel.textColor = .kpGreyishTwo
        
        kinopoiskImageView.image = kinopoiskImageView.image?.withRenderingMode(.alwaysTemplate)
        kinopoiskImageView.tintColor = .kpGreyishTwo
        imdbImageView.image = imdbImageView.image?.withRenderingMode(.alwaysTemplate)
        imdbImageView.tintColor = .kpGreyishTwo
        kinopubImageView.image = kinopubImageView.image?.withRenderingMode(.alwaysTemplate)
        kinopubImageView.tintColor = .kpGreyishTwo
    }

    func configure(with item: Item) {
        
        if let title = item.title?.components(separatedBy: " / ") {
            ruTitleLabel.text = title[0]
            if title.count > 1 {
                enTitleLabel.text = title[1]
            } else {
                enTitleLabel.text = ""
            }
        }
        
        if let type = item.type {
            switch type {
            case ItemType.movies.getValue():
                typeLabel.text = " ФИЛЬМ "
            case ItemType.shows.getValue():
                typeLabel.text = " СЕРИАЛ "
            case ItemType.documovie.getValue():
                typeLabel.text = " ДОКУМЕНТАЛЬНЫЙ ФИЛЬМ "
            case ItemType.docuserial.getValue():
                typeLabel.text = " ДОКУМЕНТАЛЬНЫЙ СЕРИАЛ "
            case ItemType.concerts.getValue():
                typeLabel.text = " КОНЦЕРТ "
            case ItemType.tvshows.getValue():
                typeLabel.text = " ТВ ШОУ "
            case ItemType.movies4k.getValue():
                typeLabel.text = " 4K "
            case ItemType.movies3d.getValue():
                typeLabel.text = " 3D "
            default:
                typeLabel.text = ""
            }
        }
        
        if let kinopoiskRating = item.kinopoiskRating {
            kpRatingLabel.text = String(format: "%.1f", kinopoiskRating)
        }
        
        if let imdbRating = item.imdbRating {
            imdbRatingLabel.text = imdbRating.string
        }
        
        if let kinopubRating = item.rating {
            kinopubRatingLabel.text = kinopubRating.string
        }

        if let poster = item.posters?.small {
            posterImageView.af_setImage(withURL: URL(string: poster)!,
                                             placeholderImage: UIImage(named: "poster-placeholder.png"),
                                             imageTransition: .crossDissolve(0.2),
                                             runImageTransitionIfCached: false)
        }
    }

}
