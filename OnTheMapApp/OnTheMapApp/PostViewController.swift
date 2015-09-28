//
//  PostViewController.swift
//  OnTheMapApp
//
//  Created by Erwin Mazwardi on 2/07/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    @IBOutlet weak var textView: UIView!
    let bottomTextField = UITextField(frame: CGRectMake(0.0, 0.0, 150.0, 50.0))
    
    let onMapTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
        NSStrokeWidthAttributeName : -3
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the bottom field text attrubutes
        bottomTextField.text = "BOTTOM"
        bottomTextField.restorationIdentifier = "bottom"
        bottomTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters;
        bottomTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.defaultTextAttributes = onMapTextAttributes
        self.bottomTextField.delegate = self
        // Display the textfields on top of the scroll view
        //textView.addSubview(bottomTextField)
        
        // Init the zoom level
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 34.03, longitude: 118.14)
        let span = MKCoordinateSpanMake(100, 80)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
    }

    // Back to Meme Editor
    @IBAction func startOver(sender: AnyObject) {
        var controller: UIViewController
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
/*
    @IBAction func findOnTheMap(sender: UIButton) {
        let submitController = self.storyboard!.instantiateViewControllerWithIdentifier("SubmitView") as! SubmitViewController
        //submitController.lat = 10.0
        //submitController.long = 15.0
        self.navigationController!.pushViewController(submitController, animated: true)
        
    }
*/

    // This function will called before performing a segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Select the intended segue
        if (segue.identifier == "SubmitViewSegue") {
            // Transferred the recorded audio file to the PlaySoundsViewController
            //let SubmitView:SubmitViewController = segue.destinationViewController as! SubmitViewController
                //SubmitView.lat = 10.0
                //SubmitView.long = 15.0
        }
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
    
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0] as! MKAnnotation
            self.mapView.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            if localSearchResponse == nil {
                var alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude:  localSearchResponse.boundingRegion.center.latitude,
                                                                     longitude: localSearchResponse.boundingRegion.center.longitude)
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation)
        }
    } // End of searchBarSearchButtonClicked function

    
    
}
