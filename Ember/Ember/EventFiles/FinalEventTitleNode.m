//
//  FinalEventTitleNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/23/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FinalEventTitleNode.h"
#import "Video.h"
#import "OrgNode.h"
#import "EventTitleNode.h"
#import "Ember-Swift.h"


#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;

//static const CGFloat kOrgPhotoWidth = 75.0f;
//static const CGFloat kOrgPhotoHeight = 75.0f;

@interface FinalEventTitleNode (){
    
    EventTitleNode *_eventTitleNode;
    ASDisplayNode *_divider;
//    ASNetworkImageNode *_orgProfilePhoto;
    ASButtonNode *_orgButton;
    NSDictionary *event;
    OrgNode *_orgNode;
    
}

@end


@implementation FinalEventTitleNode

-(EventTitleNode *)getTitleNode{
    return _eventTitleNode;
}

-(OrgNode *)getOrgNode{
    return _orgNode;
}


- (instancetype)initWithEvent:(EmberSnapShot*)snapShot mediaCount:(NSUInteger)mediaCount{
    if (!(self = [super init]))
        return nil;
    
    _eventTitleNode = [[EventTitleNode alloc] initWithEvent:snapShot mediaCount: mediaCount];
    
//    NSDictionary *eventDetails = [snapShot getPostDetails];
    
    _orgButton = [[ASButtonNode alloc] init];
    [_orgButton addTarget:self action:@selector(orgProfileRequested) forControlEvents:ASControlNodeEventTouchDown];
//    _orgProfilePhoto = [[ASNetworkImageNode alloc] init];
//    _orgProfilePhoto.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
//    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
//    _orgProfilePhoto.cornerRadius = kOrgPhotoWidth / 2;
//    _orgProfilePhoto.imageModificationBlock = ^UIImage *(UIImage *image) {
//        
//        UIImage *modifiedImage;
//        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
//        
//        UIGraphicsBeginImageContextWithOptions(image.size, false, [[UIScreen mainScreen] scale]);
//        
//        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kOrgPhotoWidth] addClip];
//        [image drawInRect:rect];
//        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
//        
//        UIGraphicsEndImageContext();
//        
//        return modifiedImage;
//    };
//    
//    _orgProfilePhoto.URL = [NSURL URLWithString:eventDetails[@"smallImageLink"]];
//    [_orgProfilePhoto setBorderWidth:3];
//    [_orgProfilePhoto setBorderColor:[[UIColor whiteColor] CGColor]];
    
    _orgNode = [[OrgNode alloc] initWithBounceSnapShot:snapShot mediaCount:mediaCount];
    
    [self addSubnode:_orgNode];
    [self addSubnode:_eventTitleNode];
//    [self addSubnode:_orgProfilePhoto];
    [self addSubnode:_orgButton];
    
    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    [self addSubnode:_divider];
    
    return self;
}


-(void)orgProfileRequested{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OrgPhotoClicked"
     object:self];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGFloat kInnerPadding = 10.0f;
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
//    _orgProfilePhoto.layoutPosition = CGPointMake(10, width - kOrgPhotoHeight / 2);
    _eventTitleNode.preferredFrameSize = CGSizeMake(width, constrainedSize.min.height);
    
      ASInsetLayoutSpec *specOrgNode = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(kInnerPadding, 10, kInnerPadding, 10) child:_orgNode];
    
//    ASStackLayoutSpec *horizontal = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[_orgProfilePhoto, specOrgNode]];
    
//    ASOverlayLayoutSpec *bG = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_orgProfilePhoto overlay:_orgButton];
//    bG.layoutPosition = CGPointMake(10, width - kOrgPhotoWidth / 2);
//    ASStaticLayoutSpec *badgePosition = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[bG]];
//    ASOverlayLayoutSpec *overlay = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_eventTitleNode overlay:badgePosition];
    
    ASStackLayoutSpec *vert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[specOrgNode, _eventTitleNode]];
    
    return vert;
}
@end
