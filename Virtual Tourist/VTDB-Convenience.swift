//
//  VTDB-Convenience.swift
//  Virtual Tourist
//
//  Created by Daniel Wang on 2016-05-29.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import CoreData

extension VTDB {
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    //MARK: Get Flickr Image URLs by Pin
    
    func getPhotosByPin(pin: Pin, completionHandler: (result : AnyObject!, error: NSError?) -> Void ) {
        
        var page = 1
        
        if pin.totalPages != 0 {
            
            //Found Flickr returning the same photo list if page number is too high (>49)), set up the random page number to smaller number
            page = Int(arc4random_uniform(UInt32(min(40,pin.totalPages)))) + 1
        }
        
        let parameters  = [
            "method": Methods.Search,
            "api_key": Constants.ApiKey,
            "bbox": self.createBoundingBoxString(pin),
            "safe_search": SearchOptions.SafeSearch,
            "extras": SearchOptions.Extras,
            "format": SearchOptions.DataFormat,
            "per_page": SearchOptions.PerPage,
            "page": page,
            "nojsoncallback": SearchOptions.NoJSONCallBack
        ]
        

        print(parameters)
        
        taskForGetMethod(parameters as! [String : AnyObject]) { result, error in
            
            if let error = error {
                print(error)
                completionHandler(result : nil,  error: error)
            } else {

                if let photos = result["photos"] as? [String: AnyObject] {
                    if let totalPages = photos["pages"] as? Int {
                        
                        pin.totalPages = totalPages
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        
                            
                        var results = [AnyObject]()
                        
                        if let photoArray = photos["photo"] as? [[String: AnyObject]] {
                            for photo in photoArray {
                                var photoDict : [String:AnyObject] = [:]
                                photoDict["photo_url"]  = photo["url_m"] as! String
                                photoDict["id"] = photo["id"]?.integerValue
                                photoDict["title"] = photo["title"] as! String
                                results.append(photoDict)
                                print(photoDict["photo_url"])
                            }
                            
                            completionHandler(result : results, error: nil)
                            
                        } else {
                            print("Cannot find key 'photo' in \(result)")
                            let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot find key 'photo' in \(result)"])
                            completionHandler(result : nil, error: errorObject)
                        }
                            
                    } else {
                        print("Cannot find key 'pages' in \(result)")
                        let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot find key 'pages' in \(result)"])
                        completionHandler(result : nil, error: errorObject)
                    }
                } else {
                    print("Cannot find key 'photos' in \(result)")
                    let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot find key 'photos' in \(result)"])
                    completionHandler(result : nil, error: errorObject)
                }
                
            }
        }
    }

}