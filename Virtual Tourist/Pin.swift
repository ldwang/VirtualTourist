//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation
import CoreData

class Pin : NSManagedObject {
    
    struct Keys {
        static let Photos = "photos"
        static let ID = "id"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSDecimalNumber?
    @NSManaged var longitude: NSDecimalNumber?
    @NSManaged var photos: [Photo]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as! Int
        latitude = dictionary[Keys.Latitude] as? NSDecimalNumber
        longitude = dictionary[Keys.Longitude] as? NSDecimalNumber
        
    }
    
}
