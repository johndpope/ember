//
//  OrgDetailsNode.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/15/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Firebase

@objc protocol OpenCreateEventDelegate: class {
    func openCreateEventViewController(orgID : NSString, orgName : NSString, orgProfileImage : NSString)
}

class OrgDetailsNode : ASCellNode {
    
    weak var delegate:OpenCreateEventDelegate?
    
    let noFollowers = ASTextNode()
    let noFollowersBelow = ASTextNode()
    
    let line = ASDisplayNode()
    
    let noEvents = ASTextNode()
    let noEventsBelow = ASTextNode()
    
    let orgDesc = ASTextNode()
    
    let createEventNode = ASTextNode()
    
    var star = ASImageNode()
    
    let background = ASButtonNode()
    
    let divider = ASDisplayNode()
    
    var localOrgInfo = EmberSnapShot()
    
    var isAdmin = false;
   
    
    override init() {
        super.init()
    }
    
    convenience init(orgInfo : EmberSnapShot) {
        self.init()
        
        let ref = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())
        
//        print(orgInfo.getData())
        
        delegate = nil
        
//        self.isAdmin = isAdmin;
        
        self.localOrgInfo = orgInfo
        let details  = orgInfo.getData() as NSDictionary
        
//        print(self.orgID)
//        print((self.localOrgInfo.objectForKey("orgName") as? String)!)
        
        // TODO : make range of string fit without having to add static spaces
        let stringFollowers = "      " as NSString
//        let spaces = String(count: 20, repeatedValue: (" " as Character))

        self.noFollowers.attributedText = NSMutableAttributedString(string: stringFollowers as String, attributes: self.textStyle())
        
        let stringFollow = "Followers"
        self.noFollowersBelow.attributedText = NSMutableAttributedString(string: stringFollow as String, attributes: self.textStyle())
        
        ref.child(BounceConstants.firebaseOrgsChild()).child(orgInfo.key).child("followers").observeEventType(.Value, withBlock: {(snapShot) in
            //            print("snapshot: \(snapShot)")
            
            var followerString = ""
            if(snapShot.childrenCount == 1){
               followerString = "Follower"
            }else{
                followerString = "Followers"
            }
            let stringFollowers = "\(snapShot.childrenCount)" as NSString
            let attr = NSMutableAttributedString(string: stringFollowers as String, attributes: self.textStyle())
            let attrChange = [NSForegroundColorAttributeName: UIColor.lightGrayColor()]
            attr.addAttributes(attrChange, range: stringFollowers.rangeOfString(followerString))
            self.noFollowers.attributedText = attr
            
            let stringFollowers2 = "\(followerString)" as NSString
            let attr2 = NSMutableAttributedString(string: stringFollowers2 as String, attributes: self.textStyle())
            let attrChange2 = [NSForegroundColorAttributeName: UIColor.lightGrayColor()]
            attr2.addAttributes(attrChange2, range: stringFollowers2.rangeOfString(followerString))
            self.noFollowersBelow.attributedText = attr2
            
            self.setNeedsLayout()
            
            
        })
        
        
        let stringEvents = "      " as NSString
        let attrEvents = NSMutableAttributedString(string: stringEvents as String, attributes: self.textStyle())
        self.noEvents.attributedText = attrEvents
        
