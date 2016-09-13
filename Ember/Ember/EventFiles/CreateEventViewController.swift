//
//  CreateEventViewController.swift
//  bounce
//
//  Created by Michael Umenta on 6/1/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import Firebase

class CreateEventViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref:FIRDatabaseReference!
    var imagePicker = UIImagePickerController()
    var finalEventDateFormat: String = ""
    var finalEventStartTimeFormat: String = ""
    var saveImage:UIImage?
    var eventImageLink:String = ""
    var eventDateObject = NSDate()
    
    
    //segue variables
    var eventsKeyToPass = ""
    var homefeedKeyToPass = ""
    var eventsegDate = ""
    var eventsegTime = ""
    var eventsegName = ""
    var eventSegDesc = ""
    var eventsegLocation = ""
    var eventsegOrgID = ""
    var eventsegOrgName = ""
    var imagesegLink  = ""
    var segOrgID = ""
    var segOrgName = ""
    var segProfileImage = ""
    var segEventDateObject = NSDate()
    var segPosterImage:UIImage!
    
    
    
    
    
    //---------------To be initialized at declaration
    var orgID: String = ""
    var orgName: String = ""
    var orgProfileImage: String = ""
    
    
 

    @IBOutlet weak var eventName: UITextField!
    let eventNameLimitLength = 30

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var eventDesc: UITextView!
    @IBOutlet weak var posterButton: UIButton!
   
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        eventName.delegate = self
        locationText.delegate = self
        
        //.Done 
        eventName.returnKeyType = UIReturnKeyType.Done
        locationText.returnKeyType = UIReturnKeyType.Done

        
        imagePicker.delegate = self
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.Default
        
        toolBar.tintColor = PRIMARY_APP_COLOR
        
        toolBar.backgroundColor = UIColor.whiteColor()

        let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventViewController.tappedToolBarBtn))
        let okBarBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
        
        label.backgroundColor = UIColor.clearColor()
        
        label.textColor = PRIMARY_APP_COLOR
        
        label.text = "When?"
        
        label.textAlignment = NSTextAlignment.Center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        
        dateTextField.inputAccessoryView = toolBar
        
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "picture") as UIImage?
        posterButton.setImage(image, forState: UIControlState.Normal)
        posterButton.titleEdgeInsets.left = 15
    }
    
    //Return to dismiss first repsonder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        eventName.resignFirstResponder()
        locationText.resignFirstResponder()
        return true
    }
  
    @IBAction func saveEvent(sender: AnyObject) {
        
        if ((self.saveImage) != nil) {
        let desc = eventDesc.text
        let name = eventName.text
        let location = locationText.text
        print(desc.characters.count)
        
        
        if name != "" && !(desc.isEmpty) &&
            
            location != ""  {
            
            //Assign information to be passed
            self.eventsegDate = finalEventDateFormat
            self.eventsegTime = finalEventStartTimeFormat
            self.eventsegName = name!
            self.eventsegLocation = location!
            self.eventsegOrgID = self.orgID
            self.eventsegOrgName = self.orgName
            self.eventSegDesc = desc
            self.imagesegLink  = self.eventImageLink
            self.segOrgID = self.orgID
            self.segOrgName = self.orgName
            self.segProfileImage = self.orgProfileImage
            self.segEventDateObject = self.eventDateObject
            self.segPosterImage = self.saveImage
            
            //Post to events Tree
            let eventsTreekey = ref.childByAutoId().key
            self.eventsKeyToPass = eventsTreekey
            //Post as homefeed item
            let homeFeedEntryKey = ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").childByAutoId().key
            self.homefeedKeyToPass = homeFeedEntryKey
            
            //self.navigationController?.popViewControllerAnimated(true)
            performSegueWithIdentifier("finalEventTagsSegue", sender: nil)
            
        } else {
            let alertController = UIAlertController(title: "Hi :)", message:
                "Please fill in all the fields before creating an event.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        } else {
            let alertController = UIAlertController(title: "Hi :)", message:
                "Please upload a poster or image for your event.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func posterAdd(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            previewImage.contentMode = .ScaleAspectFit
            previewImage.image = pickedImage
            self.saveImage = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
 
    
    

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= eventNameLimitLength
    }
    
    @IBAction func textFieldEditing(sender: UITextField) {
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.timeZone = NSTimeZone.localTimeZone()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(CreateEventViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }

    func donePressed(sender: UIBarButtonItem) {
        
        dateTextField.resignFirstResponder()
        
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        dateformatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateformatter.timeZone = NSTimeZone.localTimeZone()

        
        dateTextField.text = dateformatter.stringFromDate(NSDate())
        dateTextField.resignFirstResponder()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func datePickerValueChanged(sender: UIDatePicker) {
//        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.calendar = NSCalendar.currentCalendar()
        

        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        
        //Save NSDate object
        eventDateObject = (sender.date)
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        finalEventDateFormat = dateFormatter.stringFromDate(sender.date)
        
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        finalEventStartTimeFormat = dateFormatter.stringFromDate(sender.date)
        
    }
    
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        //establishNavBar()
        ref = FIRDatabase.database().reference()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "finalEventTagsSegue" {
            if let destination = segue.destinationViewController as? EventPreferencesViewController {
                destination.eventsKeyToPass = self.eventsKeyToPass
                destination.homefeedKeyToPass = self.homefeedKeyToPass
                destination.eventsegDate = self.eventsegDate
                destination.eventsegTime = self.eventsegTime
                destination.eventsegName = self.eventsegName
                destination.eventSegDesc = self.eventSegDesc
                destination.eventsegLocation = self.eventsegLocation
                destination.eventsegOrgID = self.eventsegOrgID
                destination.eventsegOrgName = self.eventsegOrgName
                destination.imagesegLink  = self.imagesegLink
                destination.segOrgID = self.segOrgID
                destination.segOrgName = self.segOrgName
                destination.segProfileImage = self.segProfileImage
                destination.segEventDateObject = self.segEventDateObject
                destination.segPosterImage = self.segPosterImage
            }
        }
    }
    
    
}
