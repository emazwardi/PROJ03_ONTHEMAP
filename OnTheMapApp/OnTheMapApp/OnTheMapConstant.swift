//
//  OnTheMapConstant.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 1/09/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//


extension OnTheMapApi {
    
    
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURLParse  : String = "https://api.parse.com/1/classes/StudentLocation?"
        static let BaseURLSecure : String = "https://www.udacity.com/api/session"
        static let PostURL       : String = "https://api.parse.com/1/classes/StudentLocation"
        static let UpdateURL     : String = "https://api.parse.com/1/classes/StudentLocation/object_id"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        static let GetLocStudent  = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22unique_key%22%7D"
        static let GetLocStudents = "https://api.parse.com/1/classes/StudentLocation?limit=number&order=-updatedAt"
        static let POST = "POST"
        static let UPDATE = "PUT"
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let ErrorMessage = "error"
        static let ErrorStatus = "status"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let SessionId = "id"
        static let Results = "results"
        
        // MARK: Account
        static let UserID = "id"
        
          
    }
}