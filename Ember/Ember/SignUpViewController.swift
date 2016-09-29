//
//  SignUpViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/3/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging
import SwiftValidator

class SignUpViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,BWWalkthroughViewControllerDelegate, ValidationDelegate  {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var accountCreationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var schoolChoice: UITextField!
    
    @IBOutlet weak var backToSplashButton: UIButton!
    let adminOf : [String] = ["nil"]
    var email:String = ""
    var finalEmail:String = ""
    var initialSignIn:Bool = false
    var mypassword:String = ""
    var myusername:String = ""
    var schoolOptions = [String]()
    var validator:Validator!
    
    var ref:FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountCreationIndicator.hidesWhenStopped = true;
        accountCreationIndicator.hidden  = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        //Toolbar setup for school picker
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        schoolChoice.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.Default
        
        toolBar.tintColor = PRIMARY_APP_COLOR
        
        toolBar.backgroundColor = UIColor.whiteColor()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(SignUpViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        
        label.backgroundColor = UIColor.clearColor()
        
        label.textColor = PRIMARY_APP_COLOR
        
        label.text = "Pick your school"
        
        label.textAlignment = NSTextAlignment.Center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        schoolChoice.inputAccessoryView = toolBar
        
        ref = FIRDatabase.database().reference()
        
        let image = UIImage(named: "backDown") as UIImage?
        backToSplashButton.setImage(image, forState: UIControlState.Normal)
        backToSplashButton.titleEdgeInsets.left = 15
        
        
        //Set keyboard type
        self.emailAddress.keyboardType = UIKeyboardType.EmailAddress


        
        //populate schools
        let myQuery = self.ref.child("schools")
        myQuery.observeEventType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.schoolOptions.append(rest.value! as! String)
            }
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        validator = Validator()
        
