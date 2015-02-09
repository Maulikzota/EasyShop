//
//  SecondViewController.swift
//  EasyShop
//
//  Created by Student on 2/7/15.
//  Copyright (c) 2015 Student. All rights reserved.
//
import UIKit
import MobileCoreServices
import CloudKit
import MobileCoreServices

class SecondViewController: UIViewController,ModelDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.loadImageURL()
        // Do any additional setup after loading the view, typically from a nib.
    }

    /*func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        println("i've got an image");
    }*/
    
     var capturedImages:NSArray?
    var mediaPicker :MKSImagePicker?
    
    func intializePhotoPicker(sender:AnyObject){
        
        if(self.mediaPicker == nil){
            
            self.mediaPicker = MKSImagePicker(frame: self.view.frame, superVC: self, completionBlock: { (isFinshed) -> Void in
                
                if(isFinshed != nil){
                    NSLog("Image captured properly")
                    self.updateDataSource()
                }
                else
                {
                    NSLog("Failure in image capturing")
                    
                }
            })
        }
        
        self.mediaPicker?.showImagePickerActionSheet(sender )
    }
    
   func configureCollectionView(){
        var cellNib:UINib = UINib(nibName: "LXMBottomCollectionViewStatusCell", bundle: NSBundle.mainBundle());
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.capturedImages != nil){
            return capturedImages!.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        
        var collectionViewCell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("DisplayCapturedImageCell", forIndexPath: indexPath) as UICollectionViewCell;
        
        
        var statusImageView:UIImageView = collectionViewCell.viewWithTag(11) as UIImageView;
        var imagePath =  self.capturedImages!.objectAtIndex(indexPath.row)as String
        var absoluteImagePath:String = String.savedImageDirPath(imagePath)!
        
        statusImageView.image  = UIImage(contentsOfFile:absoluteImagePath)
        
        return collectionViewCell;
        
        
    }

    
    func updateDataSource(){
        
        String.getContentsOfDirectoryAtPath("CapturedImages", block: { (filenames, error) -> () in
            self.capturedImages = filenames
            self.imagesCollectionView.reloadData()
            
        })
    }

    
   
    
    @IBAction func capture(sender : UIButton) {
         intializePhotoPicker(sender)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Button capture")
            
            var imag = UIImagePickerController()
            imag.mediaTypes = [kUTTypeImage]
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.Camera;
            imag.mediaTypes = [kUTTypeImage]
            imag.allowsEditing = false
            
            self.presentViewController(imag, animated: true, completion: nil)
        }
    }
    
     //for cloudkit model
    func errorUpdating(error: NSError) {
        let message = error.localizedDescription
        let alert = UIAlertView(title: "Error Loading Photo",
            message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func modelUpdated() {
      //  refreshControl?.endRefreshing()
       
    }
  
//    func loadImageURL(){
//        
//        let detailItem = ShopPhotos!
//            
//        detailItem.fetchPhotos() { assets in
//            if assets != nil {
//                var x = 10
//                for record in assets {
//                    if let asset = record.objectForKey("Photo") as? CKAsset {
//                        let image: UIImage? = UIImage(contentsOfFile: asset.fileURL.path!)
//                        if image != nil {
//                            let imView = UIImageView(image: image)
//                           // image ?.description
//                        }
//                    }
//                }
//            }
//        }
//    
//    }
   


}

