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

class EditOrgViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref:FIRDatabaseReference!
    var isOrgNameDuplicate:Bool = false
    var isProfilePicture:Bool = true
    var orgId:String = ""
    var key:String!
    var orgObject = [String: AnyObject]()
    var smallImageLink:String!
    var imagePicker = UIImagePickerController()
    var saveImage:UIImage?
    var saveCoverImage:UIImage?
    
    
    @IBOutlet weak var previewCoverImage: UIImageView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var campName: UITextField!
    @IBOutlet weak var campDesc: UITextView!
    @IBOutlet weak var orgPictureButton: UIButton!
    @IBOutlet weak var orgCoverPictureButton: UIButton!
    
    
    @IBAction func saveOrganization(sender: AnyObject) {
        key = ref.childByAutoId().key
        if (FIRAuth.auth()?.currentUser) != nil{
            orgObject["orgName"] = campName.text
            orgObject["orgDesc"] = campDesc.text
            checkOrgNameDuplicates(orgObject["orgName"]! as! String)
        }else{
            print("User is not signed in, please do so")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "editOrgPreferences") {
            let orgPreferencesViewController = (segue.destinationViewController as! OrgPreferencesViewController)
            orgPreferencesViewController.orgId = self.orgId
            orgPreferencesViewController.orgObject = self.orgObject
            orgPreferencesViewController.saveImage = self.saveImage
            orgPreferencesViewController.saveCoverImage = self.saveCoverImage
            orgPreferencesViewController.isEditingOrg = true
        }
    }
    
    func checkOrgNameDuplicates(orgName: String) {
        ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations")
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                for org in snapshot.children.allObjects {
                    if (orgName == (org.value["orgName"] as! String) && String(org.key) != self.orgId) {
                        print(String(org.key))
                        self.isOrgNameDuplicate = true
                        break
                    }
                }
                if(!self.isOrgNameDuplicate) {
                    self.performSegueWithIdentifier("editOrgPreferences", sender: nil)
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
        isProfilePicture = true
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func saveOrgCoverPicture(sender: AnyObject) {
        isProfilePicture = false
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        self.navigationController!.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if (isProfilePicture) {
                previewImage.contentMode = .ScaleAspectFit
                previewImage.image = pickedImage
                self.saveImage = pickedImage
            }
            else {
                previewCoverImage.contentMode = .ScaleAspectFit
                previewCoverImage.image = pickedImage
                self.saveCoverImage = pickedImage
            }
            
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
        
        ref = FIRDatabase.database().reference()
        let orgsQuery = ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations").child(self.orgId)
        orgsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            print(snapshot.value!["orgName"])
            self.campName.text = snapshot.value!["orgName"] as? String
            self.campDesc.text = snapshot.value!["orgDesc"] as! String
            
            let profileUrl = NSURL(string: snapshot.value!["smallImageLink"] as! String)
            let coverUrl = NSURL(string: snapshot.value!["largeImageLink"] as! String)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let profileData = NSData(contentsOfURL: profileUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                let coverData = NSData(contentsOfURL: coverUrl!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.saveImage = UIImage(data: profileData!)
                    self.previewImage.image = UIImage(data: profileData!)
                    
                    self.saveCoverImage = UIImage(data: coverData!)
                    self.previewCoverImage.image = UIImage(data: coverData!)
                });
            }
        })
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Edit Org"
    }
    
    
}
