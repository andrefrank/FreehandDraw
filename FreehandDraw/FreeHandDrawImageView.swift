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
   
    //MARK: - Private Properties for path and each individual stroke
    private var touchPaths=[String:UIBezierPath]()
    // A Stroke is a complete set of a Touch event ( began/moved/ended)
    private var strokes=[UIBezierPath]()
    private var selectedStrokes=[UIBezierPath]()
    
    //Variable Constraints for UIImageView
    var imageViewBottomConstraint:NSLayoutConstraint!
    var imageViewTopConstraint:NSLayoutConstraint!
    var imageViewLeadingConstraint:NSLayoutConstraint!
    var imageViewTrailingConstraint:NSLayoutConstraint!
    
    //Privatly used views
    private var imageView:UIImageView={
       let iv = UIImageView()
       //Predefine rect for minimum scale value
       iv.frame=CGRect(x: 0, y: 0, width: 1024, height: 768)
       
       iv.contentMode = UIImageView.ContentMode.scaleToFill
       iv.translatesAutoresizingMaskIntoConstraints=false
       return iv
    }()
    
    private var scrollView:UIScrollView={
       let sv=UIScrollView()
       sv.contentMode = UIScrollView.ContentMode.scaleToFill
        sv.translatesAutoresizingMaskIntoConstraints=false
       sv.showsVerticalScrollIndicator=true
       sv.showsHorizontalScrollIndicator=true
       return sv
    }()
    
    
    private let menu=UIMenuController()
    
    //MARK: - private drawing properties
    private var shapes = [[String:UIBezierPath]]()
    private var lastKey:String?
   
    //layer for all paths
    private lazy var currentShape:CAShapeLayer={
        let currentShape = CAShapeLayer()
        currentShape.fillColor = UIColor.clear.cgColor
        currentShape.lineWidth = 5
        currentShape.strokeColor = UIColor.red.cgColor
        currentShape.lineCap = .round
        return currentShape
    }()
    
    //Layer for all paths except the last one path
    private lazy var lastShape:CAShapeLayer={
        let lastShape = CAShapeLayer()
        lastShape.fillColor = UIColor.clear.cgColor
        lastShape.lineWidth = 5
        lastShape.lineCap = .round
        lastShape.strokeColor = UIColor.red.withAlphaComponent(0.6).cgColor
        return lastShape
    }()
    
    //Layer for selected paths
    private lazy var selectedShape:CAShapeLayer={
        let ss = CAShapeLayer()
        ss.fillColor = UIColor.clear.cgColor
        ss.lineWidth = 5
        ss.lineCap = .square
        ss.strokeColor = UIColor.red.withAlphaComponent(0.6).cgColor
        ss.lineDashPattern = [10,10]
        return ss
    }()
    

    // MARK: - Public properties
    var strokeWidth: CGFloat = 4 {
        willSet {
           currentShape.lineWidth=newValue
           lastShape.lineWidth=newValue
        }
    }
    
    var strokeColor: UIColor = UIColor.red {
        willSet{
            currentShape.strokeColor=newValue.cgColor
            lastShape.strokeColor=newValue.withAlphaComponent(0.6).cgColor
        }
    }
    
    var zoomFactor:CGFloat=4{
        willSet{
            scrollView.maximumZoomScale=newValue > 6 ? 6 : newValue
        }
    }
    
    var originalImage:UIImage?{
        willSet{
            imageView.image=newValue
            setNeedsLayout()
        }
    }
    
    var snapShotImage:UIImage?{
        return imageView.snapshot
    }
    
    
    var isDrawSelected:Bool=false{
        willSet{
            if newValue==true{
                scrollView.isScrollEnabled=false
                scrollView.isUserInteractionEnabled=false
            }else{
                scrollView.isScrollEnabled=true
                scrollView.isUserInteractionEnabled=true
            }
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
        guard let _=superview else {return}
        
        super.layoutSubviews()
        
        updateMinZoomScaleForSize(bounds.size)
        scrollView.setContentOffset(center, animated: true)
      
    }
    
    //Used for UIMenuController
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
        
        //The Layer used for drawing
        imageView.layer.addSublayer(currentShape)
        imageView.layer.addSublayer(lastShape)
        imageView.layer.addSublayer(selectedShape)
        
        scrollView.addSubview(imageView)
        setupConstraintsForImageView()
       
        scrollView.delegate=self
        addSubview(scrollView)
        setupConstraintsForScrollView()
        
        // Enable user interaction for touch and gesture events in parent view
        // for enable finger drawing
        self.isUserInteractionEnabled=true
        self.isMultipleTouchEnabled=true
        
        //Must disable to forward the Touch events to the parent view
        imageView.isUserInteractionEnabled=false
        imageView.isMultipleTouchEnabled=false
       
    }
    
    // MARK: - Public interface
    func clear() {
        strokes.removeAll()
        selectedStrokes.removeAll()
        setNeedsDisplay()
    }


}




