//
//  LocalNotifications.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 8/12/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation
import UIKit



@objc class LocalNotifications : NSObject {
    class var sharedInstance : LocalNotifications {
        struct Static {
            static let instance : LocalNotifications = LocalNotifications()
        }
        return Static.instance
    }
    
    private let ITEMS_KEY = "notificationItems"
    
    
    func allItems() -> [NotificationItem] {
        let todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? [:]
        let items = Array(todoDictionary.values)
        return items.map({NotificationItem(date: $0["date"] as! NSDate, title: $0["title"] as! String, UUID: $0["UUID"] as! String!)}).sort({(left: NotificationItem, right:NotificationItem) -> Bool in
            (left.date.compare(right.date) == .OrderedDescending)
        })
    }
        
    func addItem(item:NotificationItem) {
        // persist a representation of this todo item in NSUserDefaults
        var notificationDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        dateformatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let dateItem = dateformatter.stringFromDate(item.date)
        notificationDictionary[item.UUID] = ["date": item.date, "title": "\(item.title) is happening at \(dateItem)", "UUID": item.UUID] // store NSData representation of todo item in dictionary with UUID as key
        NSUserDefaults.standardUserDefaults().setObject(notificationDictionary, forKey: ITEMS_KEY) // save/overwrite todo item list
        
        let timeFormatter =  NSDateFormatter()
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let timeItem = timeFormatter.stringFromDate(item.date)
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "\(item.title) is happening today at \(timeItem)." // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        
        //time to be notified
        let timeToNotif = (item.date).dateByAddingTimeInterval(-60 * 60 * 6)
        notification.fireDate = timeToNotif// todo item due date (when notification will be fired)
        notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber + 1
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["title": item.title, "UUID": item.UUID] // assign a unique identifier to the notification so that we can retrieve it later
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    func addItemRemoteNotification(item: NotificationItem) {
        // persist a representation of this todo item in NSUserDefaults
        var notificationDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        notificationDictionary[item.UUID] = ["date": item.date, "title":"\(item.title)", "UUID": item.UUID] // store NSData representation of todo item in dictionary with UUID as key
        NSUserDefaults.standardUserDefaults().setObject(notificationDictionary, forKey: ITEMS_KEY) // save/overwrite todo item list
    }
    
    func removeItem(item: NotificationItem) {
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == item.UUID) { // ...and cancel the notification that corresponds to this NotificationItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
        
        if var notificationItems = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) {
            notificationItems.removeValueForKey(item.UUID)
            NSUserDefaults.standardUserDefaults().setObject(notificationItems, forKey: ITEMS_KEY) // save/overwrite todo item list
        }
    }
    
}