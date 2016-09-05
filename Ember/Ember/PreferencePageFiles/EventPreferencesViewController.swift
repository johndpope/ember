//
//  EventPreferencesViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 8/2/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth

class EventPreferencesViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventTagsView: UIView!
    @IBOutlet weak var tagsIndicator: UIActivityIndicatorView!
    var newTagListView:TagListView!
    var prefTags = [String]()
    var individualInterests = [String]()
    
    var mainSet:Set<String> = Set([])
    
    
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
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        prefTags = []
        
        individualInterests = []
        tagsIndicator.hidesWhenStopped = true
        tagsIndicator.startAnimating()
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
            mainSet.insert(textToInsert)
            label.backgroundColor = UIColor.lightGrayColor()
        } else {
            
            mainSet.remove(textToInsert)
            label.backgroundColor = getRandomColor()
        }
    }
 
    @IBAction func doneCreatingEvent(sender: AnyObject) {
        
        let evTags = Array(self.mainSet)
        //Post to events Tree
        let eventsTreekey = ref.childByAutoId().key
        let eventsRefChild = ref.child(BounceConstants.firebaseSchoolRoot()).child("Events")
        
        //Get current user UID
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // Get a reference to the storage service, using the default Firebase App
        let storage = FIRStorage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.referenceForURL(FIREBASE_STORAGE_URL)
        
        let currentDate = NSDate()
        let userCalendar = NSDateFormatter()
        userCalendar.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        let finalDate = userCalendar.stringFromDate(currentDate)
        
        let reference = "posters/\(self.eventsegOrgID)/\(finalDate)"
        self.imagesegLink = reference
        
        //get poster file
        let image = self.segPosterImage
        
        // Create a reference to the file I want to save
        let imgRef = storageRef.child(reference)
        
        // Local file you want to upload
        let localFile: NSData = UIImageJPEGRepresentation(image, 0.9)!
        // Create the file metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        let uploadTask = storageRef.child(imgRef.fullPath).putData(localFile, metadata: metadata);
        
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
            // Create a reference to the file I want to save
            let posterRef = storageRef.child(self.imagesegLink)
            
            //fertch full poster URL
            posterRef.downloadURLWithCompletion { (URL, error) -> Void in
                if (error != nil) {
                    // Handle any errors
                    print(error)
                } else {
                    //get timeStamp
                    let startRef = NSDate()
                    let timeStamp = -(startRef.timeIntervalSince1970)
                    
                    //get eventDateObject
                    let eventDateObject = -(self.segEventDateObject.timeIntervalSince1970)
                    
                    //Ref to events followed
                    let eventsFollowedRefChild = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(userID!).child("eventsFollowed")
                    
                    
                    
                    //Post as homefeed item
                    let homeFeedEntryKey = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").childByAutoId().key
                    let homeFeedRefChild = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed")
                    
                    //Get homefeedMedia key
                    let homeFeedMediaKey = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").childByAutoId().key
                    
                    let homefeedItem = ["eventDate":self.eventsegDate,"eventID": eventsTreekey, "eventName": self.eventsegName,"eventPosterLink":(URL?.absoluteString)!,"eventTime":self.eventsegTime,"eventDateObject":eventDateObject,"orgID":self.eventsegOrgID,"orgProfileImage":self.segProfileImage,"eventTags":evTags]
                    
                    let eventItem = ["eventDate":self.eventsegDate,"eventName": self.eventsegName, "eventDesc": self.eventSegDesc,"eventLocation":self.eventsegLocation,"eventTime":self.eventsegTime,"orgID":self.eventsegOrgID,"orgName":self.eventsegOrgName,"eventImageLink":(URL?.absoluteString)!, "eventTags":evTags,"orgProfileImage":self.segProfileImage,"homeFeedMediaKey":homeFeedMediaKey,"homefeedPostKey":homeFeedEntryKey,"timeStamp":timeStamp,"eventDateObject":eventDateObject]
                    
                    //Upload Poster
                    //self.uploadImage(self.segPosterImage)
                    
                    
                    //post to Firebase
                    eventsRefChild.child(eventsTreekey).setValue(eventItem)
                    homeFeedRefChild.child(homeFeedEntryKey).child("postDetails").setValue(homefeedItem)
                    homeFeedRefChild.child(homeFeedEntryKey).updateChildValues(["fireCount":1])
                    homeFeedRefChild.child(homeFeedEntryKey).updateChildValues(["timeStamp":timeStamp])
                    
                    //Add to events Followed
                    eventsFollowedRefChild.updateChildValues([homeFeedEntryKey:true])
                    
                    //Get list of tags
                    let orgTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations").child(self.eventsegOrgID).child("preferences")
                    orgTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
                        for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {                        homeFeedRefChild.child(homeFeedEntryKey).child("orgTags").updateChildValues([rest.key:true])
                        }
                    })
                }
            }
            
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
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Tags"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont.systemFontOfSize(25, weight: UIFontWeightThin)]
        
        // Do any additional setup after loading the view.
        tagsIndicator.stopAnimating()
        newTagListView = TagListView(frame: CGRectMake(0, eventTagsView.frame.minY , eventTagsView.frame.size.width,eventTagsView.frame.size.height))
        self.view.addSubview(newTagListView)
        newTagListView.backgroundColor = UIColor.whiteColor()
        newTagListView.layer.borderColor = UIColor.whiteColor().CGColor
        newTagListView.layer.borderWidth = 0.2
        
        let eventTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("eventTags").queryLimitedToFirst(50)
        
        eventTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
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
        self.extendedLayoutIncludesOpaqueBars = false;        
        
    }
    
    //Method to ensure you have deselected.
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


}
