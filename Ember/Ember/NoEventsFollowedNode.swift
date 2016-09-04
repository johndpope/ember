//
//  NoEventsFollowedNode.swift
//  Ember
//
//  Created by Gabriel Wamunyu on 9/4/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FirebaseAuth

class NoEventsFollowedNode: ASCellNode {
    
    let mediaText = ASTextNode()
    
    
    let font = UIFont.systemFontOfSize(14.0)
    let borderAlpha : CGFloat = 0.7
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    
    var ref:FIRDatabaseReference!
    
    override init() {
        super.init()
        
        self.mediaText.attributedText = NSAttributedString(string: "No events followed yet. Go ahead and follow one!", attributes:
            self.textStyle())
        
        addSubnode(mediaText)
        
    }
    
    
    
    func textStyle() -> [String : NSObject]{
        
        var font = UIFont()
        if(Iphone5Test.isIphone5()){
            font = UIFont.systemFontOfSize(14)
        }else{
            font = UIFont.systemFontOfSize(16)
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
        
        mediaText.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(
            ASRelativeDimensionMakeWithPercent(1),
            ASRelativeDimensionMakeWithPoints(50))
        
        let usernameStaticLayout = ASStaticLayoutSpec(children: [mediaText])
        
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), child: usernameStaticLayout)
        
        return insets
    }
    
}