//
//  SearchViewController.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/2/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation


class SearchViewController : UIViewController{
    
    var pageMenu : CAPSPageMenu?
    var controllerArray : [UIViewController] = []
    let controller1 : SearchEventsViewController = SearchEventsViewController()
    let controller2 : SearchOrgsViewController = SearchOrgsViewController()
    let searchController = UISearchController(searchResultsController: nil)
    var noOfTimesControllerCameIntoView = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.navigationItem.titleView = searchController.searchBar
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(SearchViewController.doneButtonPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = PRIMARY_APP_COLOR
        
        
    }
    
    func doneButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: - UI Setup
        
        if(noOfTimesControllerCameIntoView < 1){
            
            //self.title = "Fyre"
            
            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
            self.navigationController?.navigationBar.tintColor = PRIMARY_APP_COLOR
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR, NSFontAttributeName: UIFont.systemFontOfSize(30, weight: UIFontWeightThin)]
            
            
            // MARK: - Scroll menu setup
            // Initialize view controllers to display and place in array
            //var controllerArray : [UIViewController] = []
            controllerArray = []
            controller1.title = BounceConstants.searchEventsPageTitle()
            controllerArray.append(controller1)
            controller2.title = BounceConstants.searchOrgsPageTitle()
            controllerArray.append(controller2)
            
            // Customize menu (Optional)
            let parameters: [CAPSPageMenuOption] = [
                .ScrollMenuBackgroundColor(UIColor.whiteColor()),
                //.ViewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
                .SelectionIndicatorColor(PRIMARY_APP_COLOR),
                .BottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
                .MenuItemFont(UIFont.systemFontOfSize(13, weight: UIFontWeightLight)),
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
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        NSNotificationCenter.defaultCenter().postNotificationName(BounceConstants.searchNotificationName(), object: searchText)
        
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


extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

