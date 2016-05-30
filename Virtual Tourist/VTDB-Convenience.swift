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
    
    func getPhotosByPin(pin: Pin,  completionHandler: (success : Bool, error: NSError?) -> Void ) {
        
        let parameters = [
            "method": Methods.Search,
            "api_key": Constants.ApiKey,
            "bbox": self.createBoundingBoxString(pin),
            "safe_search": SearchOptions.SafeSearch,
            "extras": SearchOptions.Extras,
            "format": SearchOptions.DataFormat,
            "per_page": SearchOptions.PerPage,
            //"page" : pageNum,
            "nojsoncallback": SearchOptions.NoJSONCallBack
        ]
        
        //print(parameters)
        
        taskForGetMethod(parameters as! [String : AnyObject]) { result, error in
            
            if let error = error {
                print(error)
                completionHandler(success : false,  error: error)
            } else {
                if let photos = result["photos"] as? [String: AnyObject] {
                    if let pages = photos["pages"] as? Int {
                        
                        var photoURLs: [String] = []
                        
                        if let photoArray = photos["photo"] as? [[String: AnyObject]] {
                            for photo in photoArray {
                                photoURLs.append(photo["url_m"] as! String)
                            }
                            completionHandler(success: true, error: nil)
                        } else {
                            print("Cannot find key 'photo' in \(result)")
                            let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot find key 'photo' in \(result)"])
                            completionHandler(success: false, error: errorObject)
                        }
                        
                    } else {
                        print("Cannot find key 'pages' in \(result)")
                        let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot find key 'pages' in \(result)"])
                        completionHandler(success: false, error: errorObject)
                    }
                } else {
                    print("Cannot find key 'photos' in \(result)")
                    let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot find key 'pages' in \(result)"])
                    completionHandler(success: false, error: errorObject)
                }
                
            }
        }
    }

}