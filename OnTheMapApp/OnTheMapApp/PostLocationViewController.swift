//
//  InformationPostingViewController.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 9/08/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit
import MapKit
import AddressBook


class PostLocationViewController: UIViewController, UITextFieldDelegate {
    
    let otmSharedData = OnTheMapData.sharedInstance
    
    @IBOutlet var postView: UIView!
    @IBOutlet weak var question1: UILabel!
    @IBOutlet weak var question2: UILabel!
    @IBOutlet weak var question3: UILabel!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var locationTextView: UIView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var postingMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.submitButton.hidden = true
        self.postingMap.hidden = true
        self.linkTextField.hidden = true
        self.locationTextField.hidden = false
        self.firstNameTextField.hidden = true
        self.lastNameTextField.hidden = true
        self.findButton.layer.cornerRadius = 10
        self.submitButton.layer.cornerRadius = 10
        self.postView.backgroundColor = UIColor.yellowColor()
        self.linkTextField.delegate = self
        self.locationTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
    }
    
    //////////////////////////////////////////
    // Implement the textfiled delegate
    // 1. textField(shouldChangeCharactersInRange)
    // 2. textFieldShouldBeginEditing()
    // 3. textFieldDidBeginEditing()
    // 4. textFieldShouldReturn()
    //////////////////////////////////////////
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // If the textfield is selected, erase the default text
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    /* Cancel posting */
    @IBAction func cancelPostButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Find the location and display it on the map */
    @IBAction func findOnTheMapButton(sender: AnyObject) {
        let geoCoder = CLGeocoder()
        let addressString = locationTextField.text
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        geoCoder.geocodeAddressString(addressString, completionHandler:
            {(placemarks: [AnyObject]!, error: NSError!) in
                if error != nil {
                    //println("Geocode failed with error: \(error.localizedDescription)")
                    //self.appDlgt.personalInfo.updated = false
                    var alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                    alert.show()
                    return
                } else if placemarks.count > 0 {
                    //self.appDlgt.personalInfo.updated = true
                    let placemark = placemarks[0] as! CLPlacemark
                    let location = placemark.location
                    /* Save the coordinate into your personal info */
                    self.otmSharedData.personalInfo.latitude   = location.coordinate.latitude
                    self.otmSharedData.personalInfo.longitude  = location.coordinate.longitude
                    self.otmSharedData.personalInfo.location   = addressString
                    /* Change the state of some variables */
                    self.postView.backgroundColor = UIColor.yellowColor()
                    self.postingMap.hidden = false
                    self.linkTextField.hidden = false
                    if (self.otmSharedData.personalInfo.updated == false) {
                        self.firstNameTextField.hidden = true
                        self.lastNameTextField.hidden = true
                    } else {
                        self.firstNameTextField.hidden = true
                        self.lastNameTextField.hidden = true
                    }
                    self.submitButton.hidden = false
                    self.findButton.hidden = true
                    self.question1.hidden = true
                    self.question2.hidden = true
                    self.question3.hidden = true
                    self.locationTextField.hidden = true
                    /* Display the annotation on the map */
                    let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.05 , 0.05)
                    let coor2d:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(coor2d, theSpan)
                    self.postingMap.setRegion(theRegion, animated: true)
                    var anotation = MKPointAnnotation()
                    anotation.coordinate = coor2d
                    self.postingMap.addAnnotation(anotation)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
        }) /* End of geocoder task */
    }
    
    /* Posting or updating a student location */
    @IBAction func postStudentLocation(sender: AnyObject) {
        if ((linkTextField.text == "Enter a link to share") || (linkTextField.text.isEmpty == true)) {
            var alert = UIAlertView(title: nil, message: "The link is empty", delegate: self, cancelButtonTitle: "Try again")
            alert.show()
        } else {
            /* If a link is entered continue to this "else" block */            
            self.otmSharedData.personalInfo.media_url  = linkTextField.text
            //otmSharedData.personalInfo.first_name = firstNameTextField.text
            //otmSharedData.personalInfo.last_name = lastNameTextField.text
            self.sendRequest() /* Send the request */
        }
        
    } // End of postStudentLocation function

    /* Call postLocationWithViewController */
    func sendRequest() {
        if (otmSharedData.personalInfo.updated == false) {
            otmSharedData.personalInfo.updated = true
            /* Use POST for posting, because it doesn't require an object_key */
            OnTheMapApi.sharedInstance().postLocationWithViewController(OnTheMapApi.Methods.POST, hostViewController: self) { (success, errorString) in
                if success {
                    //println("SUCCESS POSTING")
                    self.otmSharedData.personalInfo.locationPosted = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.otmSharedData.personalInfo.locationPosted = false
                    var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                    alert.show()
                    return
                }
            }
        } else {
            /* Use UPDATE for updating, because it does require an object_key */
            OnTheMapApi.sharedInstance().postLocationWithViewController(OnTheMapApi.Methods.UPDATE, hostViewController: self) { (success, errorString) in
                if success {
                    //println("SUCCESS UPDATING")
                    self.otmSharedData.personalInfo.locationPosted = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.otmSharedData.personalInfo.locationPosted = false
                    var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                    alert.show()
                    return
                }
            }
        }
    }



}


