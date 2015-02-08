//
//  ShopPhotos.swift
//  EasyShop
//
//  Created by Student on 2/7/15.
//  Copyright (c) 2015 Student. All rights reserved.
//

import Foundation
import CloudKit



class ShopPhotos : NSObject {
    
    var record : CKRecord!
    var name : String!
    weak var database : CKDatabase!
    
    var assetCount = 0
    
    
    init(record : CKRecord, database: CKDatabase) {
        self.record = record
        self.database = database
        
        self.name = record.objectForKey("Name") as String!
       
    }
    
    
    
    func fetchPhotos(completion:(assets: [CKRecord]!)->()) {
        let predicate = NSPredicate(format: "User == %@", record)
        let query = CKQuery(recordType: "ShopPhotos", predicate: predicate);
        //Intermediate Extension Point - with cursors
        database.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil {
                self.assetCount = results.count
            }
            completion(assets: results as [CKRecord]!)
        }
    }
    
    
   /* func loadCoverPhoto(completion:(photo: UIImage!) -> ()) {
        // 1
        dispatch_async(
            dispatch_get_global_queue(
                DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)){
                    var image: UIImage!
                    // 2
                    let coverPhoto = self.record.objectForKey("Photo") as CKAsset!
                    if let asset = coverPhoto {
                        // 3
                        if let url = asset.fileURL {
                            let imageData = NSData(contentsOfFile: url.path!)!
                            // 4
                            image = UIImage(data: imageData) 
                        }
                    }
                    // 5
                    completion(photo: image) 
        }
    }*/
    
}



