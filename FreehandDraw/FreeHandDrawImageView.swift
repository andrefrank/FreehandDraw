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
        layer.addSublayer(shapeLayer)
        strokeColor = .red
        strokeWidth = 4
        isUserInteractionEnabled = true

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began")
        guard isZoom == false else { return }
        guard let touch = touches.first, touches.count<2 else { return }
        lastPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches move")
        guard isZoom == false else { return }
        guard let touch = touches.first,touches.count<2, let fromPoint = lastPoint else { return }
        let currentPoint = touch.location(in: self)
        
        shapePath.move(to: currentPoint)
        shapePath.addLine(to: lastPoint!)
        lastPoint = currentPoint
        shapeLayer.path = shapePath.cgPath
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Tocuhes end")
        guard let touch = touches.first,touches.count<2, let fromPoint = lastPoint else { return }
        let currentPoint = touch.location(in: self)
        
        shapePath.move(to: currentPoint)
        shapePath.addLine(to: lastPoint!)
        lastPoint = currentPoint
        shapeLayer.path = shapePath.cgPath
        
        lastPoint = currentPoint
    }
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
