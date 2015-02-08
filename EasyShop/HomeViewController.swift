//
//  HomeViewController.swift
//  EasyShop
//
//  Created by Student on 2/7/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    
    @IBAction func uploadPicture(sender: UIButton) {
       // colorLabel.text = sender.titleLabel!.text!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "CameraSegue"{
            let vc = segue.destinationViewController as FirstViewController
            //vc.colorString = colorLabel.text
        }
    }
    
    //take photo
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        
        
        var selectedImage : UIImage = image
      //  img.image = selectedImage
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    // Your method to upload image with parameters to server.
    
    func uploadImageOne(){
       // var imageData = UIImagePNGRepresentation(imageView.image)
        
      /*  let imageData = nil
        
        if imageData != nil{
            var request = NSMutableURLRequest(URL: NSURL(string:"Enter Your URL")!)
            var session = NSURLSession.sharedSession()
            
            request.HTTPMethod = "POST"
            
            var boundary = NSString(format: "---------------------------14737809831466499882746641449")
            var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            //  println("Content Type \(contentType)")
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            var body = NSMutableData.alloc()
            
            // Title
            body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            
            // Image
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"profile_img\"; filename=\"img.jpg\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageData)
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            
            
            
            request.HTTPBody = body
            
            
            var returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            
            var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
            
            println("returnString \(returnString)")
            
        }
        
     */
    }
    
}
