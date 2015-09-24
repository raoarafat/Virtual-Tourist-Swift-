//
//  Picture.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/12/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import Foundation
import UIKit

// 1. Import CoreData
import CoreData

// 2. Make Picture available to Objective-C code
@objc(Picture)

// 3. Make Pin a subclass of NSManagedObject
class Picture: NSManagedObject {
    
    struct Keys {
        static let Title = "name"
        static let ImagePath = "profile_path"
        static let ID = "id"
    }

    
// 4. We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var title: String?
    @NSManaged var pins: Pin
    
    // 5. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    * 6. The two argument init method
    *
    * The Two argument Init method. The method has two goals:
    *  - insert the new Pin into a Core Data Managed Object Context
    *  - initialze the Pin's properties from a dictionary
    */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
                
        let idTemp = dictionary[VTClient.JSONResponseKeys.ID] as! String
        
        id        = NSNumber(integer: Int(idTemp)!) // integer
        title     = dictionary[VTClient.JSONResponseKeys.Title] as? String
        imagePath = dictionary[VTClient.JSONResponseKeys.ImagePath] as? String
    }
    
        var image: UIImage? {
            get {
                
                let url = NSURL(fileURLWithPath: imagePath!)
                let fileName = url.lastPathComponent
                
                return VTClient.Caches.imageCache.imageWithIdentifier(fileName!)
            }
            set {
                
                let url = NSURL(fileURLWithPath: imagePath!)
                let fileName = url.lastPathComponent
                
                VTClient.Caches.imageCache.storeImage(newValue, withIdentifier: fileName!)
                
            }
        }
    
    //Delete the associated image file when the Photo managed object is deleted.
     override func prepareForDeletion() {
        
        let url = NSURL(fileURLWithPath: imagePath!)
        let fileName = url.lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let pathArray = [dirPath, fileName!]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(fileURL!)
        } catch _ {
        }
        
    }


}
