//
//  SearchEventsViewController.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/2/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit


class SearchEventsViewController : UITableViewController{
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var filter  = false;
    var ref = FIRDatabaseReference()
    var events : [FIRDataSnapshot] = []
    var filteredEvents : [FIRDataSnapshot] = []
 
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.ref = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchEventsViewController.didChangeSearch), name: BounceConstants.searchNotificationName(), object: nil)
        
        getData()
        
        self.tableView.registerNib(UINib.init(nibName: "cell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        
    }
    
    func getData(){
        
        let eventsQuery = self.ref.child(BounceConstants.firebaseEventsChild()).queryLimitedToFirst(100)
        
        eventsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.events.append(rest)
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
            });
        })
        
        
    }
    
    func didChangeSearch(notification: NSNotification) {
        let result = notification.object as! String
        if(result == ""){
            filter = false;
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
            });
        }else{
            filterContentForSearchText(result)
        }
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredEvents = events.filter { event in
            return event.value!.valueForKey(BounceConstants.firebaseEventsChildEventName())!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        filter = true
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.reloadData()
        });
    }
    
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                
        let snap : FIRDataSnapshot
        
        if(filter){
            snap = filteredEvents[indexPath.row]
        }else{
            snap = events[indexPath.row]
        }
        
        let controller = EventViewController()
        let bounceSnap = EmberSnapShot(snapShot: snap)
        controller.eventNode = bounceSnap
        controller.isFromSearch = true
//        self.navigationController?.pushViewController(controller, animated: true)
        
//        self.ref.child(BounceConstants.firebaseHomefeed()).child((snap.value?.valueForKey("homeFeedMediaKey"))! as! String).observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
//            
//            let controller = EventViewController()
//            let bounceSnap = EmberSnapShot(snapShot: snapshot)
//            controller.eventNode = bounceSnap
//            self.navigationController?.pushViewController(controller, animated: true)
//            
//        })
        
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (filter){
            return filteredEvents.count
        }
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        var item : FIRDataSnapshot
        if filter {
            item = filteredEvents[indexPath.row]
            
        } else {
            item = events[indexPath.row]
        }
        cell.textLabel?.text = (item.value!.valueForKey(BounceConstants.firebaseEventsChildEventName()) as! String)
        cell.detailTextLabel?.text = (item.value!.valueForKey(BounceConstants.firebaseEventsChildOrgName()) as! String)
        return cell
    }
}




