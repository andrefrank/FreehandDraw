//
//  FreeHandDrawImageView.swift
//  FreehandDraw
//
//  Created by Andre Frank on 13.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

/// Class FreehandDrawImageView
class FreeHandDrawImageView: UIView {
   
    //MARK: - Private Properties
    private var lastPoint: CGPoint?
    private var shapeLayer = CAShapeLayer()
    private var shapePath = UIBezierPath()
    
    //Variable Constraints for UIImageView
    var imageViewBottomConstraint:NSLayoutConstraint!
    var imageViewTopConstraint:NSLayoutConstraint!
    var imageViewLeadingConstraint:NSLayoutConstraint!
    var imageViewTrailingConstraint:NSLayoutConstraint!
    
    //Private used views
    private var imageView:UIImageView={
       let iv = UIImageView()
       iv.contentMode = UIImageView.ContentMode.scaleToFill
       iv.translatesAutoresizingMaskIntoConstraints=false
       return iv
    }()
    
    private var scrollView:UIScrollView={
       let sv=UIScrollView()
       sv.contentMode = UIScrollView.ContentMode.scaleToFill
        sv.translatesAutoresizingMaskIntoConstraints=false
        sv.maximumZoomScale=5
       sv.showsVerticalScrollIndicator=true
       sv.showsHorizontalScrollIndicator=true
       return sv
    }()
    
    //MARK: - private Drawing properties
    private var shapes = [[String:UIBezierPath]]()
    private var lastKey:String?
   
    
    // MARK: - Public properties
    var strokeWidth: CGFloat = 4 {
        willSet {
            shapeLayer.lineWidth = newValue
            imageView.setNeedsDisplay()
        }
    }
    
    var strokeColor: UIColor = UIColor.red {
        willSet {
            shapeLayer.strokeColor = newValue.cgColor
            imageView.setNeedsDisplay()
        }
    }
    
    var image:UIImage?{
        willSet{
            imageView.image=newValue
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
   
    //MARK:- Life cycle of custom View
    override func layoutSubviews() {
        
        guard let parent=superview else {return}
         super.layoutSubviews()
        updateMinZoomScaleForSize(bounds.size)
        scrollView.setContentOffset(center, animated: true)
      
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return true
    }
    
    
    //MARK: - Setup all views
    private func installGestures(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPinch(gesture:)))
        longPressGesture.minimumPressDuration=0.5
        
        self.addGestureRecognizer(longPressGesture)
    }
    
    private func setupConstraintsForImageView(){
        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem:scrollView, attribute: .leading, multiplier: 1, constant: 0)
        imageViewTrailingConstraint = NSLayoutConstraint(item:scrollView, attribute: .trailing, relatedBy: .equal, toItem:imageView, attribute: .trailing, multiplier: 1, constant: 0)
        imageViewTopConstraint=NSLayoutConstraint(item:imageView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        imageViewBottomConstraint=NSLayoutConstraint(item:scrollView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let imageViewWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
        let imageViewHeighthConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)
        
        imageViewWidthConstraint.priority=UILayoutPriority(rawValue: 250)
        imageViewHeighthConstraint.priority=UILayoutPriority(rawValue: 250)
        
        NSLayoutConstraint.activate([imageViewLeadingConstraint,imageViewTopConstraint,imageViewBottomConstraint,imageViewTrailingConstraint,imageViewHeighthConstraint,imageViewWidthConstraint])
    }
    
    
    private func setupConstraintsForScrollView(){
        let scrollViewLeadingConstraint=NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let scrollViewTopConstraint=NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem:self, attribute: .top, multiplier: 1, constant: 0)
        let scrollViewBottomConstraint=NSLayoutConstraint(item: scrollView, attribute: .bottomMargin, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1, constant: 0)
        let scrollViewTrailingConstraint=NSLayoutConstraint(item:self, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([scrollViewTopConstraint,scrollViewLeadingConstraint,scrollViewTrailingConstraint,scrollViewBottomConstraint])
    }
    
    private func setupView() {
        installGestures()
        
        imageView.frame=CGRect(x:0, y:0, width:bounds.width, height:bounds.height)
        
        // Preconfigure drawing layer
        strokeColor = .red
        strokeWidth = 4
        shapeLayer.lineCap = .round
        //Install Drawing layer
        imageView.layer.addSublayer(shapeLayer)
        
        scrollView.addSubview(imageView)
        
        setupConstraintsForImageView()
       
        scrollView.delegate=self
        addSubview(scrollView)
        
        setupConstraintsForScrollView()
        
        // Enable user interaction for touch and gesture events
        //imageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Public inteface
    func clearFreeHandDrawing() {
        shapePath.removeAllPoints()
        shapeLayer.path = shapePath.cgPath
    }

    //MARK: - private drawing methods
    
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


//MARK: - Handle Pan Gesture
extension FreeHandDrawImageView{
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
}


//MARK: - ScrollView Delegate methods
extension FreeHandDrawImageView:UIScrollViewDelegate{
    func updateMinZoomScaleForSize(_ size:CGSize){
        let widthScale = size.width / imageView.bounds.width
        let heigthScale = size.height / imageView.bounds.height
        
        var minScale = min(heigthScale,widthScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func updateConstraintsForSize(_ size:CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        layoutIfNeeded()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let parent=superview {
            updateConstraintsForSize(parent.bounds.size)
        }else{
             updateConstraintsForSize(bounds.size)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

//MARK: - LongPinchHandling & Show Menu
extension FreeHandDrawImageView{
    
    @objc func handleLongPinch(gesture:UILongPressGestureRecognizer){
        //Set custom view as first responder to enable menu
        if let _ = window {
            becomeFirstResponder()
            print("window")
        }
        
        //Setup menu & items
        let menu=UIMenuController()
        let drawItem=UIMenuItem(title: "Select Draw", action: #selector(handleDrawMenuItem))
        
        let moveItem=UIMenuItem(title: "Select Scroll", action: #selector(handleScrollMenuItem))
        
        menu.menuItems=[drawItem,moveItem]
        
        //Show menu in custom view
        menu.setTargetRect(bounds, in: self)
        menu.update()
        menu.setMenuVisible(true, animated: true)
    }
    
    //MARK: - Handle Selection menu
    @objc func handleDrawMenuItem(){
        print("Item draw")
    }
    
    @objc func handleScrollMenuItem(){
        print("Item scroll")
    }
    
}


//MARK: - Handle touch events for drawing UIBezierpath
extension FreeHandDrawImageView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.count)
        guard let touch = touches.first, touches.count<2 else {
            print("More than one finger used")
            return }
        lastPoint = touch.location(in: self)
        //lastKey=getKeyForStroke()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
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
