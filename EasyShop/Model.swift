/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import CloudKit
import CoreLocation

let ShopPhotosType = "ShopPhotos"

protocol ModelDelegate {
  func errorUpdating(error: NSError)
  func modelUpdated()
}

@objc class Model {
  
  class func sharedInstance() -> Model {
    return modelSingletonGlobal
  }

  var delegate : ModelDelegate?
  
  var items = [ShopPhotos]()
  let userInfo : UserInfo
  
  let container : CKContainer
  let publicDB : CKDatabase
 // let privateDB : CKDatabase
  
  init() {
    container = CKContainer.defaultContainer() //1
    publicDB = container.publicCloudDatabase //2
   // privateDB = container.privateCloudDatabase //3
    
    userInfo = UserInfo(container: container)
  }
  
  func refresh() {
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "ShopPhotos", predicate: predicate)
    publicDB.performQuery(query, inZoneWithID: nil) { results, error in
      if error != nil {
        dispatch_async(dispatch_get_main_queue()) {
          self.delegate?.errorUpdating(error)
          println("error loading: \(error)")
        }
      } else {
        self.items.removeAll(keepCapacity: true)
        for record in results{
          let shop = ShopPhotos(record: record as CKRecord, database:self.publicDB)
          self.items.append(shop)
        }
        dispatch_async(dispatch_get_main_queue()) {
          self.delegate?.modelUpdated()
          println()
        }
      }
    }
  }
  
  func shop(ref: CKReference) -> ShopPhotos! {
    let matching = items.filter {$0.record.recordID == ref.recordID}
    var e : ShopPhotos!
    if matching.count > 0 {
      e = matching[0]
    }
    return e
  }
  
}

let modelSingletonGlobal = Model()