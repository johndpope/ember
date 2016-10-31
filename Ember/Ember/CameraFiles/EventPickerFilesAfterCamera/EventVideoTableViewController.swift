//
//  EventVideoTableViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 7/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth


@objc class EventVideoTableViewController: UITableViewController {

    // MARK: - Properties
    var ref = FIRDatabaseReference()
    var events : [FIRDataSnapshot] = []
    var detectedEvents : [FIRDataSnapshot] = []
    var  videoURL:String
    var videoNSURL:NSURL
    var mEventDate: String
    var mEventName:String
    var mEventTime:String
    var mMediaLink:String
    var mOrgID:String
    var mUserID:String
    var mVidCaption:String?
    var orgProfImage: String
    var eventDateObject:NSNumber
    var mEventID:String


    
    
    init (finalAddress: String,myNSURL:NSURL,myVidCap:NSString) {
        self.mEventID = ""
        self.mEventDate = ""
        self.mEventName = ""
        self.mEventTime = ""
        self.mMediaLink = ""
        self.mOrgID = ""
        self.mUserID = ""
        self.videoURL = finalAddress
        self.videoNSURL = myNSURL
        self.orgProfImage = ""
        self.eventDateObject = 0
        self.mVidCaption = myVidCap as String
        super.init(nibName:nil,bundle:nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.navigationController?.navigationBar.topItem?.title = "Pick an Event..."
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor(red:90.0/255.0, green: 187.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont.systemFontOfSize(25, weight: UIFontWeightThin)]
        
        let infoImage = UIImage(named: "acceptMedia")
        let imgWidth = infoImage?.size.width
        let imgHeight = infoImage?.size.height
        let button:UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: imgWidth!, height: imgHeight!))
        button.setBackgroundImage(infoImage, forState: .Normal)
        button.addTarget(self, action: #selector(doAll), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: button),animated: true)
        
        
        let cancelImage = UIImage(named: "cancelMedia")
        let canWidth = cancelImage?.size.width
        let canHeight = cancelImage?.size.height
        let canButton:UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: canWidth!, height: canHeight!))
        canButton.setBackgroundImage(cancelImage, forState: .Normal)
        canButton.addTarget(self, action: #selector(cancelTapped), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: canButton),animated: true)
        

        self.ref = FIRDatabase.database().reference()
        getData()
        self.tableView.registerNib(UINib.init(nibName: "cell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    func cancelTapped() {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func doAll() {
        saveTapped({ (finalSend) in
            if finalSend {
                FIRCrashMessage("Video upload and database saving complete")
            } else  {
                FIRCrashMessage("Video upload and database saving failed")
            }
        })
    }
    
    func saveTapped(completion : (Bool) ->()) {
        if !(mEventName.isEmpty) {
            
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            
            // Get a reference to the storage service, using the default Firebase App
            let storage = FIRStorage.storage()
            
            // Create a storage reference from our storage service
            let storageRef = storage.referenceForURL(FIREBASE_STORAGE_URL)
            
            
            // Create a reference to the file I want to save
            let vidRef = storageRef.child(videoURL)
            
            //get timeStamp
            let startRef = NSDate()
            let timeStamp = -(startRef.timeIntervalSince1970)
            
            //get user ID
            let userUID = user.uid
            
            //Autogenerate autoid for video post
            let autoVidHomefeed = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Homefeed").childByAutoId().key
            
            //save to homefeed
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").child(autoVidHomefeed).child("postDetails").updateChildValues(["eventDate":self.mEventDate,"eventName":self.mEventName,"eventTime":self.mEventTime,"eventID":self.mEventID,"orgID":self.mOrgID,"orgProfileIMage": self.orgProfImage,"eventDateObject":self.eventDateObject])
            
            //save fireCount
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").child(autoVidHomefeed).updateChildValues(["fireCount":0])
            
            //save mediaLinks
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").child(autoVidHomefeed).child("postDetails").child("mediaInfo").childByAutoId().updateChildValues(["fireCount":0,"mediaLink":vidRef.fullPath as String,"userID":(user.uid),"mediaCaption":self.mVidCaption!,"timeStamp":timeStamp])
            
            //save to personal profile
        self.ref.child("users").child(userUID).child("HomeFeedPosts").updateChildValues([autoVidHomefeed:(vidRef.fullPath as String)])
            
            
            //save highest level timeStamp
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").child(autoVidHomefeed).updateChildValues(["timeStamp":timeStamp])
            
            //Get list of tags
            let orgTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations").child(self.mOrgID).child("preferences")
            
            orgTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").child(autoVidHomefeed).child("orgTags").updateChildValues([rest.key:true])
                }
            
                
            })

        
            // Local file you want to upload
            let localFile: NSURL = videoNSURL
            // Create the file metadata
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            
            // Upload file and metadata to the object 'images/mountains.jpg'
            let uploadTask = storageRef.child(vidRef.fullPath).putFile(localFile, metadata: metadata);
            
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
                    completion(false)
                case .Unauthorized:
                    // User doesn't have permission to access file
                    print("User doesn't have permission to access file")
                    completion(false)
                    
                case .Cancelled:
                    // User canceled the upload
                    print("User canceled the upload")
                    completion(false)
                //...
                case .Unknown:
                    // Unknown error occurred, inspect the server response
                    print("Unknown error occurred, inspect the server response")
                    completion(false)
                default:
                    print("Honestly, no clue what's happening")
                    completion(false)
                }
            }
            
            completion(true)
        } else {
            print("No user is signed in.")
        }
        
            let myAlertController = UIAlertController(title: "Done!", message:
                nil, preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(myAlertController, animated: true, completion: { () -> Void in
                myAlertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.navigationController?.popToRootViewControllerAnimated(false)
                })
            })
        
        } else {
            let alertController = UIAlertController(title: "Hi :)", message:
                "Please pick the event this video is for.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return the number of sections
        var numOfSections: Int = 0
        if events.count > 0
        {
            tableView.separatorStyle = .SingleLine
            numOfSections                = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text             = "You don't have any events happening now or coming up."
            noDataLabel.textColor        = UIColor.blackColor()
            noDataLabel.textAlignment    = .Center
            noDataLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            noDataLabel.numberOfLines = 2
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        }
        return numOfSections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return events.count
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    
    func getData(){
        
        let eventsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child(BounceConstants.firebaseEventsChild()).queryLimitedToFirst(100)
        eventsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if let endDateString = rest.childSnapshotForPath("endEventDateObject").value as? NSNumber {
                    let endDateObject = -(endDateString.doubleValue)
                    let myUser = EmberUser()
                    let orgID = rest.childSnapshotForPath("orgID").value as? String
                    myUser.isAdminOf(orgID!, completionHandler: {(isAdmin) in
                        if(isAdmin){
                            if(self.isWithinAcceptableRange(endDateObject)){
                                self.events.append(rest)
                            }
                        }
                        
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
            });
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var snap:FIRDataSnapshot
        snap = events[indexPath.row]

        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
            
            mEventID = snap.key as String
            mEventDate = (snap.childSnapshotForPath("eventDate").value)! as! String
            mEventName = (snap.childSnapshotForPath("eventName").value)! as! String
            mEventTime = (snap.childSnapshotForPath("eventTime").value)! as! String
            mOrgID = (snap.childSnapshotForPath("orgID").value)! as! String
            orgProfImage = (snap.childSnapshotForPath("orgProfileImage").value)! as! String
            eventDateObject = (snap.childSnapshotForPath("eventDateObject").value)! as! NSNumber

        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        var item : FIRDataSnapshot
        item = events[indexPath.row]
        
        cell.textLabel?.text = (item.value!.valueForKey(BounceConstants.firebaseEventsChildEventName()) as! String)
        cell.detailTextLabel?.text = (item.value!.valueForKey(BounceConstants.firebaseEventsChildOrgName()) as! String)
        cell.accessoryType = .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .None
        }
        
    }
    
    func isWithinAcceptableRange(endDate:NSNumber) -> Bool {
        let date = NSDate()
        
        let myEndDate = NSDate.init(timeIntervalSince1970: endDate.doubleValue)
        let validPostingPeriodStart  = myEndDate.dateByAddingTimeInterval(-7*24*60*60)
        
        if (date >= validPostingPeriodStart && date <= myEndDate)
        {
            return true
        } else {
            return false
        }
        
    }
}
