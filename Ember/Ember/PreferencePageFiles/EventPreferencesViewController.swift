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
    var segOrgID = ""
    var segOrgName = ""
    var segProfileImage = ""
    var segEventDateObject = NSDate()
    var segEndEventDateObject = NSDate()
        
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
        
        //get timeStamp
        let startRef = NSDate()
        let timeStamp = -(startRef.timeIntervalSince1970)
        
        //get eventDateObject
        let eventDateObject = -(self.segEventDateObject.timeIntervalSince1970)
        
        //get endeventDateObject
        let endEventDateObject = -(self.segEndEventDateObject.timeIntervalSince1970)
        
        //Ref to events followed
        let eventsFollowedRefChild = self.ref.child("users").child(userID!).child("eventsFollowed")
        
        //Post as homefeed item
        let homeFeedEntryKey = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").childByAutoId().key
        let homeFeedRefChild = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed")
        
        //Get homefeedMedia key
        let homeFeedMediaKey = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("HomeFeed").childByAutoId().key
        
        let homefeedItem = ["eventDate":self.eventsegDate,"eventID": eventsTreekey, "eventName": self.eventsegName,"eventTime":self.eventsegTime,"eventDateObject":eventDateObject,"endEventDateObject":endEventDateObject,"orgID":self.eventsegOrgID,"orgProfileImage":self.segProfileImage,"eventTags":evTags]
        
        let eventItem = ["eventDate":self.eventsegDate,"eventName": self.eventsegName, "eventDesc": self.eventSegDesc,"eventLocation":self.eventsegLocation,"eventTime":self.eventsegTime,"orgID":self.eventsegOrgID,"orgName":self.eventsegOrgName, "eventTags":evTags,"orgProfileImage":self.segProfileImage,"homeFeedMediaKey":homeFeedMediaKey,"homefeedPostKey":homeFeedEntryKey,"timeStamp":timeStamp,"eventDateObject":eventDateObject,"endEventDateObject":endEventDateObject]
        
        //post to Firebase
        eventsRefChild.child(eventsTreekey).setValue(eventItem)
        homeFeedRefChild.child(homeFeedEntryKey).child("postDetails").setValue(homefeedItem)
        homeFeedRefChild.child(homeFeedEntryKey).updateChildValues(["fireCount":1,"interestCount":1,"timeStamp":timeStamp])
        
        //Add to events Followed
        eventsFollowedRefChild.updateChildValues([homeFeedEntryKey:true])
        
        //Get list of tags
        let orgTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations").child(self.eventsegOrgID).child("preferences")
        orgTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {                        homeFeedRefChild.child(homeFeedEntryKey).child("orgTags").updateChildValues([rest.key:true])
            }
        })
        
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
