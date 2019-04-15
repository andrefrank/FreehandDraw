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
    
    //An array of a stroke dictionary
    private var shapes = [[String:UIBezierPath]]()
    private var lastKey:String?
   
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
    
    // MARK: - Public inteface
    func clearFreeHandDrawing() {
        shapePath.removeAllPoints()
        shapeLayer.path = shapePath.cgPath
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
        
        // Pan recognizer to draw a continuosly line when user pans over the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        
        // Enable user interaction for touch and gesture events
        isUserInteractionEnabled = true
    }

    //MARK: - Touch event handling
    
    // The main reason to implement this is because we need the initial location
    // where drawing will start
    // The recognizer events are not called in this early state
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastPoint = touch.location(in: self)
        //lastKey=getKeyForStroke()
    }
    
    //
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            // The first line can be drawn because we have the initial location
            // from touch event
            
            guard let lastPoint = self.lastPoint else {
                self.lastPoint = location
                return
            }
            drawLine(fromPoint: lastPoint, toPoint: location)
            //addStroke(withKey:lastKey, fromPoint: lastPoint, toPoint: location)
            self.lastPoint = location
        case .changed:
            drawLine(fromPoint: lastPoint!, toPoint: location)
             //addStroke(withKey:lastKey, fromPoint: lastPoint!, toPoint: location)
            lastPoint = location
        case .ended:
            // Draw final curve and reset lastPoint for the next drawing
            // start point
            drawLine(fromPoint: lastPoint!, toPoint: location)
            // addStroke(withKey:lastKey, fromPoint: lastPoint!, toPoint: location)
            lastPoint = nil
        default:
            print("shit happens")
        }
    }
    
    //MARK: - Drawing methods
    
    private func getKeyForStroke()->String{
        //Get all existing keys
        let keys=shapes.map { (dict)  -> String in
            return dict.keys.first!
        }
        print(keys)
        //Remove all multiple keys by using an NSSet
        let uniqueKeys=NSSet(array: keys)
        //Convert it back to an array which can be sorted
        //in ascending order
        let array:[String] = Array(uniqueKeys) as! [String]
        let sortedArray=array.sorted(by: {$0<$1})

        //Check existing key
        if sortedArray.count<1{
            return "\(1)"
        }else{
            return "\(Int(sortedArray.last!)!+1)"
        }
    }
    
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        shapePath.move(to: fromPoint)
        shapePath.addLine(to: toPoint)
        shapePath.close()
        
        //transfer path to layer
        shapeLayer.path = shapePath.cgPath
    }
    
    private func addStroke(withKey key:String?, fromPoint: CGPoint, toPoint: CGPoint) {
        guard let key=key else {return}
        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        path.close()
        shapes.append([key:path])
        print(shapes)
    }
    
    func reverseStroke(){
        guard shapes.count>0 else {return}
       
        shapes.removeLast()
       
        // drawShape()
    }
    
//    func drawShape() {
//        var drawingShape = UIBezierPath()
//        print("After remove:\(shapes.count)")
//        drawingShape = shapes.reduce(drawingShape) { (resultPath, path) -> UIBezierPath in
//            resultPath.append(path)
//            return resultPath
//        }
//
//        shapeLayer.path = drawingShape.cgPath
//    }
}

// MARK: - Extension for getting a snapshot of the UIImageView

extension UIImageView {
    var snapshot: UIImage? {
        // Get scale
        let scale = UIScreen.main.scale
        // Create a bitmap using frame size
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
