//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)

class Pin : NSManagedObject {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var totalPages : Int
    @NSManaged var currentPage : Int
    @NSManaged var photos: [Photo]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.totalPages = 1
        self.currentPage = 1
        
    }
    
}
