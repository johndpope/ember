//
//  NewProfileViewController.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 8/10/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FirebaseAuth


@objc protocol OpenMyOrgsFromSuperDelegate: class {
    func openMyOrgsFromSuperViewController()
}

@objc protocol OpenDiscoverPageFromSuperDelegate: class {
    func openDiscoverFromSuperViewController()
}

@objc protocol OpenCalendarPageFromSuperDelegate: class {
    func openCalendarFromSuperViewController()
}


class NewProfileViewController: ASViewController, ASTableDelegate, ASTableDataSource, OpenMyOrgsDelegate, OpenDiscoverPageDelegate, ImageClickedDelegate, OpenCalendarPageDelegate {
    
    var tableNode : ASTableNode{
        return node as! ASTableNode
    }
    
    weak var delegate1:OpenMyOrgsFromSuperDelegate?
    weak var discoverViewControllerDelegate1: OpenDiscoverPageFromSuperDelegate?
    weak var openCalendar1: OpenCalendarPageFromSuperDelegate?
    
    
    let titleNodeIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    let noPostsNodeIndexPath = NSIndexPath(forItem: 1, inSection: 0)
    
    
    let data = EmberSnapShot()
    let posts = NSMutableArray()
    var userid = NSString()
    var dataSourceLocked = false
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var reloadCalled = false
    var mainSet = [String: String]() // String for key and Bool for false if image post and true for video post
    
    
    init(){
     super.init(node: ASTableNode())
        delegate1 = nil
        discoverViewControllerDelegate1 = nil
        openCalendar1 = nil
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                if let user = FIRAuth.auth()?.currentUser {
                    self.userid = user.uid
                    
                } else {
                    print("No user is signed in.")
                }
            } else {
                print("No user is signed in.")
            }
        }
  
        self.tableNode.view.separatorStyle = .None
        
        // Prevents gray background appearing when clicking first node
        self.tableNode.view.allowsSelection = false
        
        // TODO : will remimplement back button once tab bar items are added programmatically
