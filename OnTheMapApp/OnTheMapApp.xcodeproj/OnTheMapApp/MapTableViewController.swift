//
//  MapTableViewController.swift
//  OnTheMap
//
//  Created by Erwin Mazwardi on 24/06/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit

class MapTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIApplicationDelegate {
    
    // Declare a variable which has a type of memeModel array.
    @IBOutlet weak var tableView: UITableView!
    
    var studentsOnTheMap = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Get the shared memes list
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Get the Application delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        // Point to the shared memes list
        studentsOnTheMap = appDelegate.onTheMap
        //println(studentsOnTheMap[0].first_name)
        //println("TABLE VIEW")
    }
    // Back to Meme Editor
   // @IBAction func startOver(sender: AnyObject) {
   //     var controller: UIViewController
   //     controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditor") as! UIViewController
    //    self.presentViewController(controller, animated: true, completion: nil)
    //}
    
    //override func viewDidAppear(animated: Bool) {
    //     self.dismissViewControllerAnimated(true, completion: nil)
    //}
    
    //////////////////////////////////////////
    // Implement the table view delegate
    // 1. tableView(numberOfRowsInSection)
    // 2. tableView(cellForRowAtIndexPath)
    // 3. tableView(didSelectRowAtIndexPath)
    //////////////////////////////////////////
    // Count the row numbers
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println(self.studentsOnTheMap.count)
        return self.studentsOnTheMap.count
    }
    // Create a cell view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as! UITableViewCell
        let student = self.studentsOnTheMap[indexPath.row]
        //println(student.first_name)
        cell.textLabel?.text = student.first_name
        //cell.imageView?.image = memed.memedImage
        return cell
    }
    // Display a selected row in another view
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.memeDetail = self.memes[indexPath.row]
        detailController.table_row = indexPath.row
        self.navigationController!.pushViewController(detailController, animated: true)
        */
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        println("You select a cell")
    }

    
}
