//
//  NotificationItem.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 8/12/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation


@objc class NotificationItem : NSObject {
    
    var title: String
    var date: NSDate
    var UUID: String
    
    init(date: NSDate, title: String, UUID: String) {
        self.date = date
        self.title = title
        self.UUID = UUID
    }
    
    var isOverdue: Bool {
        return (NSDate().compare(self.date) == NSComparisonResult.OrderedDescending) // date is earlier than current date
    }
}