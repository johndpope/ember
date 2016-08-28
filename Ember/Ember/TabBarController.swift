//
//  TabBarViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/3/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        // set red as selected background color
//        let numberOfItems = CGFloat(tabBar.items!.count)
//        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
//        tabBar.selectionIndicatorImage = UIImage.imageWithColor(UIColor.darkGrayColor(), size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
//        
//        // remove default border
//        tabBar.frame.size.width = self.view.frame.width + 4
//        tabBar.frame.origin.x = -2
//        UITabBar.appearance().tintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    }
    
}


//extension UIImage {
//    
//    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
//        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//    
//}
