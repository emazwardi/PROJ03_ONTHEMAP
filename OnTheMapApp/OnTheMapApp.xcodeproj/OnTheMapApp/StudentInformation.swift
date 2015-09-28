//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Erwin Mazwardi on 21/06/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//


import UIKit

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
    
    static func studentLocationsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        
        var studentLocations = [StudentInformation]()
        
        
        /* Iterate through array of dictionaries; each Movie is a dictionary */
        //println(results[0])
        for result in results {
            //println(result)
            
            studentLocations.append(StudentInformation(dictionary: result))
        }
        //println("\(studentLocations[1].firstName)")
        return studentLocations
    }
    
}

