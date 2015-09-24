//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/12/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// 1. Import CoreData
import CoreData

// 2. Make Pin available to Objective-C code
@objc(Pin)

// 3. Make Pin a subclass of NSManagedObject
class Pin: NSManagedObject {
    
    struct Keys {
//        static let Latitude = "latitude"
//        static let Longitude = "longitude"
//        static let ID = "id"
    }

    // 4. We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var pictures: [Picture]

    
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
    
    init(location: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data

        latitude = location.latitude as Double
        longitude = location.longitude as Double
    }

}
