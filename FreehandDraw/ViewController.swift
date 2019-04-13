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
        
        let image = imageView.snapshot
        imageView.strokeColor = .white
        imageView.strokeWidth = 10
    }
    
    @IBAction func clear(_ sender: Any) {
        imageView.clearFreeHandDrawing()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
    

