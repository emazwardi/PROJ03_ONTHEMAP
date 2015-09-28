//
//  OnTheMapApi.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 1/09/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import Foundation
import UIKit

class OnTheMapApi : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    let otmData = OnTheMapData.sharedInstance
    
    //var appDelegate: AppDelegate!
    
    //var onTheMap = [StudentInformation]()
    //var personalInfo = PersonalInformation()
    
    
    override init() {
        //otmData = NSObject.sharedSession().delegate as! OnTheMapData
        session = NSURLSession.sharedSession()
        
        
        super.init()
    }
    
    

 
    
    func taskForGetMethod(method: String, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Build the URL */
        let urlString = method /* Assign the parameter to the local variable */
        let url = NSURL(string: urlString) /* Convert the string the URL string type */
        
        /* 2. Configure the request */
        let request = NSMutableURLRequest(URL: url!) /* Convert the URL string type to the URL request type */
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 3. Create a session */
        //let session = NSURLSession.sharedSession()
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            OnTheMapApi.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 5. Run the task */
        task.resume()
        
        return task
    }
    
    /* Post for Login */
    func taskForPostMethod(userid: String, password: String, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        /* 1. Configure a request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userid)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        /* 2. Create a session */
        //let session = NSURLSession.sharedSession()
        /* 3. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            OnTheMapApi.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* 4. Run the task */
        task.resume()
        return task
    }
    
    func taskForPostLocMethod(method: String?, url: String?, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        //println(self.otmData.personalInfo.first_name)
        //println(self.otmData.personalInfo.last_name)
        //println(self.otmData.personalInfo.object_id)
        //println(self.otmData.personalInfo.unique_key)
        //println(self.otmData.personalInfo.location)
        //println(self.otmData.personalInfo.latitude)
        //println(self.otmData.personalInfo.longitude)
        //println(url)
        /* 1. Configure a request */
        let request = NSMutableURLRequest(URL: NSURL(string: url!)!)
        request.HTTPMethod = method!
        //println(request)
        //println(request.HTTPMethod)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(self.otmData.personalInfo.unique_key)\", \"firstName\": \"\(self.otmData.personalInfo.first_name)\", \"lastName\": \"\(self.otmData.personalInfo.last_name)\",\"mapString\": \"\(self.otmData.personalInfo.location)\", \"mediaURL\": \"\(self.otmData.personalInfo.media_url)\",\"latitude\": \(self.otmData.personalInfo.latitude), \"longitude\": \(self.otmData.personalInfo.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
    
        /* 2. Create a session */
        let session = NSURLSession.sharedSession()
        
        /* 3. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            OnTheMapApi.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 4. Run the task */
        task.resume()
        
        return task
    }
    
    func taskForLoggingOut(completionHandler: (result: AnyObject!, error: String?) -> Void)  -> NSURLSessionDataTask  {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            OnTheMapApi.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[OnTheMapApi.JSONResponseKeys.ErrorMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: String?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary
        //println(parsedResult)
        //println(parsingError)
        if let errorStatus = parsedResult!.valueForKey("error") as? String {
            if (errorStatus == "Path not found") {
                completionHandler(result: nil, error: "Failure to connect")
            } else if (errorStatus == "Account not found or invalid credentials.") {
                completionHandler(result: nil, error: "Incorrect email or password.")
            } else if (errorStatus == "unauthorized") {
                completionHandler(result: nil, error: "Failure to download.")
            } else if (errorStatus == "method not allowed") {
                completionHandler(result: nil, error: "Failure to update.")
            } else if (errorStatus == "invalid JSON") {
                completionHandler(result: nil, error: "Failure to post.")
            }
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> OnTheMapApi {
        
        struct Singleton {
            static var sharedInstance = OnTheMapApi()
        }
        
        return Singleton.sharedInstance
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

    
}
