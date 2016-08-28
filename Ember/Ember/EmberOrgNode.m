//
//  EmberOrgNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>

#import "EmberOrgNode.h"
#import "FollowNode.h"

#import "bounceapp-Swift.h"

@import Firebase;

static const CGFloat kInnerPadding = 10.0f;

@interface EmberOrgNode (){
    
    ASTextNode *_textNode;
    ASDisplayNode *_divider;
    UIImage *_placeholderImage;
    FIRDataSnapshot*_snapShot;
    ASDisplayNode *background;
    ASNetworkImageNode *_imageNode;
    FollowNode *_followNode;

}

@end

@implementation EmberOrgNode

-(instancetype)initWithOrg: (EmberSnapShot*) snapShot{
    if (!(self = [super init]))
        return nil;
    
    NSDictionary* org = snapShot.getPostDetails;
    background = [[ASDisplayNode alloc] init];
    background.flexGrow = YES;
    background.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    background.layerBacked = YES;
    
    _imageNode = [[ASNetworkImageNode alloc] init];
    _imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _imageNode.URL = [[NSURL alloc] initWithString:org[[BounceConstants firebaseOrgsChildLargeImageLink]]];
    
    _imageNode.layerBacked = YES;
    
    [self addSubnode: _imageNode];
    [self addSubnode:background];
    
    _textNode = [[ASTextNode alloc] init];
    _textNode.attributedString = [[NSAttributedString alloc] initWithString:org[[BounceConstants firebaseOrgsChildOrgName]]
                                                                 attributes:[self textStyle]];
    
    [self addSubnode:_textNode];
    
    
    _followNode = [[FollowNode alloc] initWithSnapShot:snapShot];
    _followNode.borderColor = [UIColor whiteColor].CGColor;
    _followNode.borderWidth = 2.0f;
    _followNode.cornerRadius = 5.0f;
    _followNode.userInteractionEnabled = YES;
    
    
    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    [self addSubnode:_divider];
    
     [self addSubnode:_followNode];
    
    return self;
}




- (NSDictionary *)textStyle{
    UIFont *font = [UIFont systemFontOfSize:30.0f];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
//    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGFloat kInsetHorizontal = 16.0;
    CGFloat kInsetTop = 6.0;
    CGFloat kInsetBottom = 6.0;
    
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _imageNode.preferredFrameSize = CGSizeMake(width, width);
    _textNode.flexShrink = YES;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, kInsetHorizontal, kInsetBottom, kInsetHorizontal);
    
    NSArray *info = @[_textNode, _followNode];
    
    ASStackLayoutSpec *infoStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:3.0
                                                                    justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:info];
    
    ASInsetLayoutSpec *spec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:infoStack];
    spec.flexGrow = YES;

    
    ASOverlayLayoutSpec *bG = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_imageNode overlay:background];
    
    ASOverlayLayoutSpec *overlay = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:bG overlay:infoStack];
    
    ASInsetLayoutSpec *lastSpecs = [[ASInsetLayoutSpec alloc] init];
    lastSpecs.insets = UIEdgeInsetsMake(kInnerPadding, 0, kInnerPadding, 0);
    lastSpecs.child = overlay;
    
    return overlay;
}

@end
