//
//  ImageVideoPicker.swift
//  HelloSwift
//
//  Created by Mohd Kamarshad on 10/09/14.
//  Copyright (c) 2014 Mohd Kamarshad. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit
import MobileCoreServices

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
                    
                    var request = self.createRequest (imageData,path: imagePath)
                    
                    let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                        data, response, error in
                        
                        
                        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                        var err1: NSError?
                        var json2 = NSJSONSerialization.JSONObjectWithData(strData.dataUsingEncoding(NSUTF8StringEncoding)!, options: .MutableLeaves, error:&err1 ) as NSDictionary
                        
                        println("json2 :\(json2)")
                        
                        if(error != nil) {
                            println(error!.localizedDescription)
                        }
                        else {
                            var success = json2["success"] as? Int
                            println("Succes: \(success)")
                        }
                            
                        // if response was JSON, then parse it
                        
                        // if response was text or html, then just convert it to a string
                        //
                        // let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                        // println("responseString = \(responseString)")
                        
                        // note, if you want to update the UI, make sure to dispatch that to the main queue, e.g.:
                        //
                        // dispatch_async(dispatch_get_main_queue()) {
                        //     // update your UI and model objects here
                        // }
                    })
                    task.resume()
                    
                    
                    
                    
                   /* var returnData = NSURLConnection.sendSynchronousRequest( self.createRequest(imageData,path: imagePath),returningResponse: nil, error: nil)
                    
                    var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
                    
                     println("returnString \(returnString)") */
                    picker.dismissViewControllerAnimated(true,completion:nil);

                    self.imageCompletionClosure!(isCaptureSuccessfully: true);

                }
            })
            
            
        }
        
    }
    
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        if (self.imageCompletionClosure != nil)
        {
            self.imageCompletionClosure!(isCaptureSuccessfully: false);
        }
        
        picker.dismissViewControllerAnimated(true,completion:nil);
    }
    
    
    /// Create request
    ///
    /// :param: userid   The userid to be passed to web service
    /// :param: password The password to be passed to web service
    /// :param: email    The email address to be passed to web service
    ///
    /// :returns:         The NSURLRequest that was created
    
    func createRequest (data:NSData,path: String) -> NSURLRequest {
        
        
        let boundary = generateBoundaryString()
        
        let url = NSURL(string: "www.google.com/searchbyimage?&upload")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = createBodyWithParameters( "file", data:data,path: path, boundary: boundary)
        
        return request
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// :param: parameters   The optional dictionary containing keys and values to be passed to web service
    /// :param: filePathKey  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// :param: paths        The optional array of file paths of the files to be uploaded
    /// :param: boundary     The multipart/form-data boundary
    ///
    /// :returns:            The NSData of the body of the request
    
    func createBodyWithParameters(filePathKey: String?, data: NSData?,path:String, boundary: String) -> NSData {
        let body = NSMutableData()
        
        
        if data != nil {
           
                let filename = path.lastPathComponent
               
                let mimetype = mimeTypeForPath(path)
                
                 body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                  body.appendData(NSString(format: "filename=%@\r\n",filename).dataUsingEncoding(NSUTF8StringEncoding)!)
                  body.appendData(NSString(format: "Content-Disposition: form-data; name=%@\r\n",filePathKey!).dataUsingEncoding(NSUTF8StringEncoding)!)
                  body.appendData(NSString(format: "encoded_image:%@\r\n",data!).dataUsingEncoding(NSUTF8StringEncoding)!)
                 body.appendData(NSString(format: "image_url:%@\r\n","").dataUsingEncoding(NSUTF8StringEncoding)!)

                 body.appendData(NSString(format: "image_content:%@\r\n","").dataUsingEncoding(NSUTF8StringEncoding)!)

                 body.appendData(NSString(format: "h1:en\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)

                 body.appendData(NSString(format: "bih","").dataUsingEncoding(NSUTF8StringEncoding)!)

                 body.appendData(NSString(format: "biw","").dataUsingEncoding(NSUTF8StringEncoding)!)
                
                 body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                 body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                 body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                 body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)

        }
        
        body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)

        
        NSLog("body====", body)
        
        return body
        
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary----------------------------14737809831466499882746641449"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// :param: path         The path of the file for which we are going to determine the mime type.
    ///
    /// :returns:            Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    func mimeTypeForPath(path: String) -> String {
        let pathExtension = path.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as NSString
            }
        }
        return "application/octet-stream";
    }
    
    
}

/*extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// :param: string       The string to be added to the `NSMutableData`.
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}*/


