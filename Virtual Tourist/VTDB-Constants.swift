//
//  VTDB-Constants.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-24.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation

extension VTDB {
    
    struct Constants {
        
        //MARK: API Key
        static let ApiKey = "b267f3abec7302dabd3dd1f8fc568b72"
        
        //MARK: - URLs
        static let BaseUrl = "https://api.flickr.com/services/rest/"
    }
    
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    
    struct NSUserDefaultKey {
        static let MapRegionKey = "Map Region key"
    }
    
    struct SearchOptions {
        static let Extras = "url_m"
        static let SafeSearch = "1"
        static let dataFormat = "json"
        static let NoJSONCallBack = "1"
        static let BoundingBoxHalfWidth = "1.0"
        static let BoundingBoxHalfHeight = "1.0"
        static let LatMin = "-90.0"
        static let LatMax = "90.0"
        static let LonMin = "-180.0"
        static let LonMax = "180.0"
    }
    
    struct Keys {
        static let ID = "id"
    }
}