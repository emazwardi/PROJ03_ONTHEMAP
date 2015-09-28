//
//  MapTableViewController.swift
//  OnTheMap
//
//  Created by Erwin Mazwardi on 24/06/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIApplicationDelegate {
    @IBOutlet weak var tableView: UITableView! /* Declare a variable which has a type of memeModel array */
    var studentsOnTheMap = [StudentInformation]() /* Create a handle to the studentsOnTheMap */
    var postedLocation: Bool? = false
    let otmSharedData = OnTheMapData.sharedInstance
    
    @IBOutlet weak var appsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        studentsOnTheMap = self.otmSharedData.onTheMap /* Point to the shared memes list */
    }
    
    //////////////////////////////////////////
    // Implement the table view delegate
    // 1. tableView(numberOfRowsInSection)
    // 2. tableView(cellForRowAtIndexPath)
    // 3. tableView(didSelectRowAtIndexPath)
    //////////////////////////////////////////
    
    /* Count the row numbers */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("TABLE VIEW 1")
        return self.studentsOnTheMap.count
    }
    
    /* Create a cell view */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //println("TABLE VIEW 2")
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as! UITableViewCell
        let student = self.studentsOnTheMap[indexPath.row] /* Get the selected row info */
        cell.imageView?.image = UIImage(named:"place") /* Display the image */
        cell.textLabel?.text = student.first_name /* Display the first name */
        return cell
    }
    
    /* Responses to a selected row */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //println("TABLE VIEW 3")
        /* Show the student media_url */
        let url1: NSString!
        let student = self.studentsOnTheMap[indexPath.row] /* Get the selected row info */
        url1 = student.media_url /* Must be converted to NSString first */
        let requestUrl = NSURL(string: "\(url1)") /* Then translate to NSURL string */
        UIApplication.sharedApplication().openURL(requestUrl!) /* Open the student url if the information is selected */
    }
    
    /* Logout */
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
    
    /* Refresh the table list */
    @IBAction func refreshList(sender: AnyObject) {
        //println("REFRESH THE LIST")
        self.updateStudentLocations()
    }
    
    /* Get 100 locations */
    func updateStudentLocations() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        OnTheMapApi.sharedInstance().getLocationsWithViewController("100", hostViewController: self) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.appsTableView.reloadData() /* Refresh the table */
                })
            } else {
                var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                alert.show()
            }
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    /* Post or update your location */
    @IBAction func postLocation(sender: AnyObject) {
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

}



