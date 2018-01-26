//
//  GradientView.swift
//  KinoPub
//
//  Created by Евгений Дац on 19.12.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.kpBlack.cgColor]
        gradientLayer.locations = [0.0, 0.2, 1.0]
    }
}
