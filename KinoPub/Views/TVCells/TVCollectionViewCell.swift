//
//  TVCollectionViewCell.swift
//  KinoPub
//
//  Created by Евгений Дац on 11.02.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class TVCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configViews()
    }
    
    func configViews() {
        backgroundColor = .clear
        containerView.backgroundColor = .kpGreyishBrown
        titleLabel.textColor = .kpOffWhite
        logoImageView.isHidden = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        containerView.dropShadow(color: UIColor.black, opacity: 0.3, offSet: CGSize(width: 0, height: 2), radius: 6, scale: true)
        containerView.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
    }
    
    func config(withChannel channel: Channels) {
        if let title = channel.title {
            titleLabel.text = title
        }
        
        if let logo = channel.logos?.s, let url = URL(string: logo) {
            logoImageView.af_setImage(withURL: url,
                                      placeholderImage: UIImage(named: "Sports-placeholder"),
                                      imageTransition: .crossDissolve(0.2),
                                      runImageTransitionIfCached: false) { [weak self] (response) in
                                        if response.result.isSuccess {
                                            self?.logoImageView.isHidden = false
                                        }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectView = object as? UIView,
            objectView === containerView,
            keyPath == #keyPath(UIView.bounds) {
            containerView.layer.shadowPath = UIBezierPath(rect: objectView.bounds).cgPath
        }
    }
    
    deinit {
        containerView.removeObserver(self, forKeyPath: #keyPath(UIView.bounds))
    }

}
