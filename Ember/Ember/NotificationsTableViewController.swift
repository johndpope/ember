//
//  NotificationsTableViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 8/11/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth

class NotificationsTableViewController: UITableViewController {
    
    
    // MARK: - Properties
    var notifications : [FIRDataSnapshot] = []
    
    //Retrieve from local disk
    var notificationItems: [NotificationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsTableViewController.refreshList), name: "NotificationsListShouldRefresh", object: nil)

        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.navigationController?.navigationBar.topItem?.title = "Notice Board"
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = PRIMARY_APP_COLOR
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName:UIFont.systemFontOfSize(25, weight: UIFontWeightThin)]
        
        // Use the edit button item provided by the table view controller.
        self.navigationItem.rightBarButtonItem = editButtonItem()

        
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(cancelTapped)), animated: true)
      
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func cancelTapped() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notificationItems.count
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true // all cells are editable
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsTableViewCell", forIndexPath: indexPath) as! NotificationsTableViewCell
         let item = self.notificationItems[indexPath.row] as NotificationItem
        
        cell.notifcell?.text = item.title as String!
        
        return cell
    }
 
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

//    }

    func refreshList() {
        notificationItems = LocalNotifications.sharedInstance.allItems()
        tableView.reloadData()
    }
   

    
     //Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
             //Delete the row from the data source
            let item = notificationItems.removeAtIndex(indexPath.row) // remove TodoItem from notifications array, assign removed item to 'item'
            LocalNotifications.sharedInstance.removeItem(item) // delete backing property list entry and unschedule local notification (if it still exists)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }    
    }
 

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
