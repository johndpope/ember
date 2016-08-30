//
//  AppDelegate.swift
//  Ember
//
//  Created by Anthony Wamunyu Maina on 8/27/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        

        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        
        
        // [START register_for_notifications]
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        FIRApp.configure()
       let userCurrent = FIRAuth.auth()?.currentUser
        if(userCurrent != nil) {
            let storyBoard: UIStoryboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
            let tabBarController: UITabBarController = storyBoard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            
            window?.rootViewController = tabBarController
        }
        return true;
    }
    // [START receive_message]
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        completionHandler(UIBackgroundFetchResult.NewData)
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        //Extract notification info
        //let incomingtext = userInfo["alert"] as? String
        let interim = userInfo["aps"]
        let incomingText = interim!["alert"] as? String
        
        
        //Save locally to NSUserDefaults
        let currentDate = NSDate()
        let notificationItem = NotificationItem(date:currentDate , title:incomingText!, UUID: NSUUID().UUIDString)
        LocalNotifications.sharedInstance.addItemRemoteNotification(notificationItem)
        
        // Print full message.
        print("%@", userInfo)
    }
    // [END receive_message]
    
    // [START refresh_token]
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()!
        print("InstanceID token: \(refreshedToken)")
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return true;
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        //[END disconnect_from_fcm]
    }
    
    //Register for local notifications
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        application.applicationIconBadgeNumber = 0
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationsListShouldRefresh", object: self)
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationsListShouldRefresh", object: self)
        
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //
    //    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    //        FIRMessaging.messaging().subscribeToTopic("school root")
    //    }
    
    
}
