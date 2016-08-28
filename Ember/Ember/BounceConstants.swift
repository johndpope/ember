//
//  BounceConstants.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/4/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation


let SEARCH_EVENTS_PAGE_TITLE =  "EVENTS";
let SEARCH_ORGS_PAGE_TITLE =  "ORGS";


//Search page notification name
let SEARCH_NOTIFICATION_NAME =  "test";


//Primary App Color
let PRIMARY_APP_COLOR = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255.0, alpha: 1.0)
let SECONDARY_APP_COLOR = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 101.0/255.0, alpha: 1.0)


//Firebase Homefeed
let FIREBASE_HOMEFEED_CHILD =  "HomeFeed";
let FIREBASE_HOMEFEED_CHILD_EVENT_DETAILS_EVENTPOSTERLINK = "eventPosterLink"
let FIREBASE_HOMEFEED_CHILD_EVENT_DETAILS_MEDIALINKS = "mediaLinks"
let FIREBASE_HOMEFEED_CHILD_FIRECOUNT = "fireCount"
let FIREBASE_HOMEFEED_CHILD_POST_DETAILS = "postDetails"
let FIREBASE_HOMEFEED_CHILD_EVENT_DETAILS_MEDIAINFO = "mediaInfo"

// Test Homefeed
let FIREBASE_HOMEFEED_TEST_CHILD =  "HomeFeedTest"




//Firebase events
let FIREBASE_EVENTS_CHILD =  "Events";
let FIREBASE_EVENTS_CHILD_EVENTNAME =  "eventName";
let FIREBASE_EVENTS_CHILD_EVENTDATE =  "eventDate";
let FIREBASE_EVENTS_CHILD_EVENTTIME =  "eventTime";
let FIREBASE_EVENTS_CHILD_ORGNAME =  "orgName";
let FIREBASE_EVENTS_CHILD_IMAGELINK = "eventImageLink"
let FIREBASE_EVENTS_CHILD_ORGID = "orgID"


//Firebase Orgs
let FIREBASE_ORGS_CHILD =  "Organizations";
let FIREBASE_ORGS_CHILD_ORGNAME =  "orgName";
let FIREBASE_ORGS_CHILD_ORGDESC =  "orgDesc";
let FIREBASE_ORGS_CHILD_SMALLIMAGELINK = "smallImageLink"
let FIREBASE_ORGS_CHILD_LARGEIMAGELINK = "largeImageLink"

//Landing page titles
let LANDING_PAGE_PAGE_ONE_TITLE =  "HOMEFEED";
let LANDING_PAGE_PAGE_TWO_TITLE =  "MY EVENTS";
let LANDING_PAGE_PAGE_THREE_TITLE =  "ORGS";

//School Root
//var FIREBASE_SCHOOL_ROOT = NSUserDefaults.standardUserDefaults().stringForKey("FIREBASE_SCHOOL_ROOT")!
var FIREBASE_SCHOOL_ROOT = "/Vanderbilt University/"

//Users
let FIREBASE_USERS_CHILD =  "users";
let FIREBASE_USERS_CHILD_EVENTS_FOLLOWED =  "eventsFollowed";
let FIREBASE_USERS_CHILD_EVENTS_FOLLOWED_EVENTID =  "EventID";
let FIREBASE_USERS_CHILD_ORGS_FOLLOWED =  "orgsFollowed";
let FIREBASE_USERS_CHILD_ORG_ID =  "orgID";

//Storage
let FIREBASE_STORAGE_URL = "gs://bounce-46de5.appspot.com"

//Gallery
let MAX_PHOTOS_IN_GALLERY = 2

@objc class BounceConstants : NSObject{
    private override init() {}
    
