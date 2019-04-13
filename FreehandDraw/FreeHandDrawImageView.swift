//
//  FreeHandDrawImageView.swift
//  FreehandDraw
//
//  Created by Andre Frank on 13.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

/// Class FreehandDrawImageView
class FreeHandDrawImageView: UIImageView {
    private var lastPoint: CGPoint?
    private var shapeLayer = CAShapeLayer()
    private var shapePath = UIBezierPath()
    
    
    //MARK:- Public properties
    var strokeWidth: CGFloat = 4 {
        willSet {
            shapeLayer.lineWidth = newValue
            setNeedsDisplay()
        }
    }
    
    var strokeColor: UIColor = UIColor.red {
        willSet {
            shapeLayer.strokeColor = newValue.cgColor
            setNeedsDisplay()
        }
    }
    
    //MARK:- Init and View setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    private func setupView() {
        //Preconfigure drawing layer
        strokeColor = .red
        strokeWidth = 4
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
        
        
        let panGesture=UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGesture.maximumNumberOfTouches=1
        panGesture.minimumNumberOfTouches=1
        
        self.addGestureRecognizer(panGesture)
        
        isUserInteractionEnabled = true
        
    
    }
    
    @objc private func handlePan(gesture:UIPanGestureRecognizer){
        let location = gesture.location(in: self)
        
        switch gesture.state{
        case .began:
            lastPoint=location
        case .changed:
               drawLine(fromPoint: location, toPoint: lastPoint!)
            lastPoint=location
        case .ended:
            drawLine(fromPoint: location, toPoint: lastPoint!)
        default:
            print("canceled")
            
        }
    }
    
   private func drawLine(fromPoint:CGPoint, toPoint:CGPoint){
        
        shapePath.move(to: toPoint)
        shapePath.addLine(to:fromPoint)
        
        //Save current shape
        shapeLayer.path = shapePath.cgPath
        
    }
}


//MARK:- Snapshoot extension method for this View
extension UIView {
    var screenShot: UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
