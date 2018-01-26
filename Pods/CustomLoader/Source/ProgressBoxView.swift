//
//  ProgressBoxView.swift
//  CustomLoader
//
//  Created by fritzgerald muiseroux on 24/01/2017.
//  Copyright © 2017 fritzgerald muiseroux. All rights reserved.
//

import UIKit

/**
 A Boxed view that present a view stacked with two labels
 */
public class ProgressBoxView: UIView {

    /** The loading indicator view*/
    public let loaderView: UIView!
    /** Main text*/
    public let label = UILabel()
    /** sub text */
    public let subLabel = UILabel()
    
    internal var contentView: UIView!

    /**
     Initialize the loading box with the given view
     
     - Parameter loader: the loading indicator
    */
    public init(loader: UIView) {
        loaderView = loader
        super.init(frame: CGRect.zero)
        initializeStyle()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeStyle() {
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        
        label.standardStyle(withFont: UIFont.boldSystemFont(ofSize: 15))
        subLabel.standardStyle(withFont: UIFont.boldSystemFont(ofSize: 12))
        
        contentView.stackViews([loaderView , label, subLabel])
        
        let centerYConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        let vContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": contentView])
        let hContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view]-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": contentView])
        
        addConstraints(vContraints)
        addConstraints(hContraints)
        addConstraints([centerYConstraint, centerXConstraint])
        
        layer.cornerRadius = 10
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
}

public extension ProgressBoxView {
    /**
     A progress box with a light loading ring as indicator
    */
    public static var standard: ProgressBoxView {
        let view = ProgressBoxView(loader: ProgressRingView.light)
        view.backgroundColor =  UIColor.lightGray
        return view
    }
    
    /**
     A progress box with an Activity indicator View
     
     - Parameter withStyle: the Activity indicator style
    */
    public static func system(withStyle style: UIActivityIndicatorViewStyle) -> ProgressBoxView {
        let loaderView = UIActivityIndicatorView(activityIndicatorStyle: style)
        loaderView.startAnimating()
        let view = ProgressBoxView(loader: loaderView)
        view.backgroundColor =  UIColor.lightGray
        return view
    }
}

extension UILabel {
    
    func standardStyle(withFont font: UIFont) {
        self.font = font
        self.textColor = UIColor.white
        self.numberOfLines = 0
        self.textAlignment = .center
    }
}

extension UIView {
    
    func stackViews(_ views:[UIView]) {
        
        var lastView: UIView? = nil
        var stackConstraints = [NSLayoutConstraint]()
        
        views.forEach({ view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        })
        
        
        views.forEach { view in
            if let lastView = lastView {
                let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 0)
                stackConstraints.append(topConstraint)
            } else {
                let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1.0, constant: 0)
                stackConstraints.append(topConstraint)
            }
            let centerXConstraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
            stackConstraints.append(centerXConstraint)
            
            let horizontalCOnstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|->=0-[view]->=0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": view])
            stackConstraints.append(contentsOf: horizontalCOnstraints)
            lastView = view
        }
        
        if let lastView = lastView {
            let bottom = NSLayoutConstraint(item: lastView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1.0, constant: 0)
            stackConstraints.append(bottom)
        }
        self.addConstraints(stackConstraints)
    }
}
