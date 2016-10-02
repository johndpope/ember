//
//  HomeFeedHeaderNode.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 8/11/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//
import Foundation
import AsyncDisplayKit

@objc class HomeFeedHeaderNode : ASCellNode {
    
    let labelDesc = ASTextNode()
    let background  = ASDisplayNode()
    let divider = ASDisplayNode()

    
    convenience init(orgInfo : NSString) {
        self.init()
        
        self.labelDesc.attributedText = NSAttributedString(string: orgInfo as String, attributes: self.textStyle())
            
        self.background.backgroundColor = UIColor.whiteColor()
        divider.backgroundColor = UIColor.lightGrayColor()
        divider.preferredFrameSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 2)
        divider.spacingAfter = 30
        
        addSubnode(background)
        addSubnode(labelDesc)
        addSubnode(divider)
    }
 
    
    func textStyle() -> [String : NSObject]{
        
        var font = UIFont()
        if(Iphone5Test.isIphone5()){
           font = UIFont.systemFontOfSize(12.0)
        }else{
            font = UIFont.systemFontOfSize(14.0)
        }
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 0.5 * font.lineHeight
        style.alignment = .Left
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSFontAttributeName] = font
        multipleAttributes[NSForegroundColorAttributeName] = UIColor.darkGrayColor()
        multipleAttributes[NSParagraphStyleAttributeName] = style
        
        return multipleAttributes
        
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {

        self.divider.flexGrow = true
        
        self.background.flexGrow = true
        
        let horizontalSpacer = ASLayoutSpec()
        horizontalSpacer.flexGrow = true

        labelDesc.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(
            ASRelativeDimensionMakeWithPercent(1), // Fill parent width
            ASRelativeDimensionMakeWithPoints(50))
        
        let createEventStaticLayout = ASStaticLayoutSpec(children: [labelDesc])
        
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 0), child: createEventStaticLayout)
        
        let backStack = ASBackgroundLayoutSpec(child: insets, background: background)
        
        return backStack
        
    }
}


