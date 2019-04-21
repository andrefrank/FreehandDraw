//
//  ImagePickerService.swift
//  DailySafe
//
//  Created by Andre Frank on 27.03.19.
//  Copyright © 2019 Afapps+. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ImagePickerServiceDelegate:UIViewController{
    func imagePickerService_Image(media:UIImage)
    func imagePickerService_Movie(mediaUrl:NSURL)
    func imagePickerService_cancel()
}

class ImagePickerService:NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
     let imagePicker = UIImagePickerController()
    
    weak var delegate:ImagePickerServiceDelegate?
    
    init(delegate:ImagePickerServiceDelegate,completion:(_ success:Bool)->Void){
        self.delegate = delegate
        super.init()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            imagePicker.delegate=self
            
            //Source type must be set first before any other properties can be set
            imagePicker.sourceType = .camera
            
            imagePicker.cameraDevice = .rear
            imagePicker.mediaTypes = [kUTTypeMovie,kUTTypeImage] as [String]
           
           
            completion(true)
        }else{
            self.delegate=nil
            completion(false)
        }
        
    }
    
    func takeMedia(){
        guard (delegate != nil) else {return}
        delegate!.present(imagePicker, animated: true,completion: nil)
    }
    
}

extension ImagePickerService{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
         picker.dismiss(animated: true)
        
        if info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeMovie {
             delegate?.imagePickerService_Movie(mediaUrl: info[UIImagePickerController.InfoKey.mediaURL] as! NSURL)
           
        }else if info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage {
            delegate?.imagePickerService_Image(media: info[.originalImage] as! UIImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        delegate?.imagePickerService_cancel()
    }
}
