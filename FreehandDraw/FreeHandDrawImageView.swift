//
//  FreeHandDrawImageView.swift
//  FreehandDraw
//
//  Created by Andre Frank on 13.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

class FreeHandDrawImageView: UIImageView {
    private var lastPoint: CGPoint?
    private var shapeLayer = CAShapeLayer()
    private var shapePath = UIBezierPath()
    
    var isZoom: Bool = false
    
    var strokeColor: UIColor = UIColor.red {
        willSet {
            shapeLayer.strokeColor = newValue.cgColor
            setNeedsDisplay()
        }
    }
    
    var strokeWidth: CGFloat = 4 {
        willSet {
            shapeLayer.lineWidth = newValue
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
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
    
    @objc func handlePan(gesture:UIPanGestureRecognizer){
        let location = gesture.location(in: self)
        
        switch gesture.state{
        case .began:
                print("began")
            lastPoint=location
        case .changed:
                print("changed")
               drawLine(fromPoint: location, toPoint: lastPoint!)
            lastPoint=location
        case .ended:
            drawLine(fromPoint: location, toPoint: lastPoint!)
        default:
            print("canceled")
            
        }
        
        
    }
    
    func drawLine(fromPoint:CGPoint, toPoint:CGPoint){
        
        shapePath.move(to: toPoint)
        shapePath.addLine(to:fromPoint)
        
        //Save
        shapeLayer.path = shapePath.cgPath
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Touches began")
//        guard isZoom == false else { return }
//        guard let touch = touches.first, touches.count<2 else { return }
//        lastPoint = touch.location(in: self)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Touches move")
//        guard isZoom == false else { return }
//        guard let touch = touches.first,touches.count<2, let fromPoint = lastPoint else { return }
//        let currentPoint = touch.location(in: self)
//
//        shapePath.move(to: currentPoint)
//        shapePath.addLine(to: lastPoint!)
//        lastPoint = currentPoint
//        shapeLayer.path = shapePath.cgPath
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Tocuhes end")
//        guard let touch = touches.first,touches.count<2, let fromPoint = lastPoint else { return }
//        let currentPoint = touch.location(in: self)
//
//        shapePath.move(to: currentPoint)
//        shapePath.addLine(to: lastPoint!)
//        lastPoint = currentPoint
//        shapeLayer.path = shapePath.cgPath
//
//        lastPoint = currentPoint
//    }
}

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
