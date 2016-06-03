//
//  VTDB.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import CoreData

class VTDB : NSObject {
    
    
    var session: NSURLSession
    
//    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - All purpose task method for data
    
    func taskForGetMethod(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        let urlString = Constants.BaseUrl + VTDB.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            if error !== nil {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
            } else {
                
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                
                if  statusCode >= 200 && statusCode <= 299 {
                    
                    if let data = data {
                        /* Parse the data and use the data (happens in completion handler) */
                        VTDB.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                    } else {
                        let errorObject = NSError(domain: "DomainError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request!"])
                        completionHandler(result: nil, error: errorObject)
                    }
                } else  {
                    let errorObject = NSError(domain: "DomainError", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code \(statusCode)"])
                    completionHandler(result: nil, error: errorObject)
                }
            }
        }
        
        task.resume()
        
        return task
   
    }
   
 
    func taskForGetImage(urlString: String, completionHandler : (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        //print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            if error !== nil {
                print("There was an error with your request: \(error)")
                completionHandler(imageData : nil, error: error)
            } else {
                
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                
                if  statusCode >= 200 && statusCode <= 299 {
                    
                    if let data = data {
                       
                        completionHandler(imageData: data, error: nil)
                    }
                } else  {
                    let errorObject = NSError(domain: "DomainError", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code \(statusCode)"])
                    completionHandler(imageData : nil, error: errorObject)
                }
            }
        }
        
        task.resume()
        
        return task
    
    }


    // MARK: - Helpers
    
    //Lat/Lon Maipulation
    func createBoundingBoxString(pin : Pin) -> String {
        
        let latitude = pin.latitude
        let longitude = pin.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - SearchOptions.BoundingBoxHalfWidth, SearchOptions.LonMin)
        let bottom_left_lat = max(latitude - SearchOptions.BoundingBoxHalfHeight, SearchOptions.LatMin)
        let top_right_lon = min(longitude + SearchOptions.BoundingBoxHalfWidth, SearchOptions.LonMax)
        let top_right_lat = min(latitude + SearchOptions.BoundingBoxHalfHeight, SearchOptions.LatMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    // MARK: - Shared Instance
    
   static let sharedInstance = VTDB()
    
//    class func sharedInstance() -> VTDB {
//        
//        struct Singleton {
//            static var sharedInstance = VTDB()
//        }
//        
//        return Singleton.sharedInstance
//    }
    
    
    //MARK: Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    func showAlert(hostViewController: UIViewController, alertString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let alertString = alertString {
                let alertController = UIAlertController(title: "", message: "\(alertString)", preferredStyle: .Alert)
                let dismiss = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) -> Void in }
                alertController.addAction(dismiss)
                hostViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }

}