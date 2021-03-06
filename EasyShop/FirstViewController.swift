//
//  FirstViewController.swift
//  EasyShop
//
//  Created by Student on 2/7/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit
import MobileCoreServices
import Foundation
import CoreData


class FirstViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLConnectionDataDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let container = CKContainer.defaultContainer()
    var publicDatabase: CKDatabase?
    var currentRecord: CKRecord?
    var photoURL: NSURL?
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        publicDatabase = container.publicCloudDatabase
        // Do any additional setup after loading the view, typically from a nib.
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectPhoto(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType =
            UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as NSString]
        
        self.presentViewController(imagePicker, animated: true,
            completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        let image =
        info[UIImagePickerControllerOriginalImage] as UIImage
        imageView.image = image
        photoURL = saveImageToFile(image)
    }
    
    func imagePickerControllerDidCancel(picker:
        UIImagePickerController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImageToFile(image: UIImage) -> NSURL
    {
        let dirPaths = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)
        
        let docsDir: AnyObject = dirPaths[0]
        
        let filePath =
        docsDir.stringByAppendingPathComponent("currentImage.jpg")
        
        UIImageJPEGRepresentation(image, 0.5).writeToFile(filePath,
            atomically: true)
        
        return NSURL.fileURLWithPath(filePath)!
    }
    
    @IBAction func saveRecord(sender: AnyObject) {
        
        if (photoURL == nil) {
            notifyUser("No Photo", message: "Use the Photo option to choose a photo for the record")
            return
        }
        
        println("local file is at \(photoURL?.absoluteString!)")
        
        //var redirecturl: NSURL?
        
        var err:NSError?
        let fm = NSFileManager.defaultManager()
        var fooqueue = dispatch_queue_create("bkgnd", nil)
        dispatch_async(fooqueue, {
            println("in the background")
            if let dest = fm.URLForUbiquityContainerIdentifier(nil) {
                let newdest = dest.URLByAppendingPathComponent("Documents/currentImage.jpg")
//                println("dest url is \(newdest)")
//                let s = fm.setUbiquitous(true, itemAtURL: self.photoURL!, destinationURL: newdest, error: &err)
//                if (err != nil) {
//                    println("Error setting ubiquitous...")
//                    println(err?.localizedDescription)
//                }
////                let fileURLinCloud = dest.URLByAppendingPathComponent("Documents/currentImage3.jpg")
                println("\ncalling URLForPublishingUbiquitousItemAtURL with \(newdest)")
                if let newURL = fm.URLForPublishingUbiquitousItemAtURL(newdest, expirationDate: nil, error: &err) {
                    println("uploaded to iCloud: %s", newURL.absoluteString)
                    let b = newURL.absoluteString!.stringByRemovingPercentEncoding!
                    let c = b.stringByRemovingPercentEncoding!
                    let yourImageURL = newURL.absoluteString!;
                    let searchURL = "https://www.google.com/searchbyimage?&image_url="
                    let completeURL = searchURL + yourImageURL
                    let str = NSURL(string: completeURL)
//                    NSString * completeURL = [NSString stringWithFormat:@"%@%@", searchURL, yourImageURL];
                    
                    UIApplication.sharedApplication().openURL(newURL)
                    //redirecturl = newURL
                    
                 
                    
                    
                    println(c)
                } else {
                    println("error getting pub url")
                    println(err?.localizedDescription)
                }
                
                
            } else {
                println("could not get URLforUbiquityContainerIdentifier")
            }

            
        })
        
        //let a="http%3A%2F%2Fwww.google.com%2F%0A"
        
        
        
//
//        
//        let asset = CKAsset(fileURL: photoURL!)
//        
//        let myRecord = CKRecord(recordType: "ShopPhotos")
//        myRecord.setObject(asset, forKey: "Photo")
//        myRecord.setObject("Maulik", forKey: "User")
//        myRecord.setObject("Maulik", forKey: "Name")
//        NSLog("Enter1")
//        
//        publicDatabase!.saveRecord(myRecord, completionHandler:
//            ({returnRecord, error in
//                if let err = error {
//                     NSLog("Enter")
//                    self.notifyUser("Save Error", message:
//                        err.localizedDescription)
//                } else {
//                     NSLog("Enter2")
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self.notifyUser("Success",
//                            message: "Record saved successfully")
//                    }
//                    self.currentRecord = myRecord
//                }
//            }))
    }
    
    func notifyUser(title: String, message: String) -> Void
    {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true,
            completion: nil)
    }
    
    @IBAction func performQuery(sender: AnyObject) {
        
        let predicate = NSPredicate(format: "User = %@", "Maulik")
        
        let query = CKQuery(recordType: "ShopPhotos", predicate: predicate)
        
        publicDatabase?.performQuery(query, inZoneWithID: nil,
            completionHandler: ({results, error in
                
                if (error != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.notifyUser("Cloud Access Error",
                            message: error.localizedDescription)
                    }
                } else {
                    if results.count > 0 {
                        
                        var record = results[0] as CKRecord
                        self.currentRecord = record
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            let photo =
                            record.objectForKey("Photo") as CKAsset
                            
                            let image = UIImage(contentsOfFile:
                                photo.fileURL.path!)
                            //NSLog(photo.string)
                            NSLog(photo.fileURL.path!)
                           // UIApplication.sharedApplication().openURL(NSURL(string: "http://www.google.com")!)
                            
                            
                            var imageData = UIImagePNGRepresentation(image)
                  
                           
                            
                
                            
                          /*  let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                                data, response, error in
                                
                                if error != nil {
                                    // handle error here
                                    return
                                }
                                
                                // if response was JSON, then parse it
                                
                                var parseError: NSError?
                                let responseObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &parseError)
                                
                                if let responseDictionary = responseObject as? NSDictionary {
                                    // handle the parsed dictionary here
                                } else {
                                    // handle parsing error here
                                }
                                
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
                            task.resume()*/
                            
                            
                            
                            //self.imageView.image = image
                            //self.photoURL = self.saveImageToFile(image!)
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.notifyUser("No Match Found", 
                                message: "No record matching the address was found")
                        }
                    }
                }
            }))
    }
    
    
    @IBAction func urlDownload(sender: AnyObject) {
        
        let fm = NSFileManager.defaultManager()
        
//        var err:NSError?
//        
//        let dest = fm.URLForUbiquityContainerIdentifier("iCloud.mmz.EasyShop")
//        let z = dest?.URLByAppendingPathComponent("#iclouddrive")
//        let y = z?.URLByAppendingPathComponent("images.jpeg")
//        let d = fm.URLForPublishingUbiquitousItemAtURL(y!,expirationDate:nil,error: &err)
//        if let string = d?.absoluteString {
//            println(string)
//        }
        
    }
    
//      func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest? {
//        if((response) != nil){
//            let url = [request .URL]
//            
//            NSMutableURLRequest *newRequst = [_originalRequest mutuableCopy]
//            
//        }
 //   }
    
    
    
}









