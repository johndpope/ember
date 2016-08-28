//
//  CreateEventViewController.swift
//  bounce
//
//  Created by Michael Umenta on 6/1/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateOrgViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref:FIRDatabaseReference!
    var isOrgNameDuplicate:Bool = false
    var key:String!
    var orgObject = [String: AnyObject]()
    var smallImageLink:String!
    var imagePicker = UIImagePickerController()
    var saveImage:UIImage?
    var placeholderCoverPhoto: String = "https://firebasestorage.googleapis.com/v0/b/bounce-46de5.appspot.com/o/orgImages%2F-KOhTswa4BbI95AjOyce%2F2016-08-08%2009%3A07%3A11%20-0700?alt=media&token=28f65109-efb2-443d-958c-3e54f7931c3e"
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var campName: UITextField!
    @IBOutlet weak var campDesc: UITextView!
    @IBOutlet weak var orgPictureButton: UIButton!
    @IBOutlet weak var orgCoverPictureButton: UIButton!
    
    
    @IBAction func saveOrganization(sender: AnyObject) {
        key = ref.childByAutoId().key
        if (FIRAuth.auth()?.currentUser) != nil{
            orgObject["largeImageLink"] = self.placeholderCoverPhoto
            orgObject["orgName"] = campName.text
            orgObject["orgDesc"] = campDesc.text
            orgObject["smallImageLink"] = ""
            checkOrgNameDuplicates(orgObject["orgName"]! as! String)
        }else{
            print("User is not signed in, please do so")
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "gotoOrgPreferences") {
            let orgPreferencesViewController = (segue.destinationViewController as! OrgPreferencesViewController)
            orgPreferencesViewController.orgId = self.key
            orgPreferencesViewController.orgObject = self.orgObject
            orgPreferencesViewController.saveImage = self.saveImage
        }
    }
    
    func checkOrgNameDuplicates(orgName: String) {
        ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                for org in snapshot.children.allObjects {
                    if (orgName == (org.value["orgName"] as! String)) {
                        self.isOrgNameDuplicate = true
                        break
                    }
                }
                if(!self.isOrgNameDuplicate) {
                   self.performSegueWithIdentifier("gotoOrgPreferences", sender: nil)
                }
                else {
                    // User needs to use .edu email address before continuing
                    let alertController = UIAlertController(title: "Organization Name Taken",
                        message: "The name of the organization has been taken, please select an alternate" +
                        " organization name.",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Default, handler: nil)
                    )
                    // Reset the value of isOrgNameDuplicate, and display alert
                    self.isOrgNameDuplicate = false
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                }, withCancelBlock: { error in
                    print(error.description)
        })
    }
   
    
    
    @IBAction func saveOrgProfilePicture(sender: AnyObject) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        
         // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "picture") as UIImage?
        orgPictureButton.setImage(image, forState: UIControlState.Normal)
        orgPictureButton.titleEdgeInsets.left = 15
        
        orgCoverPictureButton.setImage(image, forState: UIControlState.Normal)
        orgCoverPictureButton.titleEdgeInsets.left = 15
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        navigationItem.title = "Create Org"
    }
    
    
}
