//
//  LoadingIndicatorView.swift
//  CustomLoader
//
//  Created by fritzgerald muiseroux on 23/01/2017.
//  Copyright © 2017 fritzgerald muiseroux. All rights reserved.
//

import UIKit

/**
 A ring that view that can represent some background activity
 */
@IBDesignable
public class ProgressRingView: UIView {
    
    private var addedLayer = [CALayer]()
    
    /** Color of the inner ring */
    @IBInspectable
    public var innerColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    /** Color of the outter ring */
    @IBInspectable
    public var outterColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    /** the line width of each circle */
    @IBInspectable
    public var lineWidth: CGFloat = 3.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /** 
     A boolean that indicate if the view represent a determinate activity.
     If false then the view will stop the animation and the outter ring will progress following the value ratio
     */
    @IBInspectable
    public var isIndeterminate: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    /** default 0.0. the current value may change if outside new min value */
    @IBInspectable
    public var minimumValue: CGFloat = 0 {
        didSet {
            if minimumValue >= maximumValue {
                maximumValue = minimumValue + 1
            }
            if isIndeterminate == false {
                setNeedsLayout()
            }
        }
    }
    
    /** default 1.0. the current value may change if outside new max value */
    @IBInspectable
    public var maximumValue: CGFloat = 1 {
        didSet {
            if isIndeterminate == false {
                setNeedsLayout()
            }
        }
    }
    
    private var _value: CGFloat = 0
    
    /** default 0.0. this value will be pinned to min/max */
    @IBInspectable
    public var value: CGFloat {
        get { return _value }
        set {
            _value = min(max(newValue, minimumValue), maximumValue)
            if isIndeterminate == false {
                setNeedsLayout()
            }
        }
    }
    
    /** the actual progression between 0 and 1 */
    public var valueRatio: Double {
        return ProgressRingView.valueRatio(minumum: minimumValue, maximum: maximumValue, value: value)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func circleLayer(color: UIColor, radius: CGFloat, angle: Double, lineWith width: CGFloat) -> CALayer {
        
        let shapeLayer = CAShapeLayer(circleInFrame: bounds, radius:radius, maxAngle: angle)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    private func initialize() {
        
        if isIndeterminate {
            initializeIndeterminate()
        } else {
            initializeDeterminate()
        }
    }
    
    private func initializeDeterminate() {
        
        let bigRadius = (bounds.width / 2.0) - lineWidth
        let centerRadius = bigRadius - lineWidth
        let valueRatio = ProgressRingView.valueRatio(minumum: minimumValue, maximum: maximumValue, value: value)
        let theLayer = circleLayer(color: outterColor, radius: bigRadius, angle: M_PI * 2 * valueRatio, lineWith: lineWidth)
        layer.addSublayer(theLayer)
        
        let theLayer2 = circleLayer(color: innerColor, radius: centerRadius, angle: M_PI * 2, lineWith: lineWidth)
        layer.addSublayer(theLayer2)
        
        
        addedLayer.append(theLayer)
        addedLayer.append(theLayer2)
    }
    
    
    private func initializeIndeterminate() {
        
        let bigRadius = (bounds.width / 2.0) - lineWidth
        let theLayer = circleLayer(color: outterColor, radius: bigRadius, angle: M_PI, lineWith: lineWidth)
        layer.addSublayer(theLayer)
        theLayer.addRotationAnimation(clockwise: true)
        
        let theLayer2 = circleLayer(color: innerColor, radius: bigRadius - lineWidth, angle: M_PI, lineWith: lineWidth)
        layer.addSublayer(theLayer2)
        theLayer2.addRotationAnimation(clockwise: false)
        
        addedLayer.append(theLayer)
        addedLayer.append(theLayer2)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        addedLayer.forEach { subLayer in
            subLayer.removeFromSuperlayer()
        }
        addedLayer.removeAll()
        initialize()
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 40)
    }
}

extension ProgressRingView {
    // MARK: Helper
    static func valueRatio(minumum: CGFloat, maximum: CGFloat, value: CGFloat) -> Double{
        let amplitude = maximum - minumum
        let translatedValue = fabs(Double(value - minumum))
        let valueRatio = Double(translatedValue) / Double(amplitude)
        return fmin(fmax(0, valueRatio), 1.0)
    }
}

public extension ProgressRingView {
    
    /** A progress Ring with a white outter color an dark gray inner color*/
    public static var light: ProgressRingView {
        let view = ProgressRingView()
        view.outterColor = .white
        view.innerColor = .darkGray
        return view
    }
    
    /** A progress Ring with a black outter color an dark darkGray inner color*/
    public static var dark: ProgressRingView {
        let view = ProgressRingView()
        view.outterColor = .black
        view.innerColor = .darkGray
        return view
    }
}

extension CAShapeLayer {
    
    convenience init(circleInFrame drawingFrame: CGRect,
                     radius: CGFloat,
                     maxAngle: Double = M_PI * 2,
                     clockwise: Bool = true) {
        self.init()
        //let diameter = fmin(drawingFrame.width, drawingFrame.height)
        let center = CGPoint(x: drawingFrame.width / 2.0, y: drawingFrame.height / 2.0)
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: CGFloat(-M_PI_2),
                                      endAngle:CGFloat(maxAngle - M_PI_2),
                                      clockwise: clockwise)
        path = circlePath.cgPath
        frame = drawingFrame
    }
}

extension CALayer {
    
    /// Rotate forever around the Z axis
    func addRotationAnimation(clockwise: Bool) {
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = M_PI
        if clockwise {
            rotation.toValue = -M_PI
        }
        rotation.isCumulative = true
        rotation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        rotation.duration = 0.75
        rotation.isAdditive = true
        rotation.fillMode = kCAFilterLinear
        rotation.repeatCount = Float.greatestFiniteMagnitude;
        
        self.add(rotation, forKey: "rotation")
    }
}
