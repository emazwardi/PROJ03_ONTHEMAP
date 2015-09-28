//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Erwin Mazwardi on 13/06/2015.
//  Copyright (c) 2015 Socdesign. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var headerTextLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var signUp: UIButton!
    
    var session: NSURLSession!
    //let appDlgt = OnTheMapApi.sharedInstance().otmData
    
    let appDlgt = OnTheMapData.sharedInstance
    
    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* Based on student comments, this was added to help with smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        /* Configure the UI */
        self.configureUI()
        
        self.debugTextLabel.text = "Don't have an account?"
        self.signUp.hidden = false
        
        if self.appDlgt.personalInfo.request_session_id == nil {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.appDlgt.personalInfo.request_session_id == nil {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        }
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
    
    // MARK: - Login
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if emailTextField.text.isEmpty {
            /* Showing the aler view when email or password is not correct */
            var alert = UIAlertView(title: nil, message: "Email Empty.", delegate: self, cancelButtonTitle: "Try again")
            alert.show()
            //debugTextLabel.text = "Email Empty."
        } else if passwordTextField.text.isEmpty {
            /* Showing the aler view when email or password is not correct */
            var alert = UIAlertView(title: nil, message: "Password Empty.", delegate: self, cancelButtonTitle: "Try again")
            alert.show()
            //debugTextLabel.text = "Password Empty."
        } else {
            OnTheMapApi.sharedInstance().getSessionIdWithViewController(emailTextField.text, password: passwordTextField.text, hostViewController: self) { (success, errorString)  in
                if success {
                    self.appDlgt.personalInfo.unique_key = self.emailTextField.text /* Save the current email address to be used as a unique key */
                    //self.appDlgt.personalInfo.object_id = "9500"
                    if self.appDlgt.personalInfo.request_session_id != nil {
                        self.completeLogin()
                    } else {
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        var alert = UIAlertView(title: nil, message: "Please login again", delegate: self, cancelButtonTitle: "Try again")
                        alert.show()
                    }
                } else {
                    /* Showing the alert view when email or password is not correct */
                    var alert = UIAlertView(title: nil, message: errorString, delegate: self, cancelButtonTitle: "Try again")
                    alert.show()
                }
            }
        }
    }
    
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        let requestUrl = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.sharedApplication().openURL(requestUrl!)
    }
    
    /* Jump to mapView after login is successfull*/
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            self.performSegueWithIdentifier("MapSegue", sender: self)
        })
    }
    

    func viewAlert() {
        
        /* Create the AlertController */
        let alertController = UIAlertController(title: "Alert", message: "Account not found. Create a new account?", preferredStyle: UIAlertControllerStyle.Alert)
        /* Create the continue action */
        let continueAction: UIAlertAction = UIAlertAction(title: "Continue", style: .Default) { action -> Void in
            //let requestUrl = NSURL(string: "https://www.udacity.com/")
            //UIApplication.sharedApplication().openURL(requestUrl!)
        }
        alertController.addAction(continueAction)
        /* Create and add the Cancel action */
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            // Do some stuff
        }
        alertController.addAction(cancelAction)
        /* Present the alert controller */
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Helper

extension LoginViewController {
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.255, green: 0.127, blue: 0.000, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.255, green: 0.127, blue: 0.000, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        emailTextField.leftView = emailTextFieldPaddingView
        emailTextField.leftViewMode = .Always
        emailTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        emailTextField.backgroundColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        emailTextField.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        emailTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = .Always
        passwordTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        passwordTextField.backgroundColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        passwordTextField.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.tintColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        
        /* Configure debug text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        signUp.hidden = true
        
    }
}

/* This code has been added in response to student comments */
extension LoginViewController {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

