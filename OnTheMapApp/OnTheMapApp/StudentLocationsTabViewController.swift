//
//  StudentLocationsTabViewController.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 6/09/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationsTabViewController: UIViewController, UIApplicationDelegate, MKMapViewDelegate  {
    var count: Int! = 0
    var countLoc: Int! = 0
    @IBOutlet weak var locationsMap: MKMapView!
    
    let otmSharedData = OnTheMapData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationsMap.delegate = self
        getLocOfaStudent()
        getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        /* This code get executed only when there is a new location posted */
        if self.otmSharedData.personalInfo.locationPosted == true {
            /* Remove the old annotation */
            var oldAnnot: MKAnnotation!
            var annot = self.locationsMap.annotations.filter { $0.title == "Erwin" }
            self.locationsMap.removeAnnotations(annot)
            
            /* Display a new annotation on the map */
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.otmSharedData.personalInfo.latitude!, longitude: self.otmSharedData.personalInfo.longitude!) /* Set the coordinate */
            let viewRegion = MKCoordinateRegionMakeWithDistance(location, 5000000, 5000000)
            self.locationsMap.setRegion(viewRegion, animated: true)
            var anotation = MKPointAnnotation()
            anotation.coordinate = location
            anotation.title = self.otmSharedData.personalInfo.first_name
            anotation.subtitle = self.otmSharedData.personalInfo.media_url
            self.locationsMap.addAnnotation(anotation)
            
            /* Toggle the flag */
            self.otmSharedData.personalInfo.locationPosted = false
        }
    }
    
    /* Refresh the map */
    @IBAction func refreshButton(sender: AnyObject) {
        self.count = 0
        /* Remove the previous annotations */
        let annotationsToRemove = self.locationsMap.annotations.filter { $0 !== self.locationsMap.userLocation }
        self.locationsMap.removeAnnotations( annotationsToRemove )
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.otmSharedData.onTheMap[0].latitude!, longitude: self.otmSharedData.onTheMap[0].longitude!) /* Set the coordinate */
        let viewRegion = MKCoordinateRegionMakeWithDistance(location, 7000000, 7000000)
        self.locationsMap.setRegion(viewRegion, animated: false)
        
        /* Refresh the locations */
        getStudentLocations()
    }
    
    /* Post or update your location */
    @IBAction func postButton(sender: AnyObject) {
        if self.otmSharedData.personalInfo.updated  == false {
            /* No an existing record, jump directly to the Pos Controller */
            let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostingView") as! PostLocationViewController
            self.presentViewController(postVC, animated: true, completion: nil)
        } else {
            /* Found an existing record, ask a user confirmation before jumping to the Pos Controller */
            /* Create the AlertController */
            let alertController = UIAlertController(title: "Alert", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: UIAlertControllerStyle.Alert)
            let overwriteAction: UIAlertAction = UIAlertAction(title: "Overwrite", style: .Default) { action -> Void in
                let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostingView") as! PostLocationViewController
                self.presentViewController(postVC, animated: true, completion: nil)
            }
            alertController.addAction(overwriteAction)
            /* Create and add the Cancel action */
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in  }
            alertController.addAction(cancelAction)
            /* Present the alert controller */
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    /* Dissmis the view controller */
    @IBAction func logoutButton(sender: AnyObject) {
        OnTheMapApi.sharedInstance().deleteSession(self) { (success, errorString)  in
            if success {
                self.otmSharedData.personalInfo.request_session_id = nil
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                alert.show()
            }
        }
    }
    
    /* Configure and display a pin */
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        /* For the network busi indicator, hard coded to 100 */
/*
        self.count = self.count + 1
        println(self.count)
        if self.count == self.countLoc {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false /* Finish network busy indicator */
            self.count = 0
        }
*/
        /* Confugure the pin */
        if annotation is MKUserLocation {
            //println("MKUserLocation")
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if (pinView == nil) {
            //println("PINVIEW NILL")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
            var callOutButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            pinView!.rightCalloutAccessoryView = callOutButton
        } else {
            //println("PINVIEW NOT NILL")
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    /* Display the student url in the default browser */
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        //println("calloutAccessoryControlTapped")
        let url1: NSString!
        url1 = view.annotation.subtitle /* Must be converted to NSString first */
        let requestUrl = NSURL(string: "\(url1)") /* Then translate to NSURL string */
        /* Open the student url if the information is selected */
        if control == view.rightCalloutAccessoryView {
            UIApplication.sharedApplication().openURL(requestUrl!)
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        //println("didSelectAnnotationView")
    }

    
    /* Query a location of a student */
    func getLocOfaStudent() {
        /* Use the object_id from the personal record */
        OnTheMapApi.sharedInstance().queryLocationWithViewController(self.otmSharedData.personalInfo.object_id, hostViewController: self) { (success, errorString) in
            if success {
                //println("getLocOfaStudent: SUCCEES")
                self.otmSharedData.personalInfo.updated = true /* A flag stating that an existing record found. Updating later. */
            } else {
                //println("getLocOfaStudent: FAIL")
                self.otmSharedData.personalInfo.updated = false /* A flag stating that no existing record found. Posting later. */
                //var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                //alert.show()
            }
        }        
    }
    
    func getStudentLocations() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true /* Start network busy indicator */
        OnTheMapApi.sharedInstance().getLocationsWithViewController("100", hostViewController: self) { (success, errorString) in
            if success {
                self.countLoc = 0
                for students in self.otmSharedData.onTheMap {
                    self.countLoc = self.countLoc + 1
                   /* Go to the region */
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: students.latitude!, longitude: students.longitude!) /* Set the coordinate */
                    /* Add annotation */
                    var anotation = MKPointAnnotation()
                    anotation.coordinate = location
                    anotation.title = students.first_name
                    anotation.subtitle = students.media_url
                    //println(self.countLoc)
                    /* Place the annotation */
                    self.locationsMap.addAnnotation(anotation)
                } /* End of for students loop */
                /* Zoom the map 8000km around the latest updated */
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.otmSharedData.onTheMap[0].latitude!, longitude: self.otmSharedData.onTheMap[0].longitude!) /* Set the coordinate */
                let viewRegion = MKCoordinateRegionMakeWithDistance(location, 8000000, 8000000)
                self.locationsMap.setRegion(viewRegion, animated: true)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                //println("NUMBER OF LOCATIONS: \(self.countLoc)")
            } else {
                /* Error downloading student locations */
                var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                alert.show()
            }
        }
    }
}