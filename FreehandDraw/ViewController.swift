//
//  ViewController.swift
//  FreehandDraw
//
//  Created by Andre Frank on 12.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Constraints for Pan & zoom functionality
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var imageView: FreeHandDrawImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scrollView.delegate = self;
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    
    @IBAction func undo(_ sender: Any) {
        imageView.reverseStroke()
    }
    
    
    @IBAction func redrawImage(_ sender: Any) {
        //Take a snapshot from the changed image
        let image = imageView.snapshot
        
        // Just a test if property is working..
        imageView.strokeColor = .white
        imageView.strokeWidth = 10
    }
    
    @IBAction func clear(_ sender: Any) {
        imageView.clearFreeHandDrawing()
    }
}


extension ViewController:UIScrollViewDelegate{
    func updateMinZoomScaleForSize(_ size:CGSize){
        let widthScale = size.width / imageView.bounds.width
        let heigthScale = size.height / imageView.bounds.height
        
        var minScale = min(heigthScale,widthScale)
        minScale = min(minScale,1)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