    //Search
    class func searchEventsPageTitle() -> String { return SEARCH_EVENTS_PAGE_TITLE }
    class func searchOrgsPageTitle() -> String { return SEARCH_ORGS_PAGE_TITLE }
    class func searchNotificationName() -> String { return SEARCH_NOTIFICATION_NAME }
    
    
    //Homefeed
    class func firebaseHomefeed() -> String {return FIREBASE_HOMEFEED_CHILD}
    class func firebaseHomefeedEventPosterLink() -> String {return FIREBASE_HOMEFEED_CHILD_EVENT_DETAILS_EVENTPOSTERLINK}
    class func firebaseHomefeedMediaLinks() -> String {return FIREBASE_HOMEFEED_CHILD_EVENT_DETAILS_MEDIALINKS}
    class func firebaseHomefeedFireCount() -> String {return FIREBASE_HOMEFEED_CHILD_FIRECOUNT}
    class func firebaseHomefeedPostDetails() -> String {return FIREBASE_HOMEFEED_CHILD_POST_DETAILS}
    
    //HomefeedTest
    class func firebaseHomefeedTest() -> String {return FIREBASE_HOMEFEED_TEST_CHILD}
    
    class func firebaseHomefeedMediaInfo() -> String {return FIREBASE_HOMEFEED_CHILD_EVENT_DETAILS_MEDIAINFO}
    
    //Firebase Events
    class func firebaseEventsChild() -> String {return FIREBASE_EVENTS_CHILD}
    class func firebaseEventsChildEventName() -> String {return FIREBASE_EVENTS_CHILD_EVENTNAME}
    class func firebaseEventsChildOrgName() -> String {return FIREBASE_EVENTS_CHILD_ORGNAME}
    class func firebaseEventsChildImageLink() -> String {return FIREBASE_EVENTS_CHILD_IMAGELINK}
    class func firebaseEventsChildOrgId() -> String {return FIREBASE_EVENTS_CHILD_ORGID}
    class func firebaseEventsChildEventDate() -> String {return FIREBASE_EVENTS_CHILD_EVENTDATE}
    class func firebaseEventsChildEventTime() -> String {return FIREBASE_EVENTS_CHILD_EVENTTIME}
    
    //Firebase Root
    class func firebaseSchoolRoot() -> String {return FIREBASE_SCHOOL_ROOT}

    
    //Firebase Orgs
    class func firebaseOrgsChild() -> String {return FIREBASE_ORGS_CHILD}
    class func firebaseOrgsChildOrgName() -> String {return FIREBASE_ORGS_CHILD_ORGNAME}
    class func firebaseOrgsChildOrgDesc() -> String {return FIREBASE_ORGS_CHILD_ORGDESC}
    class func firebaseOrgsChildSmallImageLink() -> String {return FIREBASE_ORGS_CHILD_SMALLIMAGELINK}
    class func firebaseOrgsChildLargeImageLink() -> String {return FIREBASE_ORGS_CHILD_LARGEIMAGELINK}
    
    //Home landing page
    class func landingPagePageOneTitle() -> String {return LANDING_PAGE_PAGE_ONE_TITLE}
    class func landingPagePageTwoTitle() -> String {return LANDING_PAGE_PAGE_TWO_TITLE}
    class func landingPagePageThreeTitle() -> String {return LANDING_PAGE_PAGE_THREE_TITLE}
    
    //Firebase Users
    class func firebaseUsersChild() -> String {return FIREBASE_USERS_CHILD}
    class func firebaseUsersChildEventsFollowed() -> String {return FIREBASE_USERS_CHILD_EVENTS_FOLLOWED}
    class func firebaseUsersChildEventsFollowedEventID() -> String {return FIREBASE_USERS_CHILD_EVENTS_FOLLOWED_EVENTID}
    class func firebaseUsersChildOrgsFollowed() -> String {return FIREBASE_USERS_CHILD_ORGS_FOLLOWED}
    class func firebaseUsersChildOrgID() -> String {return FIREBASE_USERS_CHILD_ORG_ID}
    
    //Storage
    class func firebaseStorageUrl() -> String {return FIREBASE_STORAGE_URL}
    
    //Gallery
    class func maxPhotosInGallery() -> NSInteger {return MAX_PHOTOS_IN_GALLERY}
    
    // App Colors
    class func primaryAppColor() -> UIColor {return PRIMARY_APP_COLOR}
    
}