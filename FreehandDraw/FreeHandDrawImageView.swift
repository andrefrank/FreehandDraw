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
    private var shapePath=UIBezierPath()
    
    private var isFirstTap:Bool=false
    // MARK: - Public properties
    
    var zoomScale:CGFloat=1
    
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
    
    //MARK:- Public inteface
    func clearFreeHandDrawing(){
       shapePath.removeAllPoints()
       shapeLayer.path=shapePath.cgPath
        
    }
    
    // MARK: - Init and View setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Preconfigure drawing layer
        strokeColor = .red
        strokeWidth = 4
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGesture.maximumNumberOfTouches = 1
        
        addGestureRecognizer(panGesture)
        
        isUserInteractionEnabled = true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        lastPoint=gestureRecognizer.location(in: self)
        print(lastPoint)
        super.gestureRecognizerShouldBegin(gestureRecognizer)
        return true
    }
    
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let translation = gesture.translation(in: self)
        print(translation)
        
        switch gesture.state {
        case .began:
            lastPoint = location
            print(lastPoint)
            gesture.setTranslation(CGPoint.zero, in: self)
        case .changed:
//            if !isFirstTap {
//                let firstPoint = calculateFirstDrawPosition(usingTranslation: translation)
//                drawLine(fromPoint: firstPoint, toPoint: lastPoint!)
//                isFirstTap=true
//            }
    
            drawLine(fromPoint: lastPoint!, toPoint:location)
            gesture.setTranslation(CGPoint.zero, in: self)
            lastPoint = location
        case .ended:
            drawLine(fromPoint: lastPoint!, toPoint: location)
            isFirstTap=false
        default:
          print("cancel")
          isFirstTap=false
        }
    }
    
    func calculateFirstDrawPosition(usingTranslation translation:CGPoint, overTime time:TimeInterval=4)->CGPoint{
        var x:CGFloat=0
        var y:CGFloat=0
        
        if translation.x>0.5{
            x = translation.x*CGFloat(time)
        }else {
            x = translation.x*CGFloat(time)+0.5*CGFloat(time)
        }
        
        if translation.y>0.5{
            y = translation.y*CGFloat(time)
        }else {
            y = translation.y*CGFloat(time)+0.5*CGFloat(time)
        }
       
        
        print("\(x) and \(y)")
        return CGPoint(x: lastPoint!.x-x, y: lastPoint!.y-y)
    }
    
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        
       
        shapePath.move(to:fromPoint)
        shapePath.addLine(to:toPoint)
        
        //transfer path to layer
        shapeLayer.path=shapePath.cgPath
        
    }
}

// MARK: - Snapshoot extension method for this View

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
