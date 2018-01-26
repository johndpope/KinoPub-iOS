//
//  UISearchBar+KPAdditions.swift
//  KinoPub
//
//  Created by Евгений Дац on 26.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import UIKit

extension UISearchBar {
    public func setTextColor(_ color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
}
