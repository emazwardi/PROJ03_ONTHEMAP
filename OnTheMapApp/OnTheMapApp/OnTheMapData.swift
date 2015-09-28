//
//  OnTheMapData.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 27/09/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import Foundation


class OnTheMapData {
    class var sharedInstance: OnTheMapData {
        struct Static {
            static var instance: OnTheMapData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = OnTheMapData()
        }
        
        return Static.instance!
    }
    
    var onTheMap = [StudentInformation]()
    var personalInfo = PersonalInformation()
    
}

struct StudentInformation {
    var object_id: String? = nil
    var unique_key: String? = nil
    var first_name: String? = nil
    var last_name: String? = nil
    var map_string: String? = nil
    var media_url: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    init(dictionary: [String : AnyObject]) {
        object_id = dictionary["objectId"] as? String
        unique_key = dictionary["uniqueKey"] as? String
        first_name = dictionary["firstName"] as? String
        last_name = dictionary["lastMame"] as? String
        map_string = dictionary["mapString"] as? String
        media_url = dictionary["mediaURL"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
    }
    
    static func studentLocationsFromResults(results: [[String : AnyObject]], completionHandler: (Locations: [StudentInformation], lastIndex: Int?) -> Void) {
        
        //static func studentLocationsFromResults(results: [[String : AnyObject]]) -> ([StudentInformation], i: Int) {
        var studentLocations = [StudentInformation]()
        var i = 0
        
        /* Iterate through array of dictionaries; each Movie is a dictionary */
        for result in results {
            i = i + 1
            studentLocations.append(StudentInformation(dictionary: result))
        }
        completionHandler(Locations: studentLocations, lastIndex: i)
        //return (studentLocations, i)
    }
}

struct PersonalInformation {
    var locationPosted: Bool? = false
    var continuePosting: Bool? = false
    var place: String!
    var updated: Bool? = false
    
    var unique_key: String! = nil
    var object_id: String! = nil
    var location: String! = nil
    var first_name: String! = "Erwin"
    var last_name: String! = "Mazwardi"
    var media_url: String! = nil
    var latitude: Double! = nil
    var longitude: Double! = nil
    var email: String! = nil
    var request_session_id: String! = nil
    
}