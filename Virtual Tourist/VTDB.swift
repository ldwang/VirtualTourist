//
//  VTDB.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation

class VTDB : NSObject {
    
    typealias CompletionHandler = (result: AnyObject!, error: NSError?)
    
    var session: NSURLSession
    
//    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
}