//MARK: - ScrollView Delegate methods
extension FreeHandDrawImageView:UIScrollViewDelegate{
    func updateMinZoomScaleForSize(_ size:CGSize){
        
        let widthScale =  size.width / (imageView.bounds.width)
        let heigthScale =  size.height / (imageView.bounds.height)
        
        let minScale = min(heigthScale,widthScale)
        scrollView.minimumZoomScale = minScale
        //scrollView.zoomScale = minScale
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
        if let _=superview {
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
        
        guard let _=self.window, self.becomeFirstResponder(), !menu.isMenuVisible else {return}
        
        //Setup menu & items
        
        let drawItem=UIMenuItem(title: "Draw", action: #selector(handleDrawMenuItem))
        
        let moveItem=UIMenuItem(title: "Scroll & Scale", action: #selector(handleScrollMenuItem))
        
        menu.menuItems=[drawItem,moveItem]
        
        //Show menu in custom view
        menu.setTargetRect(bounds, in: self)
        menu.setMenuVisible(true, animated: true)
       
    }
    
    //MARK: - Handle Menu
    @objc func handleDrawMenuItem(){
        isDrawSelected=true
      
    }
    
    @objc func handleScrollMenuItem(){
       isDrawSelected=false
    }
    
}


//MARK: - Handle touch events for drawing UIBezierpath
extension FreeHandDrawImageView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Collect start location of drawing
        //This method can be used for more than 1 touch
        for (index,touch) in touches.enumerated() {
           //Use specifc touch as key for saving
           let key=String(format: "%d", index)
           //Save Bezierpath first point in dictionary
            let touchLocation = touch.location(in: imageView)
            
            for (index,stroke) in strokes.enumerated(){
                if touchLocation.contains(path: stroke){
                    selectedStrokes.append(stroke)
                    strokes.remove(at: index)
                    setNeedsDisplay()
                }
            }
            
           let path = UIBezierPath()
           path.move(to: touchLocation)
           touchPaths[key]=path
        }
       
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Collect moving touch locations using key
        //touch
        for (index,touch) in touches.enumerated() {
            let key=String(format: "%d", index)
            if let path = touchPaths[key] {
                 let touchLocation = touch.location(in: imageView)
                path.addLine(to: touchLocation)
                
            }
            //Trigger drawing
            setNeedsDisplay()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for (index,_) in touches.enumerated() {
            let key=String(format: "%d", index)
            if let path = touchPaths[key] {
               strokes.append(path)
               //Remove last path from dictionary
               // for drawing this path in different color
               touchPaths.removeValue(forKey: key)
            }
            //Trigger drawing
            setNeedsDisplay()
        }
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}


//MARK: - The Draw method
extension FreeHandDrawImageView{
    override func draw(_ rect: CGRect) {
       
        //Create the drawing path for all exisiting strokes
        //using specified user color
        let drawingPath=UIBezierPath()
       
        //Collect all UIBezierpaths
        for path in strokes{
           drawingPath.append(path)
        }
       //Draw in sublayer of imageView
       lastShape.path=drawingPath.cgPath
        
        //Collect all paths again without the current path and repaint it with thinner color
        let lastPath=UIBezierPath()
        for path in touchPaths.values{
            lastPath.append(path)
        }
     
        //Draw in different layer
        currentShape.path = lastPath.cgPath
        
        let selectedPath=UIBezierPath()
        for path in selectedStrokes{
            selectedPath.append(path)
        }
       selectedShape.path=selectedPath.cgPath
        
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

extension CGPoint{
    func contains(path:UIBezierPath,thresholdWidth:CGFloat=10,scale:CGFloat=1)->Bool{
        let fatCGPath=path.cgPath.copy(strokingWithWidth: thresholdWidth/scale, lineCap: CGLineCap.round, lineJoin: CGLineJoin.miter, miterLimit: 1)
        let newPath=UIBezierPath(cgPath: fatCGPath)
        if newPath.contains(self){
            return true
        }
        return false
    }
}
