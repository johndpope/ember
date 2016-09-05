//
//  MyOrgsTableViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 7/20/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyOrgsTableViewController: UITableViewController {

    
    // MARK: - Properties
    var ref = FIRDatabaseReference()
    var orgs : [FIRDataSnapshot] = []
    var interimIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        //retrieveORGIDS()
        
        retrieveORGIDS({ (downLoadState) in
           downLoadState
        })
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont.systemFontOfSize(25, weight: UIFontWeightThin)]
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 1
        var numOfSections: Int = 0
        if orgs.count > 0
        {
            tableView.separatorStyle = .SingleLine
            numOfSections                = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text             = "You are not currently following any orgs."
            noDataLabel.textColor        = UIColor.blackColor()
            noDataLabel.textAlignment    = .Center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        }
        return numOfSections
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orgs.count
    }
    
    
    func retrieveORGIDS(completion : (Bool) ->()) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(userID!).child("orgsFollowed").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                self.interimIds.append(rest.key)
            }
            for object in self.interimIds {
                let orgsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("Organizations/\(object)")
                orgsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot)in
                    dispatch_async(dispatch_get_main_queue(),{
                        self.orgs.append(snapshot)
                        self.tableView.reloadData()
                    });
                    })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        completion(true)
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyOrgsTableViewCell", forIndexPath: indexPath) as! MyOrgsTableViewCell
        
        
        //Fetches appropriate info for each followed org
        var item : FIRDataSnapshot
         item = self.orgs[indexPath.row]
        
        let numOfFollowers = item.childSnapshotForPath("followers").childrenCount
        let numString = String(numOfFollowers)
        cell.orgNameLabel?.text = (item.value!["orgName"] as? String)
        
        
        if numOfFollowers == 1 {
            cell.followerCountLabel?.text = "\(numString) Follower"
        } else {
            cell.followerCountLabel?.text = "\(numString) Followers"

        }
        
        let myUser = EmberUser()
        let orgID = item.key
        
        myUser.isAdminOf(orgID, completionHandler: {(isAdmin) in
            if(isAdmin){
                // user is admin
                cell.adminLabel.hidden = false
            } else {
                cell.adminLabel.hidden = true
            }
            
        })
        let url = NSURL(string: item.childSnapshotForPath("smallImageLink").value as! String)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            dispatch_async(dispatch_get_main_queue(), {
                cell.profImage?.image = UIImage(data: data!)
            });
        }
        cell.accessoryType = .None

        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var snap:FIRDataSnapshot
        snap = orgs[indexPath.row]
        let controller = OrgProfileViewController()
        controller.orgId = snap.key
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
//            cell.accessoryType = .None
//        }
//        
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
