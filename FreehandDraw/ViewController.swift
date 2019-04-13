//
//  ViewController.swift
//  FreehandDraw
//
//  Created by Andre Frank on 12.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var imageView: FreeHandDrawImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 6.0;
        self.scrollView.contentSize = self.imageView.frame.size;
        self.scrollView.delegate = self;
    }
    
    @IBAction func redrawImage(_ sender: Any) {
        
        let image = imageView.screenShot
        imageView.strokeColor = .white
        imageView.strokeWidth = 10
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
   
    @IBAction func zoom(_ sender: Any) {
        imageView.isZoom=true
    }
    
    @IBAction func mark(_ sender: Any) {
        imageView.isZoom=false
    }
}
    

