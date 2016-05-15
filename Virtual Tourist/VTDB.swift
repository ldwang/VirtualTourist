//
//  VTDB.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation

class VTDB : NSObject {
    
    
    var session: NSURLSession
    
//    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey
        
        let urlString = Constants.BaseUrl + resource + VTDB.escapedParameters(mutableParameters)
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

    // MARK: - Helpers
    
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            print("Step 4 - parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
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
    
    class func sharedInstance() -> VTDB {
        
        struct Singleton {
            static var sharedInstance = VTDB()
        }
        
        return Singleton.sharedInstance
    }
    
    
    //MARK: Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}