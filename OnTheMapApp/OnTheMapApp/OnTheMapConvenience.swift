//
//  OnTheMapConvenience.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 2/09/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit
import Foundation

extension OnTheMapApi {
    
    func getSessionIdWithViewController(userid: String, password: String, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        /* Chain completion handlers for each request so that they run one after the other */
        if isConnectedToNetwork() == true {
            self.getSessionID(userid, thispassword: password) { (success, requestSessionID, errorString) in
                if success {
                    //println("requestToken: \(requestSessionID)")
                    self.otmData.personalInfo.request_session_id = requestSessionID
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: errorString)
                }
            }
        } else {
            completionHandler(success: false, errorString: "No network connection")
        }
    }
    
    func getLocationsWithViewController(studentNumbers: String, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        if isConnectedToNetwork() == true {
            /* Chain completion handlers for each request so that they run one after the other */
            let Method = OnTheMapApi.Methods.GetLocStudents
            let modMethod = Method.stringByReplacingOccurrencesOfString("number", withString: studentNumbers)
            //println(modMethod)
            self.getLocations(modMethod) { (success, errorString) in
                
                if success {
                    //println("GET LOCATIONS: SUCCESS")
                    completionHandler(success: true, errorString: nil)
                } else {
                    //println("GET LOCATIONS: ERROR")
                    completionHandler(success: false, errorString: errorString)
                }
            }
            
        } else {
            completionHandler(success: false, errorString: "No network connection")
        }
    }
    
    func queryLocationWithViewController(objectId: String?, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        if isConnectedToNetwork() == true {
            /* Use a unique_key when querying a location */
            //println("UNIQUE_ID \(self.appDelegate.personalInfo.unique_key)")
            let Method = OnTheMapApi.Methods.GetLocStudent
            let modMethod = Method.stringByReplacingOccurrencesOfString("unique_key", withString: "\(self.otmData.personalInfo.unique_key)")
            //let modMethod = Method.stringByReplacingOccurrencesOfString("unique_key", withString: "nil")
            //println(modMethod)
            self.queryLocation(modMethod) { (success, errorString) in
                if success {
                    //println("QUERY A LOCATION: FOUND A RECORD")
                    completionHandler(success: true, errorString: nil)
                } else {
                    //println("QUERY A LOCATION: NO RECORD WAS FOUND")
                    completionHandler(success: false, errorString: nil)
                }
            }
            
        } else {
            completionHandler(success: false, errorString: "No network connection")
        }
    }
    
    func postLocationWithViewController(methods: String?, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        if isConnectedToNetwork() == true {
            /* Chain completion handlers for each request so that they run one after the other */
            
            var modURL: String?
            
            if (methods == "PUT") {
                /* Use an object_id when updating a location */
                //println("UPDATE A LOCATION")
                let URL = OnTheMapApi.Constants.UpdateURL
                modURL = URL.stringByReplacingOccurrencesOfString("object_id", withString: self.otmData.personalInfo.object_id)
                //println(modURL)
            } else if methods == "POST" {
                //println("POST A LOCATION")
                modURL = OnTheMapApi.Constants.PostURL
            }
            
            self.postLocation(methods, url: modURL) { (success, errorString) in
                //OnTheMapApi.Methods.POST, url: OnTheMapApi.Constants.PostURL
                if success {
                    //println("POST A LOCATION: SUCCESS")
                    completionHandler(success: true, errorString: nil)
                } else {
                    //println("POST A LOCATION: ERROR")
                    completionHandler(success: false, errorString: errorString)
                }
            }
            
        } else {
            completionHandler(success: false, errorString: "No network connection")
        }
    }

    
    func queryLocation(method: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        var aStudentInfo = [StudentInformation]()
        
        if isConnectedToNetwork() == true {
            /* 2. Make the request */
            taskForGetMethod(method) { (JSONResult, error) in
                //println(JSONResult)
                /* 3. Send the desired value(s) to completion handler */
                let data = JSONResult.valueForKey(OnTheMapApi.JSONResponseKeys.Results) as? [[String:AnyObject]]
                StudentInformation.studentLocationsFromResults(data!) { (Locations, Index) in
                    if Index == 0 {
                        completionHandler(success: false, errorString: nil) /* A record not found */
                    } else {
                        self.otmData.personalInfo.object_id  = Locations[0].object_id
                        self.otmData.personalInfo.first_name = Locations[0].first_name
                        self.otmData.personalInfo.last_name  = Locations[0].last_name
                        self.otmData.personalInfo.media_url  = Locations[0].media_url
                        self.otmData.personalInfo.latitude   = Locations[0].latitude
                        self.otmData.personalInfo.longitude  = Locations[0].longitude
                        completionHandler(success: true, errorString: nil) /* A record found */
                    }
                }
            }
            
        } else {
            completionHandler(success: false, errorString: "No network connection")
        }
    }
    
    func deleteSession(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        /* Chain completion handlers for each request so that they run one after the other */
        if isConnectedToNetwork() == true {
            taskForLoggingOut() { (JSONResult, error) in
                if error != nil {
                    completionHandler(success: false, errorString: error)
                } else {
                    completionHandler(success: true, errorString: nil)
                }
            }
        } else {
            completionHandler(success: false, errorString: "No network connection")
        }
    }

    func getLocations(method: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* 2. Make the request */
        taskForGetMethod(method) { (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                //println("getLocations: Error")
                completionHandler(success: false, errorString: error)
            } else {
                let data = JSONResult.valueForKey(OnTheMapApi.JSONResponseKeys.Results) as? [[String:AnyObject]]
                StudentInformation.studentLocationsFromResults(data!) { (Locations, Index) in
                    if Index == 0 {
                        completionHandler(success: false, errorString: "A record not found") /* A record not found */
                    } else {
                        self.otmData.onTheMap = Locations
                        completionHandler(success: true, errorString: nil)
                    }
                }
                
                
            }
        }
    }
    
    func getSessionID(thisuserid: String, thispassword: String, completionHandler: (success: Bool, requestSessionId: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        
        /* 2. Make the request */
        taskForPostMethod(thisuserid, password: thispassword) { (JSONResult, error) in
            //println(JSONResult)
            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandler(success: false, requestSessionId: nil, errorString: error)
            } else {
                if let sessionDictionary = JSONResult.valueForKey(OnTheMapApi.JSONResponseKeys.Session) as? NSDictionary {
                    if let extractedID = sessionDictionary.valueForKey(OnTheMapApi.JSONResponseKeys.SessionId) as? String {
                        completionHandler(success: true, requestSessionId: extractedID, errorString: nil)
                    } else {
                        completionHandler(success: false, requestSessionId: nil, errorString: "Login Failed (SessionID not found).")
                    }
                    
                } else {
                    completionHandler(success: false, requestSessionId: nil, errorString: "Login Failed (Session not found).")
                }

            }
        }
    }
    
    func postLocation(methods: String?, url: String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
        //println("postLocation method")
        /* 2. Make the request */
        //taskForGetMethod(method) { (JSONResult, error) in
        taskForPostLocMethod(methods, url: url)  { (JSONResult, error) in
            /* 3. Send the desired value(s) to completion handler */
            completionHandler(success: true, errorString: nil)
            //println("postLocation method finish")
/*
            if error != nil {
                println("getLocations: Error")
                completionHandler(success: false, errorString: error)
            } else {
                println(JSONResult)
                completionHandler(success: true, errorString: nil)
                
            }
*/
        }
    }
    
    func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "http://google.com/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }

    
    
}
