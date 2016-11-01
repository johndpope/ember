//
//  ProfileViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/3/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseAuth
import Firebase


// TODO : Change Profile & NewProfile to ASViewController
// Will require changing Main Tab Bar Controller into an ASViewController
// Cannot add navigation to ASViewController from Individual Profile Icon on Storyboard
// Tried opening NewProfile from this class but this resulted in scrolling that wasn't smooth
// Interim solution is to use an instance of CAPSPageMenu which has an ASViewController root thus making scrolling smooth

class ProfileViewController: UIViewController, OpenMyOrgsFromSuperDelegate, OpenDiscoverPageFromSuperDelegate, OpenCalendarPageFromSuperDelegate {
    var ref:FIRDatabaseReference!
    var mySchools = [String]()
    
    var pageMenu : CAPSPageMenu?
    var controllerArray : [UIViewController] = []
    let controller1 = NewProfileViewController()
    
    var noOfTimesControllerCameIntoView = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        // MARK: - Scroll menu setup
        let controller1 = NewProfileViewController()
        
        controllerArray.append(controller1)
        self.extendedLayoutIncludesOpaqueBars = false;
        self.edgesForExtendedLayout = UIRectEdge.None;
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        
      
    }
    
    func openCalendarFromSuperViewController() {
            // open calendar page here
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let cal = stb.instantiateViewControllerWithIdentifier("calendarObj") as UIViewController
        self.navigationController?.pushViewController(cal, animated: true)
      
    }
    
    func openDiscoverFromSuperViewController() {
        
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Discover") as UIViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func openMyOrgsFromSuperViewController() {
        let viewController : OrgsViewController = OrgsViewController()
        viewController.title = "Find Orgs"
//         let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyOrgs") as UIViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func logoutClicked(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Are you sure you want to sign out?", message:
           nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Destructive, handler: {
            action in
            try! FIRAuth.auth()!.signOut()
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginScreen") as UIViewController
            let navController = UINavigationController(rootViewController: viewController)
            self.presentViewController(navController, animated: true, completion: nil)

            }
        )
        
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler:nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(noOfTimesControllerCameIntoView < 1){
            
            self.navigationController?.navigationBar.topItem?.title = "Your Profile"
            
            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor() // HIDES NAVIGATION TEXT
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont.systemFontOfSize(30, weight: UIFontWeightThin)]
            
            
            // MARK: - Scroll menu setup
            
            controllerArray = []
            controller1.title = BounceConstants.landingPagePageOneTitle()
            controllerArray.append(controller1)
            
            controller1.delegate1 = self
            controller1.discoverViewControllerDelegate1 = self
            controller1.openCalendar1 = self


            // Customize menu (Optional)
            let parameters: [CAPSPageMenuOption] = [
                
                .ScrollMenuBackgroundColor(UIColor.whiteColor()),
                .MenuItemWidth(0.0),
                .MenuHeight(0.0),
                .EnableHorizontalBounce(false) //Disables horizontal swipe problem
            ]
            
            // Initialize scroll menu
            
            pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0,0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
            
            
            self.addChildViewController(pageMenu!)
            
            self.view.addSubview(pageMenu!.view)
            
            pageMenu!.didMoveToParentViewController(self)
            
            for view in self.view.subviews {
                
                if(view.isKindOfClass(UIScrollView)){
                    
                    let view = view as! UIScrollView
                    view.scrollEnabled = false
                }
   
        }
        }
        noOfTimesControllerCameIntoView += 1
    }
    

    @IBAction func settingsButtonClicked(sender: AnyObject) {
        
        controller1.gearIconClicked()

        
    }
    
    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return true
    }
    
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutButton(sender: AnyObject) {
//        try! FIRAuth.auth()!.signOut()
//        self.performSegueWithIdentifier("logoutClicked", sender: nil)
    }
    
}