        let stringEventsBelow = "Events"
        let attrEvents2 = NSMutableAttributedString(string: stringEventsBelow as String, attributes: self.textStyle())
        let attrEventsChange = [NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        attrEvents2.addAttributes(attrEventsChange, range: stringEvents.rangeOfString("Events"))
        self.noEventsBelow.attributedText = attrEvents2
        
        ref.child(BounceConstants.firebaseEventsChild()).queryOrderedByChild("orgID").queryEqualToValue(orgInfo.key).observeEventType(.Value, withBlock: {(snapShot) in
//            print("snapshot: \(snapShot)")
            
            let stringEvents = "\(snapShot.childrenCount)" as NSString
            let attrEvents = NSMutableAttributedString(string: stringEvents as String, attributes: self.textStyle())
            self.noEvents.attributedText = attrEvents
            
            let stringEvents2 = "Events" as NSString
            let attrEvents2 = NSMutableAttributedString(string: stringEvents2 as String, attributes: self.textStyle())
            let attrEventsChange2 = [NSForegroundColorAttributeName: UIColor.lightGrayColor()]
            attrEvents2.addAttributes(attrEventsChange2, range: stringEvents2.rangeOfString("Events"))
            self.noEventsBelow.attributedText = attrEvents2
            
            self.setNeedsLayout()
            
        })
        
    
        self.orgDesc.attributedText = NSAttributedString.init(string: (details.objectForKey("orgDesc") as? String)!, attributes: self.textStyle())
        self.createEventNode.attributedText = NSAttributedString.init(string: "Create Event", attributes: self.textStyleCreateEvent())
        
        self.createEventNode.addTarget(self, action: #selector(OrgDetailsNode.createEvent), forControlEvents: .TouchUpInside)
        self.background.addTarget(self, action: #selector(OrgDetailsNode.createEvent), forControlEvents: .TouchUpInside)

        
        self.star.image = UIImage(named: "eventCreation")
        
        self.background.backgroundColor = PRIMARY_APP_COLOR
        self.background.cornerRadius = 10 // value for corner radius
        self.background.clipsToBounds = true
       
        self.orgDesc.spacingAfter = CGFloat(30)
        
        line.backgroundColor = UIColor.lightGrayColor()
        line.preferredFrameSize = CGSizeMake(2, 30)
        
        divider.backgroundColor = UIColor.lightGrayColor()
        divider.preferredFrameSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 1)
        divider.spacingAfter = 30
        
        addSubnode(noFollowers)
        addSubnode(noFollowersBelow)
        addSubnode(noEvents)
        addSubnode(noEventsBelow)
        addSubnode(line)
        addSubnode(orgDesc)
        addSubnode(background)
        addSubnode(createEventNode)
        addSubnode(star)
        addSubnode(divider)
        
    }
    
    func createEvent(){

        let details  = localOrgInfo.getData() as NSDictionary
        delegate!.openCreateEventViewController(localOrgInfo.key, orgName: (details.objectForKey("orgName") as? String)!, orgProfileImage: (details.objectForKey("smallImageLink") as? String)!)
        
    }
    
    func getDelegate() -> OpenCreateEventDelegate{
        return delegate!
    }
    
    func setAdminStatus(isAdmin : Bool){
        self.isAdmin = isAdmin;
    }

    func textStyle() -> [String : NSObject]{
        
        var font = UIFont()
        if(Iphone5Test.isIphone5()){
            font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        }else{
            font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
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
    
    func textStyleCreateEvent() -> [String : NSObject]{
        
        var font = UIFont()
        if(Iphone5Test.isIphone5()){
            font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        }else{
            font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        }
 
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 0.5 * font.lineHeight
        style.alignment = NSTextAlignment.Center
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSFontAttributeName] = font
        multipleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        multipleAttributes[NSParagraphStyleAttributeName] = style
        
        return multipleAttributes
        
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        let kInsetHorizontal = CGFloat(16.0)
        let kInsetTop = CGFloat(6.0)
        let kInsetBottom = CGFloat(6.0)
        let kInsetFollowersLeft = CGFloat(20)
        
        
        self.divider.flexGrow = true
        
        self.background.flexGrow = true
        
        
        let horizontalSpacer = ASLayoutSpec()
        horizontalSpacer.flexGrow = true
        
        let hori = ASStackLayoutSpec(direction: .Vertical, spacing: 1.0, justifyContent: .Center, alignItems: .Center, children: [noFollowers, noFollowersBelow])
        
        let insetsFollowers = UIEdgeInsetsMake(0, kInsetFollowersLeft, 0, 10)
        let followingInset = ASInsetLayoutSpec(insets: insetsFollowers, child: hori)
 
        let vert = ASStackLayoutSpec(direction: .Horizontal, spacing: 1.0, justifyContent: .Center, alignItems: .Stretch, children: [horizontalSpacer, followingInset, horizontalSpacer])

        
        let hori_events = ASStackLayoutSpec(direction: .Vertical, spacing: 1.0, justifyContent: .Center, alignItems: .Center, children: [noEvents, noEventsBelow])
        
        let eventsInset = ASInsetLayoutSpec(insets: insetsFollowers, child: hori_events)
        
        let followingStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 5.0, justifyContent: .Center, alignItems: .Stretch, children: [horizontalSpacer, vert, horizontalSpacer, line, horizontalSpacer,eventsInset, horizontalSpacer])
        
        let insets = UIEdgeInsetsMake(kInsetTop, 0, kInsetBottom, 0)
        let followingSpecs = ASInsetLayoutSpec(insets: insets, child: followingStack)
        
        let createEventStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 10.0, justifyContent: .Center, alignItems: .Center, children: [star, createEventNode])
        
        createEventStack.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(
            ASRelativeDimensionMakeWithPercent(1), // Fill parent width
            ASRelativeDimensionMakeWithPoints(50))
        
        let createEventStaticLayout = ASStaticLayoutSpec(children: [createEventStack])
        
        let backStack = ASBackgroundLayoutSpec(child: createEventStaticLayout, background: background)
        let backStackInsets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: backStack)
        
        backStackInsets.spacingAfter = CGFloat(30)
        
        let orggDescInsets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: orgDesc)
        
        var finalStack = ASStackLayoutSpec()
        
        if(isAdmin){
            
            // TODO : adding divider twice not working
            
            finalStack = ASStackLayoutSpec(direction: .Vertical, spacing: 1.0, justifyContent: .Center, alignItems: .Center, children: [followingSpecs, orggDescInsets, divider, backStackInsets, divider])
        }else{
           finalStack = ASStackLayoutSpec(direction: .Vertical, spacing: 1.0, justifyContent: .Center, alignItems: .Center, children: [followingSpecs, orggDescInsets, divider])
        }
        
        return finalStack
        
    }
}


