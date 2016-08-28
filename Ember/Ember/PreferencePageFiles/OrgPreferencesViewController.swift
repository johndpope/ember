//
//  OrgPreferencesViewController.swift
//  bounceapp
//
//  Created by Michael Umenta on 8/2/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class OrgPreferencesViewController: UIViewController {
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var orgTagsView: UIView!
    var newTagListView:TagListView!
    var admins: [String] = []
    var adminOf: [String] = []
    var isEditingOrg:Bool = false
    var prefTags = [String]()
    var orgInterests = [String:Bool]()
    var orgId:String!
    var orgObject = [String:AnyObject]()
    var mainOrgTagsSet:Set<String> = Set([])
    var uid:String!
    var saveImage:UIImage?
    var saveCoverImage:UIImage?
    
    var ref:FIRDatabaseReference!
    var userRef:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        prefTags = []
        orgInterests = [:]
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tap(sender:UITapGestureRecognizer)
    {
        let label = (sender.view as! UILabel)
        let textToInsert = label.text!
        
        if(label.backgroundColor != UIColor.lightGrayColor()) {
            mainOrgTagsSet.insert(textToInsert)
            label.backgroundColor = UIColor.lightGrayColor()
        } else {
            mainOrgTagsSet.remove(textToInsert)
            label.backgroundColor = getRandomColor()
        }
    }

    
    @IBAction func preferencesDone(sender: AnyObject) {
        if let user = FIRAuth.auth()?.currentUser{
            if(!isEditingOrg){
                uid = user.uid
                admins.append(uid)
                orgObject["admins"] = admins
                orgObject["followers"] = [uid:true]
                userRef = ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(uid)
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    self.adminOf = snapshot.value!.objectForKey("adminOf") as! [String]
                    
                    let orgRef = self.ref.child(BounceConstants.firebaseSchoolRoot()).child(BounceConstants.firebaseUsersChild()).child(user.uid).child(BounceConstants.firebaseUsersChildOrgsFollowed()).child(self.orgId)
                    orgRef.setValue(true)
                    self.appendToAdminArray(self.orgId)
                    }, withCancelBlock: { error in
                        print(error.description)
                })
                uploadImage(self.saveImage!, isProfileImage: true)
                uploadImage(self.saveCoverImage!, isProfileImage: false)
                // value for smallImageLink is not ready at this time, so it is saved when it is ready in
                let orgRef = ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations")
                orgRef.child(self.orgId).setValue(self.orgObject)
            }
            else {
                if((self.saveImage) != nil){
                    uploadImage(self.saveImage!, isProfileImage: true)
                }
                if(self.saveCoverImage != nil){
                    uploadImage(self.saveCoverImage!, isProfileImage: false)
                }
                // value for smallImageLink is not ready at this time, so it is saved when it is ready in
                let orgRef = ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations")
                orgRef.child(self.orgId).updateChildValues(self.orgObject)
            }
            
            
            for item in mainOrgTagsSet {
                orgInterests[item] = true
            }
            
            let preferences = orgInterests
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations").child(orgId!).child("preferences").setValue(preferences)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else {
            
        }
    }
    
    
    
    @IBAction func doneAddingPreferences(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func getRandomColor() -> UIColor  {
        let randomNumber = Int(arc4random_uniform(5) + 1)
        let color:UIColor!
        if randomNumber == 1
        {
            color = UIColor(red: 238/255, green: 101/255, blue: 107/255, alpha: 1)
        }
        else if randomNumber == 2
        {
            color = UIColor(red: 96/255, green: 95/255, blue: 132/255, alpha: 1)
        }
        else if randomNumber == 3
        {
            color = UIColor(red: 85/255, green: 152/255, blue: 158/255, alpha: 1)
        }
        else
        {
            color = UIColor(red: 184/255, green: 205/255, blue: 158/255, alpha: 1)
        }
        return color
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Org Tags"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 25)!]
        
        // Do any additional setup after loading the view.
        newTagListView = TagListView(frame: CGRectMake(0, orgTagsView.frame.minY , orgTagsView.frame.size.width,orgTagsView.frame.size.height))
        self.view.addSubview(newTagListView)
        newTagListView.backgroundColor = UIColor.whiteColor()
        newTagListView.layer.borderColor = UIColor.whiteColor().CGColor
        newTagListView.layer.borderWidth = 0.2
        
        let orgTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("orgTags").queryLimitedToFirst(50)
        
        orgTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.prefTags.append(rest.value as! String)
            }
            
            for (index,i) in self.prefTags.enumerate()
            {
                let color:UIColor!
                
                if index%4 == 1
                {
                    color = UIColor(red: 238/255, green: 101/255, blue: 107/255, alpha: 1)
                }
                else if index%4 == 2
                {
                    color = UIColor(red: 96/255, green: 95/255, blue: 132/255, alpha: 1)
                }
                else if index%4 == 3
                {
                    color = UIColor(red: 85/255, green: 152/255, blue: 158/255, alpha: 1)
                }
                else
                {
                    color = UIColor(red: 184/255, green: 205/255, blue: 158/255, alpha: 1)
                }
                
                self.newTagListView.addTag(i, target: self, tapAction: #selector(EventPreferencesViewController.tap(_:)),backgroundColor: color,textColor: UIColor.whiteColor())
            }
        })
        loadingSpinner.stopAnimating()
        self.extendedLayoutIncludesOpaqueBars = false;
    }
    
    func appendToAdminArray(orgKey: String){
        if(adminOf[0] == "nil"){
            adminOf = []
        }
        adminOf.append(orgKey)
        userRef.updateChildValues(["adminOf": adminOf])
    }
    
    func uploadImage(image:UIImage, isProfileImage:Bool) {
        let currentDate = NSDate()
        let userCalendar = NSDateFormatter()
        userCalendar.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        let finalDate = userCalendar.stringFromDate(currentDate)
        
        var reference:String
        // Saves the profile picture and the cover photo in different locations.
        if(isProfileImage) {
           reference = "orgImages/\(self.orgId)/profile/\(finalDate)"
        }
        else {
            reference = "orgImages/\(self.orgId)/cover/\(finalDate)"
        }
        
        // Get a reference to the storage service, using the default Firebase App
        let storage = FIRStorage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.referenceForURL(FIREBASE_STORAGE_URL)
        
        // Create a reference to the file I want to save
        let imgRef = storageRef.child(reference)
        
        // Local file you want to upload
        let localFile: NSData = UIImageJPEGRepresentation(image, 1.0)!
        // Create the file metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        let uploadTask = storageRef.child(imgRef.fullPath).putData(localFile, metadata: metadata){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let orgImageLink = metaData!.downloadURL()!.absoluteString
                let orgRef = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations")
                // saves the image in a different location depending on if its a profile picture or cover photo
                if (isProfileImage) {
                    orgRef.child(self.orgId).child("smallImageLink").setValue(orgImageLink)
                }
                else {
                    orgRef.child(self.orgId).child("largeImageLink").setValue(orgImageLink)
                }
                
            }
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observeStatus(.Pause) { snapshot in
            // Upload paused
        }
        
        uploadTask.observeStatus(.Resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observeStatus(.Progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                _ = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            }
        }
        
        uploadTask.observeStatus(.Success) { snapshot in
            // Upload completed successfully
            print("Upload completed successfully")
        }
        
        // Errors only occur in the "Failure" case
        uploadTask.observeStatus(.Failure) { snapshot in
            guard let storageError = snapshot.error else { return }
            guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
            switch errorCode {
            case .ObjectNotFound:
                // File doesn't exist
                print("File doesn't exist")
            case .Unauthorized:
                // User doesn't have permission to access file
                print("User doesn't have permission to access file")
                
            case .Cancelled:
                // User canceled the upload
                print("User canceled the upload")
            //...
            case .Unknown:
                // Unknown error occurred, inspect the server response
                print("Unknown error occurred, inspect the server response")
            default:
                print("Honestly, no clue what's happening")
            }
        }
        
    }
    
}
