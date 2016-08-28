//
//  SearchOrgsViewController.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/2/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

class SearchOrgsViewController : UITableViewController{
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var filter  = false;
    var ref = FIRDatabaseReference()
    var orgs : [FIRDataSnapshot] = []
    var filteredOrgs : [FIRDataSnapshot] = []
    var lastKey : String = ""
    var lastSearchFilter : String = ""
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())
        
        getData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchOrgsViewController.didChangeSearch), name: BounceConstants.searchNotificationName(), object: nil)
        self.tableView.registerNib(UINib.init(nibName: "cell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.tableView.registerNib(UINib.init(nibName: "last", bundle: nil), forCellReuseIdentifier: "Last")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        print("view did appear called")
        
        
    }
    
    
    func getMoreData(){
        
        self.ref.child(BounceConstants.firebaseOrgsChild()).queryOrderedByKey().queryStartingAtValue(lastKey).queryLimitedToFirst(10).observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for (index, rest) in snapshot.children.allObjects.enumerate() {

                if(index != 0){
                   
                    if(self.lastKey != (rest as! FIRDataSnapshot).key){
                        print(rest as! FIRDataSnapshot)
                        self.orgs.append(rest as! FIRDataSnapshot)
                    }
                    
                }else{
                    // TODO : message that no more items are present
                }
                
            }
            if(self.filter){
               self.filterContentForSearchText(self.lastSearchFilter)
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
            });
            
            
        })
        
    }
    func getData(){
        
        let eventsQuery = self.ref.child(BounceConstants.firebaseOrgsChild()).queryLimitedToFirst(100)
        eventsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.orgs.append(rest)
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
            lastSearchFilter = result
            filterContentForSearchText(result)
        }
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        lastKey = orgs[orgs.count - 1].key;
        
        filteredOrgs = orgs.filter { org in
            return org.value!.valueForKey(BounceConstants.firebaseOrgsChildOrgName())!.lowercaseString.containsString(searchText.lowercaseString)
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (filter){
            return filteredOrgs.count + 1
        }
        return orgs.count + 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1){
            
            lastKey = orgs[orgs.count - 1].key;
            getMoreData()
            
        }else{
            
            var item : FIRDataSnapshot
            if filter {
                item = filteredOrgs[indexPath.row]
                
            } else {
                item = orgs[indexPath.row]
            }
            
            let controller = OrgProfileViewController()
            controller.orgId = item.key
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell
        
        if(indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1){
            
            cell = tableView.dequeueReusableCellWithIdentifier("Last", forIndexPath: indexPath)
            cell.textLabel?.text = "See more..."
            
            if(filter && filteredOrgs.count == 0){
                cell.textLabel?.text = "No more results"
            }
            
        }else{
            
            var item : FIRDataSnapshot
            if filter {
                item = filteredOrgs[indexPath.row]
                
            } else {
                item = orgs[indexPath.row]
            }
            
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel?.text = (item.value!.valueForKey(BounceConstants.firebaseOrgsChildOrgName()) as! String)
            cell.detailTextLabel?.text = (item.value!.valueForKey(BounceConstants.firebaseOrgsChildOrgDesc()) as! String)
            
        }
        
       
        return cell
    }
    
    
}
