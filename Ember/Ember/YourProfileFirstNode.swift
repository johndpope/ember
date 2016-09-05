//
//  YourProfileFirstNode.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 8/10/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FirebaseAuth

@objc protocol OpenMyOrgsDelegate: class {
    func openMyOrgsViewController()
}

@objc protocol OpenDiscoverPageDelegate: class {
    func openDiscoverViewController()
}

@objc protocol OpenCalendarPageDelegate: class {
    func openCalendarViewController()
}

class YourProfileFirstNode: ASCellNode {
    
    let discoverButton = ASButtonNode()
    let myOrgsButton = ASButtonNode()
    let calendarButton = ASButtonNode()
    let userName = ASTextNode()
    let emailText = ASTextNode()
    let mediaText = ASTextNode()
    
    
    let font = UIFont.systemFontOfSize(14.0)
    let borderAlpha : CGFloat = 0.7
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    
    weak var delegate:OpenMyOrgsDelegate?
    weak var discoverViewControllerDelegate: OpenDiscoverPageDelegate?
    weak var openCalendarDelegate: OpenCalendarPageDelegate?
    
    var ref:FIRDatabaseReference!
    
    override init() {
        super.init()
        
        
        
        delegate = nil
        discoverViewControllerDelegate = nil
        openCalendarDelegate = nil
        
        formatDiscoverButton()
        
       formatMyOrgsButton()
        
        formatCalendarButton()
        
        
        self.emailText.attributedString = NSAttributedString(string: " ", attributes: self.textStyle())
        self.emailText.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, self.emailText.attributedString!.size().height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, self.emailText.attributedString!.size().height)))
        
        self.userName.attributedString = NSAttributedString(string: " ", attributes: self.textStyle())
        self.userName.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, self.userName.attributedString!.size().height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, self.userName.attributedString!.size().height)))
        
        fetchAndUpdateUserDetails()

 
        self.mediaText.attributedText = NSAttributedString(string: "My Photos and Videos")
        mediaText.spacingAfter = 10
        
        addSubnode(userName)
        addSubnode(emailText)
        addSubnode(discoverButton)
        addSubnode(myOrgsButton)
        addSubnode(mediaText)
        addSubnode(calendarButton)
    }
    
    func fetchAndUpdateUserDetails(){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())
        
        ref.child(BounceConstants.firebaseUsersChild()).child(uid!).observeSingleEventOfType(.Value, withBlock: { (snap) in
            
            if let val = snap.value as? NSDictionary{
                
                if((val.objectForKey("username")) != nil){
                    self.userName.attributedString = NSAttributedString(string: val.objectForKey("username") as! String, attributes: self.textStyle())
                }
                self.emailText.attributedString = NSAttributedString(string: val.objectForKey("email-address") as! String, attributes: self.textStyle())
            }
            
        })
        
    }
    
    func formatCalendarButton(){
        
        calendarButton.setTitle("Ember Calendar", withFont: font, withColor: UIColor.whiteColor(), forState: .Normal)
        calendarButton.setTitle("Ember Calendar", withFont: font, withColor: UIColor.whiteColor(), forState: .Highlighted)
        calendarButton.backgroundColor = PRIMARY_APP_COLOR
        calendarButton.cornerRadius = 4
        calendarButton.borderWidth = 1.0
        calendarButton.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        calendarButton.addTarget(self, action: #selector(YourProfileFirstNode.highlightCalendar), forControlEvents: .TouchDown)
        calendarButton.addTarget(self, action: #selector(YourProfileFirstNode.openCalendarPage), forControlEvents: .TouchUpInside)
    }
    
    func formatDiscoverButton(){
        
        discoverButton.setTitle("Explore", withFont: font, withColor: UIColor.whiteColor(), forState: .Normal)
        discoverButton.setTitle("Explore", withFont: font, withColor: UIColor.whiteColor(), forState: .Highlighted)
        discoverButton.backgroundColor = PRIMARY_APP_COLOR
        discoverButton.cornerRadius = 4
        discoverButton.borderWidth = 1.0
        discoverButton.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        discoverButton.addTarget(self, action: #selector(YourProfileFirstNode.highlightDiscover), forControlEvents: .TouchDown)
        discoverButton.addTarget(self, action: #selector(YourProfileFirstNode.openDiscoverPage), forControlEvents: .TouchUpInside)
    }
    
    func formatMyOrgsButton(){
        
        myOrgsButton.setTitle("My Orgs", withFont: font, withColor: UIColor.whiteColor(), forState: .Normal)
        myOrgsButton.backgroundColor = PRIMARY_APP_COLOR
        myOrgsButton.cornerRadius = 4
        myOrgsButton.borderWidth = 1.0
        myOrgsButton.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        myOrgsButton.addTarget(self, action: #selector(YourProfileFirstNode.highlightOrgs), forControlEvents: .TouchDown)
        myOrgsButton.addTarget(self, action: #selector(YourProfileFirstNode.openMyOrgs), forControlEvents: .TouchUpInside)
    }
    
    func highlightCalendar(){
        calendarButton.backgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 101.0/255.0, alpha: 1.0)
    }
    
 
    func highlightDiscover(){
        discoverButton.backgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 101.0/255.0, alpha: 1.0)
    }
    
    func highlightOrgs(){
        myOrgsButton.backgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 101.0/255.0, alpha: 1.0)
    }
    
    func openCalendarPage(){
        calendarButton.backgroundColor = PRIMARY_APP_COLOR
        openCalendarDelegate!.openCalendarViewController()
        
     
    }
    
    func openDiscoverPage(){
        discoverButton.backgroundColor = PRIMARY_APP_COLOR
        discoverViewControllerDelegate!.openDiscoverViewController()
    }
    func openMyOrgs(){
        myOrgsButton.backgroundColor = PRIMARY_APP_COLOR
        delegate!.openMyOrgsViewController()
    }
    
    func textStyle() -> [String : NSObject]{
        
        var font = UIFont()
        if(Iphone5Test.isIphone5()){
            font = UIFont.systemFontOfSize(18, weight: UIFontWeightRegular)
        }else{
            font = UIFont.systemFontOfSize(20, weight: UIFontWeightRegular)
        }
  
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 0.5 * font.lineHeight
        style.alignment = NSTextAlignment.Center
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSFontAttributeName] = font
        multipleAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        multipleAttributes[NSParagraphStyleAttributeName] = style
        
        return multipleAttributes
        
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        discoverButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(
            ASRelativeDimensionMakeWithPercent(1),
            ASRelativeDimensionMakeWithPoints(30))
        
        myOrgsButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(
            ASRelativeDimensionMakeWithPercent(1), 
            ASRelativeDimensionMakeWithPoints(30))
        
        calendarButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(
            ASRelativeDimensionMakeWithPercent(1),
            ASRelativeDimensionMakeWithPoints(30))
        
        let usernameStaticLayout = ASStaticLayoutSpec(children: [userName])
        let emailStaticLayout = ASStaticLayoutSpec(children: [emailText])
        
        usernameStaticLayout.spacingBefore = 30
        usernameStaticLayout.spacingAfter = 10
        
        emailStaticLayout.spacingAfter = 30
        
        let createEventStaticLayout = ASStaticLayoutSpec(children: [discoverButton])
        
        
        let createEventStaticLayoutOrgs = ASStaticLayoutSpec(children: [myOrgsButton])
        
        let calendarStatic = ASStaticLayoutSpec(children: [calendarButton])
        
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: createEventStaticLayout)
        let insetsCalendar = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: calendarStatic)
        let insetsOrgs = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: createEventStaticLayoutOrgs)
        
        insets.spacingAfter = 5
        insetsOrgs.spacingAfter = 5
        insetsCalendar.spacingAfter = 30
        
        let stackVert = ASStackLayoutSpec(direction: .Vertical, spacing: 1.0, justifyContent: .Center, alignItems: .Center, children: [usernameStaticLayout ,emailStaticLayout, insets, insetsOrgs,insetsCalendar, mediaText])
        
        
        
        return stackVert
    }
    
}