//
//  ViewController.swift
//  FreehandDraw
//
//  Created by Andre Frank on 12.04.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ImagePickerServiceDelegate{
    
    var imagePickerServce:ImagePickerService!
    
    //MARK: - IBOutlets
    @IBOutlet weak var imageView: FreeHandDrawImageView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.originalImage=UIImage(named: "photo1")
        imagePickerServce=ImagePickerService(delegate: self, completion: { (succcess) in
            
        })
    }
    
    @IBAction func clear(_ sender: Any) {
        imageView.clear()
    }
    @IBAction func snapShot(_ sender: Any) {
        
        imageView.zoomFactor=5
        //imagePickerServce.takeMedia()
        imageView.originalImage=UIImage(named: "high_res")
    }
    
    func imagePickerService_Image(media: UIImage) {
        imageView.originalImage=media
    }
    
    func imagePickerService_Movie(mediaUrl: NSURL) {
        print(mediaUrl)
    }
    
    func imagePickerService_cancel() {
        print("User has canceled")
    }
    
    
    
    
}
