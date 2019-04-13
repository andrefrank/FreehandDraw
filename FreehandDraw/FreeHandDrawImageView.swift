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
    
    // MARK: - Public properties
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
        
        //Pan recognizer to draw a continuosly line when user pans over the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        
        //Enable user interaction for touch and gesture events
        isUserInteractionEnabled = true
    }
    
    //The main reason to implement this is because we need the initial location
    // where drawing will start
    // The recognizer events are not called in this early state
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch=touches.first else {return}
        lastPoint=touch.location(in: self)
    }
    
    //
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            //The first line can be drawn because we have the initial location
            // from touch event
            drawLine(fromPoint: lastPoint!, toPoint: location)
            lastPoint = location
        case .changed:
            drawLine(fromPoint: lastPoint!, toPoint:location)
            lastPoint = location
        case .ended:
            drawLine(fromPoint: lastPoint!, toPoint: location)
        default:
          print("cancel")
       
        }
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
