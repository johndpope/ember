//
//  CounterView.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/12/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.


import UIKit
import AsyncDisplayKit
import FirebaseAuth

@objc class CounterView: UIView {
    
    enum Placement {
        case Header, Footer
    }
    
    var yOffsets: [CGFloat] = []
    
    var placement = Placement.Header
    
    var snap = EmberSnapShot()
    var count: Int
    let countLabel = UILabel()
    let userName = UILabel()
    var mediaInfo = NSArray()
    
    
    var currentIndex: Int {
        didSet {
            updateLabel(snap)
        }
    }
    
    init(frame: CGRect, node : EmberNode, currentIndex: Int, count: Int, placement : Placement, mediaInfo : NSArray) {
        
        self.currentIndex = currentIndex
        self.count = count
        self.placement = placement
        self.snap = node.getBounceSnapShot()
        self.mediaInfo = mediaInfo
        
        super.init(frame: frame)
        
        configureLabel()
        updateLabel(node.getBounceSnapShot())
    }
    
    // For objective-C : Enums don't work with objective-C hence can't use it as a parameter
    convenience init(frame: CGRect, node:EmberNode, currentIndex: Int, count: Int, index : Int, mediaInfo : NSArray) {
        
        var placement = Placement.Header
        
        if(index == 0){
            placement = .Header
        }else{
            placement = .Footer
        }
        
        self.init(frame : frame, node: node, currentIndex: currentIndex, count: count, placement : placement, mediaInfo: mediaInfo)
        
        self.currentIndex = currentIndex
        self.count = count
        self.placement = placement
        self.snap = node.getBounceSnapShot()
        self.mediaInfo = mediaInfo
 
        configureLabel()
        updateLabel(node.getBounceSnapShot())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        
        if(placement == .Header){
            countLabel.textAlignment = .Center
            countLabel.top = 10
        }else{
//           countLabel.textAlignment = .Left // left alignment not proper
            countLabel.textAlignment = .Center
        }
        
        countLabel.numberOfLines = 2
        
        userName.textAlignment = .Center
        
        self.addSubview(countLabel)
        
        if(placement == .Footer){
            self.addSubview(userName)
        }
        
    }
    
    
    func updateLabel(snap : EmberSnapShot) {
        
        let mediaDict = mediaInfo.objectAtIndex(currentIndex) as! NSDictionary
        
        var mediaLink = String()
        
        if mediaDict.objectForKey("mediaCaption") as! String != "(null)" {
            mediaLink = mediaDict.objectForKey("mediaCaption") as! String
        }
        
        
//        print(mediaLink)
        
        let uid = mediaDict.objectForKey("userID") as! String
        var stringTemplate = String()
        
        if(placement == .Header){
            stringTemplate = "%d of %d"
        }else{
            stringTemplate = mediaLink
        }
        

            //        print(uid)
            
            
            let ref = FIRDatabase.database().referenceWithPath(BounceConstants.firebaseSchoolRoot())
            
            ref.child(BounceConstants.firebaseUsersChild()).child(uid).child("username").observeSingleEventOfType(.Value, withBlock: {
                (snap) in
                //                print("couterview username: \(snap)")
                
                if(snap.value !== NSNull()){
                    self.userName.attributedText = NSAttributedString(string: snap.value as! String, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()])
                }
                
            })
            
            
            let countString = String(format: stringTemplate, arguments: [currentIndex + 1, count])
            
            countLabel.attributedText = NSAttributedString(string: countString, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel.frame = CGRectMake(countLabel.frame.origin.x, countLabel.frame.origin.y - 20, UIScreen.mainScreen().bounds.size.width, 48)
        userName.frame = CGRectMake(countLabel.frame.origin.x, countLabel.frame.origin.y + 48, UIScreen.mainScreen().bounds.size.width, 24)
       
    }
    
}

