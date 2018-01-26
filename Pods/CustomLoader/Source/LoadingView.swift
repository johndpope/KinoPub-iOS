//
//  LoadingView.swift
//  CustomLoader
//
//  Created by fritzgerald muiseroux on 24/01/2017.
//  Copyright © 2017 fritzgerald muiseroux. All rights reserved.
//

import UIKit

/**
    A view that will fill the given view and block user input
 */
public class LoadingView: UIView {
    /** The view that indicate that the user must wait for some oeration to complete */
    let loaderView: UIView
    
    /**
        Initialize the loading.
     
        - Parameter loaderView: view that indicate that we are waiting for and activity to end
    */
    public init(loaderView theView: UIView) {
        loaderView = theView
        super.init(frame: CGRect.zero)
        
        theView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(theView)
        
        let centerXContraint = NSLayoutConstraint(item: theView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centerYContraint = NSLayoutConstraint(item: theView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        addConstraints([centerXContraint, centerYContraint])
    }
    
    /**
        Remove the loading view from is super view
     
        - Parameter animated: whether view should fade out before being removed form superview
        - Parameter completion: Handler called after the view is removed. If animation is false, this block is performed at the beginning of the next run loop cycle
    */
    public func removeFromSuperview(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let animaDuration: Double = animated ? 0.3 : 0
        UIView.animate(withDuration: animaDuration, animations: {
            self.alpha = 0
        }, completion: { finished in
            
            self.removeFromSuperview()
            if let completion = completion {
                completion(finished)
            }
        })
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension LoadingView {
    /**
        Present the loading view
        
        - Parameter inView: The view to present the loader into
        - Parameter animated: whether or not we should the loading view should fade in when presented
        - Parameter completion: Handler called after the view is removed.
    */
    public func show(inView view: UIView, animated: Bool = true, completion: ((Bool) -> Void)? = nil) -> LoadingView{
        LoadingView.show(inView: view, loadingView: self, animated: animated, completion: completion)
        return self
    }
}

public extension LoadingView {
    // MARK: LoadingView Presentation
    /**
     Present the loading view
     
     - Parameter inView: The view to present the loader into
     - Parameter withProgressRing: The progress ring view to present
     - Parameter animated: whether or not we should the loading view should fade in when presented
     - Parameter completion: Handler called after the view is removed.
     */
    public class func show(inView view:UIView, withProgressRing ringView: ProgressRingView, animated: Bool = true, completion: ((Bool) -> Void)? = nil) -> LoadingView {
        
        let loadingView = LoadingView(loaderView: ringView)
        show(inView: view, loadingView: loadingView, animated: animated, completion: completion)
        
        return loadingView
    }
    
    /**
     Present the loading view
     
     - Parameter inView: The view to present the loader into
     - Parameter withProgressBox: The progress Box view to present
     - Parameter animated: whether or not we should the loading view should fade in when presented
     - Parameter completion: Handler called after the view is removed.
     */
    public class func show(inView view: UIView, withProgressBox box: ProgressBoxView, animated: Bool = true, completion: ((Bool) -> Void)? = nil) -> LoadingView {
        
        let loadingView = LoadingView(loaderView: box)
        show(inView: view, loadingView: loadingView, animated: animated, completion: completion)
        
        return loadingView
    }
    
    /**
     Present the loading view
     
     - Parameter inView: The view to present the loader into
     - Parameter loadingView: view that indicate that we are waiting for and activity to end
     - Parameter animated: whether or not we should the loading view should fade in when presented
     - Parameter completion: Handler called after the view is removed.
     */
    public class func show(inView view: UIView, loadingView: UIView, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        loadingView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin,]
        loadingView.frame = view.bounds
        view.addSubview(loadingView)
        
        if animated {
            loadingView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                loadingView.alpha = 1.0
            }, completion: { finished in
                loadingView.alpha = 1.0
                completion?(finished)
            })
        } else if let completion = completion {
            completion(true)
        }
    }
    
    /**
     Remove all loading views from the view
     
     - Parameter inView: remove the loaders from this view
     - Parameter animated: whether view should fade out before being removed form superview
     - Parameter completion: Handler called after the view is removed. If animation is false, this block is performed at the beginning of the next run loop cycle
     */
    public class func removeLoadingViews(inView view: UIView, animated: Bool, completion: ((Void) -> Void)? = nil) {
        var loadingViews = [LoadingView]()
        view.subviews.forEach { view in
            if let loadingView = view as? LoadingView {
                loadingViews.append(loadingView)
            }
        }
        var numberOfViews = loadingViews.count
        for view in loadingViews {
            view.removeFromSuperview(animated: animated) { _ in
                numberOfViews -= 1
                if numberOfViews == 0,
                    let completion = completion {
                    completion()
                }
            }
        }
    }
}

// MARK: Style
public extension LoadingView {
    /** Loading view with a light progress ring */
    public static var lightProgressRing: LoadingView {
        return LoadingView(loaderView: ProgressRingView.light)
    }
    
    /** Loading view with a dark progress ring */
    public static var darkProgressRing: LoadingView {
        return LoadingView(loaderView: ProgressRingView.dark)
    }
    
    /** Loading view with a standard progress box */
    public static var standardProgressBox: LoadingView {
        return LoadingView(loaderView: ProgressBoxView.standard)
    }
    
    /** 
     Loading view with a system activity indicator 
     - Parameter withStyle: Activity indicator style
     */
    public static func system(withStyle style: UIActivityIndicatorViewStyle) -> LoadingView {
        let loaderView = UIActivityIndicatorView(activityIndicatorStyle: style)
        loaderView.startAnimating()
        return LoadingView(loaderView: loaderView)
    }
    
    /**
     Loading view with a Progress Box containing system activity indicator
     - Parameter withStyle: Activity indicator style
     */
    public static func systemBox(withStyle style: UIActivityIndicatorViewStyle) -> LoadingView {
        return LoadingView(loaderView: ProgressBoxView.system(withStyle: style))
    }
}

public extension LoadingView {
    /** the loaderView casted as a Progress box */
    public var progressBox: ProgressBoxView? {
        return loaderView as? ProgressBoxView
    }
    
    /** the loaderView casted as a Progress Ring */
    public var progressRing: ProgressRingView? {
        return loaderView as? ProgressRingView
    }
}


// MARK: UIView extensions
public extension UIView {
    /**
     Remove all loading views from the view
     
     - Parameter animated: whether view should fade out before being removed form superview
     - Parameter completion: Handler called after the view is removed. If animation is false, this block is performed at the beginning of the next run loop cycle
     */
    public func removeLoadingViews(animated: Bool, completion: ((Void) -> Void)? = nil) {
        LoadingView.removeLoadingViews(inView: self, animated: animated, completion: completion)
    }
}