        validator.registerField(firstName, errorLabel: fullNameLabel, rules: [RequiredRule(), FullNameRule()])
        validator.registerField(emailAddress, errorLabel: fullNameLabel, rules: [RequiredRule(),
            EmailRule(message:"Please provide a .edu email address")])
        validator.registerField(password, errorLabel: fullNameLabel, rules: [RequiredRule(), MinLengthRule(length: 6, message: "Passowrd must by at least 6 characters.")])
        validator.registerField(schoolChoice, errorLabel: fullNameLabel, rules: [RequiredRule()])
        
    }
    
    func validationSuccessful() {
        accountCreationIndicator.hidden = false
        //accountCreationIndicator.startAnimating()
        // submit the form
        //Ensure email is lowercase
        self.email = self.emailAddress.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.finalEmail = email.lowercaseString
        
        //Get full name and password
        self.mypassword = self.password.text!
        self.myusername = self.firstName.text!
        
        //Ensure email has the suffix .edu and uses valid characters
        if (finalEmail.hasSuffix(".edu") && finalEmail.isEmail && checkSchoolValidity(self.finalEmail, schoolSelection: self.schoolChoice.text!)) {
            
            if(!initialSignIn) {
                FIRAuth.auth()?.createUserWithEmail(self.finalEmail, password: mypassword, completion: {
                    user, error in
                    if  error != nil {
                        print(error!.localizedDescription)
                    }
                    else {
                        let changeRequest = user!.profileChangeRequest()
                        changeRequest.displayName = self.myusername
                        changeRequest.commitChangesWithCompletion { error in
                            if error != nil {
                                // An error happened.
                                print("error changing display name")
                            } else {
                                // Profile updated.
                            }
                        }
                        // [START basic_write]
                        let mySchool = self.schoolChoice.text!
                        NSUserDefaults.standardUserDefaults().setObject(mySchool, forKey: "FIREBASE_SCHOOL_ROOT")
                        FIREBASE_SCHOOL_ROOT = "/\(mySchool)/"
                        // [END basic_write]
                        self.sendVerificationEmail()
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setBool(false, forKey: "hasViewedOnBoarding")
                        self.logIn(self.finalEmail,logInPassword: self.mypassword)                   }
                })
                self.initialSignIn = true
            }
            else {
                self.logIn(self.finalEmail,logInPassword: self.mypassword)
            }
            
        }
        else {
            self.accountCreationIndicator.stopAnimating()
            // User needs to use .edu email address before continuing
            let alertController = UIAlertController(title: "Email address",
                                                    message: "Please use a matching .edu email address only",
                                                    preferredStyle: UIAlertControllerStyle.Alert
            )
            alertController.addAction(UIAlertAction(title: "Ok",
                style: UIAlertActionStyle.Default, handler: nil)
            )
            // Display alert
            self.presentViewController(alertController, animated: true, completion: nil)
        }


    }
    
    func validationFailed(errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.redColor().CGColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.hidden = false
        }
    }
    
    func editBorder() {
        
        //firstName.layer.borwerColor = UIColor.blackColor().CGColor
        //emailAddress.layer.border
        
        resetBorderColor(firstName)
        resetBorderColor(emailAddress)
        resetBorderColor(password)
        resetBorderColor(schoolChoice)
        fullNameLabel.layer.hidden = true
    }
    
    func resetBorderColor(textView: UITextField){
        var borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        textView.layer.borderColor = borderColor.CGColor
        textView.layer.borderWidth = 1.0;
        textView.layer.cornerRadius = 5.0;
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backToSplashPage(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func signUpButton(sender: AnyObject) {
        //Start Activity Indicator
        
        self.editBorder()
        self.validator.validate(self)
        
           }
    
    func logIn(logInEmail:String, logInPassword:String) {
        let myEmail = self.finalEmail
        let mySchool = self.schoolChoice.text!
        FIRAuth.auth()?.signInWithEmail(logInEmail, password: logInPassword, completion: {
            user,error in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                if (!user!.emailVerified) {
                    self.ref.child("users").child(user!.uid).setValue(["username": self.myusername, "email-address": myEmail, "adminOf":self.adminOf, "school": mySchool])
                    
                    self.accountCreationIndicator.stopAnimating()
                    // User needs to use .edu email address before continuing
                    let alertController = UIAlertController(title: "Email address Verification",
                        message: "Please check email to verify email address.",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )
                    alertController.addAction(UIAlertAction(title: "Ok",
                        style: UIAlertActionStyle.Default, handler: nil)
                    )
                    // Display alert
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else {
                    self.startOnboarding()
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true, forKey: "hasViewedOnBoarding")
                }
            
            }
            
        })
    }
    
    func startOnboarding() {
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("walk1")
        let page_two = stb.instantiateViewControllerWithIdentifier("walk2")
        let page_three = stb.instantiateViewControllerWithIdentifier("walk3")
        let page_four = stb.instantiateViewControllerWithIdentifier("walk4")
        let page_five = stb.instantiateViewControllerWithIdentifier("walk5")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        walkthrough.addViewController(page_four)
        walkthrough.addViewController(page_five)
        
        self.presentViewController(walkthrough, animated: true, completion: nil)
        self.accountCreationIndicator.stopAnimating()

    }
    func checkSchoolValidity(email:String, schoolSelection: String)->Bool {
        if (email.hasSuffix("vanderbilt.edu") && schoolSelection == "Vanderbilt University") {
            return true
        } else if (email.hasSuffix("davidson.edu") && schoolSelection == "Davidson College") {
            return true
        } else {
            return false
        }
    }
    
    
    func sendVerificationEmail() {
        FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion({ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Sent")
        })
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("signUpSegue", sender: nil)
    }
    
    func donePressed(sender: UIBarButtonItem) {
        if (!(schoolChoice.text?.isEmpty)!) {
             schoolChoice.resignFirstResponder()
        } else {
            schoolChoice.text = schoolOptions[0]
            schoolChoice.resignFirstResponder()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schoolOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schoolOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        schoolChoice.text = schoolOptions[row]
    }

    @IBAction func viewPolicy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://docs.google.com/document/d/188bf_bn_Mer_C8APTkEit-c0oMuxaSk5NGBxWekdy50/edit?usp=sharing")!)

    }
}
extension String {
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}



