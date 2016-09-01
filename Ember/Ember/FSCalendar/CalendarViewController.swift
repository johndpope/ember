//
//  CalendarViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 8/22/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit


class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,UITableViewDelegate,UITableViewDataSource  {
    

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    var ref:FIRDatabaseReference!

    @IBOutlet weak var mainTableView: UITableView!
    var thisDateEvents = [FIRDataSnapshot]()
    var allDateEvents = [FIRDataSnapshot]()
    
    //Contains strings of all the dates that have an event
    var mainSet:Set<String> = Set([])
    
    //Contains the number of events per valid date
    var eventsDict = [String:Int]()
    
    //contains the events for any valid date string
    var mainObjectsDict = [String:[FIRDataSnapshot]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        populateData({ (set) in
            set
        })
       
        // Do any additional setup after loading the view.
        
        calendar.scrollDirection = .Horizontal
        calendar.appearance.caseOptions = [.HeaderUsesUpperCase,.WeekdayUsesUpperCase]
        calendar.selectDate(calendar.dateWithYear(2015, month: 10, day: 10))
        calendar.clipsToBounds = true
        //calendar.pagingEnabled  = false

    }
    override func viewDidAppear(animated: Bool) {
        calendar.reloadData()
        mainTableView.reloadData()
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func minimumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return calendar.dateWithYear(2016, month: 8, day: 1)
    }
    
    func maximumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return calendar.dateWithYear(2017, month: 5, day: 31)
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        if let events = self.eventsDict[calendar.stringFromDate(date)] {
        return events
        } else {
            
        return 0
            
        }
    }
    
//    func calendarCurrentPageDidChange(calendar: FSCalendar) {
//        NSLog("change page to \(calendar.stringFromDate(calendar.currentPage))")
//    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        
        let thisDate = calendar.stringFromDate(date)
        
        if let currentEvents =  mainObjectsDict[thisDate] {
            self.thisDateEvents = currentEvents
            self.mainTableView.reloadData()
        } else {
            thisDateEvents = []
             self.mainTableView.reloadData()
        }
    }
    
    func calendar(calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func populateData(completion : (Set<String>) -> ()){
        let eventsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child(BounceConstants.firebaseEventsChild()).queryLimitedToFirst(50)
        eventsQuery.queryOrderedByKey().observeEventType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.allDateEvents.append(rest)
                let dateNum = rest.childSnapshotForPath("eventDateObject").value as! NSNumber
                self.extractDateVal(dateNum)
            }
            self.getSnapshot()
            completion(self.mainSet)
        })
    }
    
    func saveToDict (passedDate:String) {
        if let val = self.eventsDict[passedDate] {
            eventsDict[passedDate] = val + 1
            
        } else {
            eventsDict[passedDate] = 1
        }
    }
    
    func extractDateVal(thisDate:NSNumber) {
        let dateObject = -(thisDate.doubleValue)
        let myDate = NSDate.init(timeIntervalSince1970: dateObject)
        self.mainSet.insert(self.calendar.stringFromDate(myDate))
        self.saveToDict(self.calendar.stringFromDate(myDate))
    }
    
    func getSnapshot() {
        for items in allDateEvents {
            let itsDateString = getDateString(items)
            
            if var val = mainObjectsDict[itsDateString]  {
                
                val.append(items)
                mainObjectsDict.updateValue(val, forKey: itsDateString)
            } else {
                mainObjectsDict[itsDateString] = [items]
            }
        }
    }
    
    func getDateString(itemSnap:FIRDataSnapshot) -> String {
        
        let itsDateInterim = itemSnap.childSnapshotForPath("eventDateObject").value as! NSNumber
        let dateObjectInterim = -(itsDateInterim.doubleValue)
        let myDateInterim = NSDate.init(timeIntervalSince1970: dateObjectInterim)
        let finalInterim = self.calendar.stringFromDate(myDateInterim)
        return finalInterim
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return thisDateEvents.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
     {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier("detailsCell", forIndexPath: indexPath) as! CalendarDetailsTableViewCell
        
        let item = self.thisDateEvents[indexPath.row]
        cell.eventName?.text = (item.value!["eventName"]) as? String
        cell.orgName?.text = (item.value!["orgName"]) as? String
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let snap = self.thisDateEvents[indexPath.row];
        
        let dateToCheck = snap.childSnapshotForPath("eventDateObject").value as! NSNumber
        if(checkDate(dateToCheck)) {
        
        if let posterKey = (snap.value!.valueForKey("homefeedPostKey") as? String){
            
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child(BounceConstants.firebaseHomefeed()).child(posterKey).observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
                let controller = EventViewController()
                let bounceSnap = EmberSnapShot(snapShot: snapshot)
                controller.eventNode = bounceSnap
                self.navigationController?.pushViewController(controller, animated: true)
                
            })
            
            }
        }
        
    }
    
    func checkDate(dateToCheck:NSNumber) -> Bool {
        let date = NSDate()
        let dateObject = -(dateToCheck.doubleValue)
        let myDate = NSDate.init(timeIntervalSince1970: dateObject)
        
        if (myDate > date) {
            return true
        } else {
            return false
        }
        
        
        
    }
 
//    func calendar(calendar: FSCalendar, imageForDate date: NSDate) -> UIImage? {
//        return [13,24].containsObject(calendar.dayOfDate(date)) ? UIImage(named: "tinyFire") : nil
//    }



}
