//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Photo : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let PhotoURL = "photo_url"
    }
    
    @NSManaged var photoURL: String?
    @NSManaged var id: Int
    @NSManaged var title: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        photoURL = dictionary[Keys.PhotoURL] as? String
        id =  dictionary[Keys.ID] as! Int
        title = dictionary[Keys.Title] as? String
        
    }
    
    var image: UIImage? {
        
        get {
            return VTDB.Caches.imageCache.imageWithIdentifier(photoURL)
        }
        
        set {
            VTDB.Caches.imageCache.storeImage(newValue, withIdentifier: photoURL!)
        }
    }

    override func prepareForDeletion() {
        VTDB.Caches.imageCache.removeImage(photoURL!)
    }
    
    
}
