//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Erwin Mazwardi on 20/06/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//



import UIKit
import MapKit

class MapViewController: UIViewController, UIApplicationDelegate, MKMapViewDelegate {
    
    @IBOutlet var myMap: MKMapView!
    

    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        myMap.delegate = self
        
        /* our span, witch will be the initial zoom level on our selected point 
           on the map once we open the app, in our case we will set this to 0.1 
           setting it to a higher value gives us a zoomed out view of our selected 
           point on the map */
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        /* the coordinates to our location on the map. our constant ” location ” is 
           of type CLLocationCoordinate2D and has the “x” latitude and “y” longitude */
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 45.612125, longitude: 22.948280)
        /* The region encompasses both the latitude and longitude point on which 
           the map is centered and the span of coordinates to display. ” -Apple , we set 
           this by declaring a new constant of type : MKCoordinateRegion and making a new 
           region using our location and our span */
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
        /* finally we are displaying our region to our myMap MapKit view  */
        myMap.setRegion(theRegion, animated: true)
        /* Now we create a annotation
           We are passing our location,  giving our annotation a Title and a Subtitle,
           an then displaying the annotation in myMap. */
        var anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = "The Location"
        anotation.subtitle = "This is the location !!!"
        myMap.addAnnotation(anotation)
        /* Now using the : UILongPressGestureRecognizer method, we will give the user 
           the possibility to add a annotation by long-pressing the screen. */
        //let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        //longPress.minimumPressDuration = 1.0
        //myMap.addGestureRecognizer(longPress)
        self.getStudentLocations()
    }
  /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Get the Application delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        // Point to the shared memes list
        students = appDelegate.onTheMap
    }
   */
    /* Our action ” action: ” will be a function in witch we will create the annotation. 
       Note the semicolon at the end of ” action: “, using this we tell our compiler that 
       our action function will be taking parameters. If our action is a function() that
       does not take any parameters then it’s absolutely ok to just use “action” without 
       the semicolon. */
    func action(gestureRecognizer:UIGestureRecognizer) {
        var touchPoint = gestureRecognizer.locationInView(self.myMap)
        var newCoord:CLLocationCoordinate2D = myMap.convertPoint(touchPoint, toCoordinateFromView: self.myMap)
        
        var newAnotation = MKPointAnnotation()
        newAnotation.coordinate = newCoord
        newAnotation.title = "New Location"
        newAnotation.subtitle = "New Subtitle"
        myMap.addAnnotation(newAnotation)
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
            
            var callOutButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            pinView!.rightCalloutAccessoryView = callOutButton
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView!
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        println("In calloutAccessoryControlTapped")
        
        if control == view.rightCalloutAccessoryView {
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("StudentDetailView") as! StudentDetailViewController
            //let object = UIApplication.sharedApplication().delegate
            //let appDelegate = object as! AppDelegate
            //detailController.student_url = appDelegate.onTheMap[0].media_url;
            self.navigationController!.pushViewController(detailController, animated: true)
        }
        
    }
    
   
    
    
 /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.memeDetail = self.memes[indexPath.row]
        detailController.table_row = indexPath.row
        self.navigationController!.pushViewController(detailController, animated: true)
    }
*/
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("TAPPING22")
    }
    /*
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        println("TAPPING")
    }
    
    

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("TAPPING11")
    }
     */
    func getStudentLocations() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            /* Parsing the data */
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            //println(parsedResult)
            
            //if let results = parsedResult["results"] as? [[String:AnyObject]] {
            if let results = parsedResult["results"] as? [[String:AnyObject]] {
                //println("RESULTS: \(results)")
                
                //if let aID = results["lastName"] as? String {
                //
               // }
                
                
                appDelegate.onTheMap = StudentInformation.studentLocationsFromResults(results)
               
               
                
                
                
                let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
                for students in appDelegate.onTheMap {
                    
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: students.latitude!, longitude: students.longitude!)
                    let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
                    self.myMap.setRegion(theRegion, animated: true)
                    var anotation = MKPointAnnotation()
                    anotation.coordinate = location
                    anotation.title = students.first_name
                    anotation.subtitle = students.map_string
                    self.myMap.addAnnotation(anotation)
                    
                }
                
                
                
            }
            
        
        }
        task.resume()
    }
    
    
    
}