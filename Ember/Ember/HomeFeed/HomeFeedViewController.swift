//
//  FirstViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/3/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class HomeFeedViewController: UIViewController {
    
    //private var statusBarHidden = true
    var pageMenu : CAPSPageMenu?
    var controllerArray : [UIViewController] = []
    let controller1  = HomefeedController()
    let controller2 = MyEventsViewController()
    let controller3 : OrgsViewController = OrgsViewController()
    var noOfTimesControllerCameIntoView = 0
    
    var fullView : UIImageView?
    var temp : UIImageView?
    
    
//    @IBAction func searchClicked(sender: UIBarButtonItem) {
//        self.performSegueWithIdentifier("OpenSearch", sender:self)
//
//    }
    
    @IBAction func notificationsClicked(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("notSegue", sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBarController?.delegate = self
        self.tabBarController?.tabBar.translucent = false
        
        
        // MARK: - Scroll menu setup
        let controller1  = HomefeedController()
        controllerArray.append(controller1)
        let controller2 : MyEventsViewController = MyEventsViewController()
        controllerArray.append(controller2)
        let controller3 : OrgsViewController = OrgsViewController()
        controllerArray.append(controller3)
        self.extendedLayoutIncludesOpaqueBars = false;
        self.edgesForExtendedLayout = UIRectEdge.None;
           }

    
    func launchCamera() {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CameraViewController") as UIViewController        
        let navController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func openProfile(){
        let viewController = NewProfileViewController()
        let navController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: - UI Setup
        
        if(noOfTimesControllerCameIntoView < 1){
            //self.title = "Fyre"
            
            self.navigationController?.navigationBar.topItem?.title = "Ember"
            
            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            //self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName:UIFont.systemFontOfSize(30, weight: UIFontWeightThin)]
            
            // MARK: - Scroll menu setup
            // Initialize view controllers to display and place in array
            controllerArray = []
            controller1.title = BounceConstants.landingPagePageOneTitle()
            controllerArray.append(controller1)
            controller2.title = BounceConstants.landingPagePageTwoTitle()
            controllerArray.append(controller2)
            controller3.title = BounceConstants.landingPagePageThreeTitle()
            controllerArray.append(controller3)
            
            
            // Customize menu (Optional)
            let parameters: [CAPSPageMenuOption] = [
                .ScrollMenuBackgroundColor(UIColor.whiteColor()),
                //.ViewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
                .SelectionIndicatorColor(PRIMARY_APP_COLOR),
                .BottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
                .MenuItemFont(UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)),
                .MenuHeight(40.0),
                .MenuItemWidth(90.0),
                .CenterMenuItems(true)
            ]
            
            // Initialize scroll menu
            
            pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0,0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
            
            
            self.addChildViewController(pageMenu!)
            
            self.view.addSubview(pageMenu!.view)
            
            pageMenu!.didMoveToParentViewController(self)
            
            
        }
        noOfTimesControllerCameIntoView += 1
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func didTapGoToLeft() {
        let currentIndex = pageMenu!.currentPageIndex
        
        if currentIndex > 0 {
            pageMenu!.moveToPage(currentIndex - 1)
        }
    }
    
    func didTapGoToRight() {
        let currentIndex = pageMenu!.currentPageIndex
        
        if currentIndex < pageMenu!.controllerArray.count {
            pageMenu!.moveToPage(currentIndex + 1)
        }
    }
    
    // MARK: - Container View Controller
    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return true
    }
    
    
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    

}
 //MARK: Tab Bar Delegate

extension HomeFeedViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            //launchCamera()
            self.performSegueWithIdentifier("OpenSearch", sender:self)
            return false
        }else if(viewController is NewProfileViewController){
            openProfile()
            return false
        }
        else {
            return true
        }
    }
    
}
