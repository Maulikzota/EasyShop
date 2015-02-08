//
//  ImageVideoPicker.swift
//  HelloSwift
//
//  Created by Mohd Kamarshad on 10/09/14.
//  Copyright (c) 2014 Mohd Kamarshad. All rights reserved.
//

import UIKit


class MKSImagePicker: UIView,UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK:- PROPERTIES
    
    var originVC:UIViewController?
    
    typealias imageCaptureClosure = (isCaptureSuccessfully:Bool?)->Void
    
    var imageCompletionClosure:imageCaptureClosure?
    
    
    //MARK: - View Life Cycle Methods
    
    init(frame:CGRect, superVC originVC:UIViewController, completionBlock:imageCaptureClosure){
        self.originVC = originVC
        self.imageCompletionClosure = completionBlock
        
        super.init(frame:frame)
        
        //Display Capture Options to the User....
    }
    


    required init(coder aDecoder: NSCoder) {
        self.originVC = nil
        self.imageCompletionClosure = nil
        super.init(coder: aDecoder)
        
    }
    
    
    
    func showImagePickerActionSheet(sender:AnyObject){
        var actionContrller = UIAlertController(title: " ", message:"Take Pic ", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionContrller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancelAction))
        actionContrller.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler:handleCameraAction))
        actionContrller.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Destructive, handler:handlePhotoLibAction))
        
        if let popoverController = actionContrller.popoverPresentationController {
            actionContrller.popoverPresentationController!.barButtonItem = sender as UIBarButtonItem
        }
        self.originVC!.presentViewController(actionContrller, animated: true, completion: nil)
    }

    //MARK:- Private Methods
    private func handleCancelAction(alertAction:UIAlertAction!){
        self.imageCompletionClosure!(isCaptureSuccessfully: false);
        self.originVC!.dismissViewControllerAnimated(false, completion:nil)
        
    }
    
    private func handleCameraAction(alertAction:UIAlertAction!){
        
        self.startCameraControllerFromViewController(self.originVC, usingDelegate:self)
    }

    private func handlePhotoLibAction(alertAction:UIAlertAction!){
        self.startPhotoLibraryControllerFromViewController(self.originVC, usingDelegate:self)
    }

    private func startPhotoLibraryControllerFromViewController<T where T: UINavigationControllerDelegate,T: UIImagePickerControllerDelegate>(controller:UIViewController?,
        usingDelegate delegate: T?)->Bool{
            
            if((UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) == false)||(controller == nil)||(delegate == nil)){
                return false
                
            }
            
            var libraryUI = UIImagePickerController()
            libraryUI.delegate = delegate
            controller!.presentViewController(libraryUI, animated: true, completion:nil)
            
            return true
    }
    
    
    
    private func startCameraControllerFromViewController<T where T: UINavigationControllerDelegate,T: UIImagePickerControllerDelegate>(controller:UIViewController?, usingDelegate delegate:T?)->Bool
    {
        if((UIImagePickerController.isSourceTypeAvailable(.Camera) == false)||(controller == nil)||(delegate == nil)){
            return false
            
        }
        
        var cameraUI = UIImagePickerController()
        cameraUI.delegate = delegate
        cameraUI.sourceType = .Camera;
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        cameraUI.allowsEditing = false;
        cameraUI.delegate = delegate;
      
        controller!.presentViewController(cameraUI, animated: true, completion:nil)
        
        return true;
    }
    
    //MARK: - UIImagePickerControllerDelegate delegate methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        
        let tempImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        if (self.imageCompletionClosure != nil)
        {
            //Save Captured Image in Document Directory......
            String.createImageDirectoryIfNeedWithCompletion(folderName: "CapturedImages", completionBlock: { (directoryPath,fileCount) -> Void in
                
                let currentTimeStamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)

                var imagePath = "\(directoryPath)/\(fileCount).png"
                
                if !imagePath.isEmpty {
                    
                    var imageData:NSData = UIImageJPEGRepresentation(tempImage, 0.8)
                    imageData.writeToFile(imagePath, atomically:true)
                    NSLog("Image Path is \(imagePath)")
                    picker.dismissViewControllerAnimated(true,completion:nil);

                    self.imageCompletionClosure!(isCaptureSuccessfully: true);

                }
            })
            
            
        }
        
    }
    
    
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

    
    
    
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        if (self.imageCompletionClosure != nil)
        {
            self.imageCompletionClosure!(isCaptureSuccessfully: false);
        }
        
        picker.dismissViewControllerAnimated(true,completion:nil);
    }
}
