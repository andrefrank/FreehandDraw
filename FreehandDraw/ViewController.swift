//
//  ViewController.swift
//  FreehandDraw
//
//  Created by Andre Frank on 12.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        
    
    //MARK: - IBOutlets
    @IBOutlet weak var imageView: FreeHandDrawImageView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.originalImage=UIImage(named: "photo1")
    }
    
    @IBAction func clear(_ sender: Any) {
        imageView.clear()
    }
    @IBAction func snapShot(_ sender: Any) {
       
        imageView.zoomFactor=5

    }
    
}
