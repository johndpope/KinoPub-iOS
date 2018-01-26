//
//  FadeImageView.swift
//  KinoPub
//
//  Created by hintoz on 26.05.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class FadeImageView: UIImageView {

    @IBInspectable
    var fadeDuration: Double = 0.4

    override var image: UIImage? {
        get {
            return super.image
        }
        set(newImage) {
            if let img = newImage {
                CATransaction.begin()
                CATransaction.setAnimationDuration(self.fadeDuration)

                let transition = CATransition()
                transition.type = kCATransitionFade

                super.layer.add(transition, forKey: kCATransition)
                super.image = img

                CATransaction.commit()
            } else {
                super.image = nil
            }
        }
    }

}