//        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
//        navigationItem.leftBarButtonItem = backButton
        
        let backButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let boundSize = self.view.bounds.size
        indicator.sizeToFit()
        
        var refreshRect = indicator.frame
        refreshRect.origin = CGPointMake((boundSize.width - indicator.frame.size.width) / 2.0,
                                                                                 (boundSize.height - indicator.frame.size.height) / 2.0)
        indicator.frame = refreshRect
        self.view.addSubview(indicator)

        self.navigationController?.navigationBar.topItem?.title = "Your Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont.systemFontOfSize(25)]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "exit"), style: .Plain, target: self, action: nil)

        self.fetchData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: navigationController, action: #selector(NewProfileViewController.gearIconClicked(_:)))
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    func childNode(childImage: EmberNode!, didClickImage image: UIImage!, withLinks array: [AnyObject]!) {

        let provider = GalleryImageProvider()
        provider.setUrls(array)
        
        let frame  = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 24)
        
        let headerView = CounterView(frame: frame, node:childImage, currentIndex: 0, count: array.count, placement: .Header, mediaInfo: array as NSArray)
        let footerView = CounterView(frame: frame, node:childImage, currentIndex: 0, count: array.count, placement: .Footer, mediaInfo: array as NSArray)
        
        let galleryViewController  = GalleryViewController()
        galleryViewController.setImageProvider(provider)
        galleryViewController.setDisplacedView(childImage.getSubImageNode().view)
        galleryViewController.setImageCount(array.count)
        galleryViewController.setStartIndex(0)
        galleryViewController.intializeTransitions()
        galleryViewController.completeInit()
        
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        self.presentImageGallery(galleryViewController)
        
        galleryViewController.landedPageAtIndexCompletion = {(index) in
            headerView.currentIndex = index
            footerView.currentIndex = index
        }
        
    }
    
    func openDiscoverViewController() {
        discoverViewControllerDelegate1!.openDiscoverFromSuperViewController()
    }
    
    func openMyOrgsViewController() {
        delegate1!.openMyOrgsFromSuperViewController()
    }
    
    func openCalendarViewController() {
        openCalendar1!.openCalendarFromSuperViewController()
    }
    
    
    func gearIconClicked(sender : UIBarButtonItem) {

    }
    
    /**
     Fetches user's HomeFeedPosts under their user object and uses the keys to search for corresponding
     keys in the HomeFeed tree
     */
    func fetchData(){
        
        indicator.startAnimating()
        
        if let user = FIRAuth.auth()?.currentUser {
            let uid = user.uid;
            
            let ref = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())
            
            let query = ref.child(BounceConstants.firebaseUsersChild()).child(uid).child("HomeFeedPosts")
            query.observeSingleEventOfType(.Value, withBlock: {(snapShot) in
                
                var count = 1; // Maintains index for inserting posts into tableview
                //            print("your profile: \(snapShot)")
//                print("snap count: \(snapShot.childrenCount)")
                
                if(snapShot.childrenCount == 0){ // If no posts are available then only add the the first node with the user details
                    self.indicator.stopAnimating()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.reloadCalled = true
                        self.tableNode.view.beginUpdates()
                        self.tableNode.view.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
                        self.tableNode.view.endUpdates()
                        return
                    })
                    
                }
                
                // For each HomefeedPosts key
                for child in snapShot.children{
                    
                    let homefeedKey = (child as! FIRDataSnapshot).key
                    
                    if let dict = (child as! FIRDataSnapshot).value as? NSDictionary{
                        
                        for key in dict.allKeys{
                            self.mainSet[homefeedKey] = key as? String // Has nested values hence image's mediaInfo key saved
                        }
                        
                    }else{
                        self.mainSet[homefeedKey] = "video" // No nested values hence video post
                        
                    }

                    
//                    print("mainset: \(self.mainSet)")
                    
                    ref.child(BounceConstants.firebaseHomefeed()).child(homefeedKey).observeSingleEventOfType(.Value, withBlock: {
                        (snap) in
                        
                        // If video post...
                        if((self.mainSet[homefeedKey]) == "video"){

                            self.indicator.stopAnimating()
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.reloadCalled = true
                                
                                self.tableNode.view.beginUpdates()
                                self.data.addIndividualProfileSnapShot(snap)
                                self.tableNode.view.insertRowsAtIndexPaths([NSIndexPath(forRow: count, inSection: 0)], withRowAnimation: .Fade)
                                self.tableNode.view.endUpdates()
                                
                                count += 1
                                return
                                
                            })
                            return
                        }
                        
                        // Image post if reaches this point
                        if let dict = (snap.value as! NSDictionary).objectForKey("postDetails")?.objectForKey("mediaInfo")?.allKeys{
//                            print("dict: \(dict)")
                            
                            for key in dict{
                                if self.mainSet[homefeedKey]! == key as! String{
                                    
                                    self.indicator.stopAnimating()
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.reloadCalled = true
                                        
                                        self.tableNode.view.beginUpdates()
                                        self.data.addIndividualProfileSnapShot(snap)
                                        self.tableNode.view.insertRowsAtIndexPaths([NSIndexPath(forRow: count, inSection: 0)], withRowAnimation: .Fade)
                                        self.tableNode.view.endUpdates()
                                        
                                        count += 1
                                        
                                    })
                                    
                                }
                            }
                            
                        }
                        
                        
                    })
  

                } 
                
            })
            
        }
        
    }
    

    
    func FIRDownload(bounceNode : EmberNode, postDetails : NSDictionary){
        
        var url =  NSString()
        
        if(postDetails.objectForKey(BounceConstants.firebaseHomefeedEventPosterLink()) != nil){
            url = postDetails.objectForKey(BounceConstants.firebaseHomefeedEventPosterLink()) as! NSString
            
        }else{
    
        if(postDetails.objectForKey(BounceConstants.firebaseHomefeedMediaInfo())!.isKindOfClass(NSDictionary)){
            
            let values = (postDetails.objectForKey(BounceConstants.firebaseHomefeedMediaInfo())!.allValues) as NSArray
            if(values.count != 0){
                let first = values.objectAtIndex(0) as! NSDictionary
                url = first.objectForKey("mediaLink") as! NSString
            }
        }else{
           
            let values = postDetails.objectForKey(BounceConstants.firebaseHomefeedMediaInfo()) as! NSArray
            let first = values.objectAtIndex(0) as! NSDictionary
            url = first.objectForKey("mediaLink") as! NSString
        }

            
        }
        
//        print(url)
        
        if(!url.containsString("http")){
            
            let storageRef : FIRStorageReference = FIRStorage.storage().referenceForURL(BounceConstants.firebaseStorageUrl())
            
            let ref = storageRef.child(url as String)
            ref.downloadURLWithCompletion { (URL, error) -> Void in
                if (error != nil) {
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if(URL!.absoluteString.containsString("mp4") || URL!.absoluteString.containsString("mov")){
                            bounceNode.getSubVideoNode().asset = AVAsset(URL: URL!)
                            
                        }else{
                            bounceNode.getSubImageNode().URL = URL!
                        }
                    })
                    
                }
            }
        }else{
            
            if(url.containsString("mp4") || url.containsString("mov")){
                bounceNode.getSubVideoNode().asset = AVAsset(URL: NSURL(string: url as String)!)
                
            }else{
                bounceNode.getSubImageNode().URL = NSURL(string: url as String)
            }
        }

    }
    
    func gearIconClicked(){
        self.toggleEditingMode()
    }
    
    
    func deletePost(row : Int){
        
        let post = data.getBounceSnapShotAtIndex(UInt(row) - 1)
        let key = post.key
        
        
        // Delete from homefeed
        let refHomefeed = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())
        
        if(self.mainSet[key] == "video"){
           refHomefeed.child(BounceConstants.firebaseHomefeed()).child(key).removeValue()
        }else{
            print(key)
            print(self.mainSet)
            let mediaInfoKey = self.mainSet[key]
            refHomefeed.child(BounceConstants.firebaseHomefeed()).child(key).child(BounceConstants.firebaseHomefeedPostDetails()).child(BounceConstants.firebaseHomefeedMediaInfo()).observeSingleEventOfType(.Value, withBlock: {(snap) in
                
//                print("children count: \(snap.childrenCount)")
                if(snap.childrenCount == 1){
                    refHomefeed.child(BounceConstants.firebaseHomefeed()).child(key).removeValue()
                }else{
                   refHomefeed.child(BounceConstants.firebaseHomefeed()).child(key).child(BounceConstants.firebaseHomefeedPostDetails()).child(BounceConstants.firebaseHomefeedMediaInfo()).child(mediaInfoKey!).removeValue()
                }
            })
        }
        
        
        if let user = FIRAuth.auth()?.currentUser {
            let uid = user.uid;
            // Delete from user object
            FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot()).child(BounceConstants.firebaseUsersChild()).child(uid).child("HomeFeedPosts").child(key).removeValue()
        }
        
        data.removeSnapShotAtIndex(UInt(row) - 1)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(data.getNoOfBounceSnapShots() != 0){
            return Int(data.getNoOfBounceSnapShots()) + 1
        }else{
            // Display a message when the table is empty
            
            if(reloadCalled){
                return 2
            }
            
        }
        return 1
    }
    
    func tableView(tableView: ASTableView, nodeBlockForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNodeBlock {
        if(titleNodeIndexPath.compare(indexPath) == .OrderedSame){
            
            let cellNodeBlock = { () -> ASCellNode in
                let node = YourProfileFirstNode()
                node.delegate = self
                node.discoverViewControllerDelegate = self
                node.openCalendarDelegate = self
                return node
            }
            
            return cellNodeBlock
        }
        
        if(noPostsNodeIndexPath.compare(indexPath) == .OrderedSame && reloadCalled && data.getNoOfBounceSnapShots() == 0){
            let cellNodeBlock = { () -> ASCellNode in
                let node = NoPostsNode()
                return node
            }
            
            return cellNodeBlock
            
        }else{
            let snap = data.getBounceSnapShotAtIndex(UInt(indexPath.row) - 1)
            
            let cellNodeBlock = { () -> ASCellNode in
                
                let node = EmberNode(event: snap, past: false)
                node.delegate = self
                self.FIRDownload(node, postDetails: snap.getPostDetails())
                return node
            }
            
            return cellNodeBlock
        }

        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return titleNodeIndexPath.compare(indexPath) != .OrderedSame || (noPostsNodeIndexPath.compare(indexPath) != .OrderedSame && data.getNoOfBounceSnapShots() == 0)
    }
    
    
    func tableViewLockDataSource(tableView: ASTableView) {
        self.dataSourceLocked = true
    }
    
    func tableViewUnlockDataSource(tableView: ASTableView) {
        self.dataSourceLocked = false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(editingStyle == .Delete){
            
            let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: nil, preferredStyle: .ActionSheet)
            
            let yes = UIAlertAction(title: "Yes", style: .Default, handler: {(action) in
                self.deletePost(indexPath.row)
                self.tableNode.view.deleteRowsAtIndexPaths(NSArray(objects: indexPath) as! [NSIndexPath], withRowAnimation: .Automatic)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {(action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
            })
            
            alert.addAction(yes)
            alert.addAction(cancel)
            
            if(self.presentedViewController == nil){
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func toggleEditingMode(){
        self.tableNode.view.setEditing(!tableNode.view.editing, animated: true)
    }
    
    
    
}