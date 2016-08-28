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

static const CGFloat kOrgPhotoWidth = 75.0f;
static const CGFloat kOrgPhotoHeight = 75.0f;

@interface FinalEventTitleNode (){
    
    EventTitleNode *_eventTitleNode;
    ASDisplayNode *_divider;
    ASNetworkImageNode *_orgProfilePhoto;
    ASButtonNode *_orgButton;
    NSDictionary *event;
    
}

@end


@implementation FinalEventTitleNode

-(EventTitleNode *)getTitleNode{
    return _eventTitleNode;
}

-(ASNetworkImageNode *)getLocalNode{
    return _orgProfilePhoto;
}



- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    _eventTitleNode = [[EventTitleNode alloc] initWithEvent:snapShot];
    
    NSDictionary *eventDetails = [snapShot getPostDetails];

    
    _orgButton = [[ASButtonNode alloc] init];
    [_orgButton addTarget:self action:@selector(orgProfileRequested) forControlEvents:ASControlNodeEventTouchDown];
    _orgProfilePhoto = [[ASNetworkImageNode alloc] init];
    _orgProfilePhoto.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
    _orgProfilePhoto.cornerRadius = kOrgPhotoWidth / 2;
    _orgProfilePhoto.imageModificationBlock = ^UIImage *(UIImage *image) {
        
        UIImage *modifiedImage;
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, [[UIScreen mainScreen] scale]);
        
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kOrgPhotoWidth] addClip];
        [image drawInRect:rect];
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return modifiedImage;
    };
    
    _orgProfilePhoto.URL = [NSURL URLWithString:eventDetails[@"smallImageLink"]];
    [_orgProfilePhoto setBorderWidth:3];
    [_orgProfilePhoto setBorderColor:[[UIColor whiteColor] CGColor]];
    
    
    [self addSubnode:_eventTitleNode];
    [self addSubnode:_orgProfilePhoto];
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
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
    _orgProfilePhoto.layoutPosition = CGPointMake(10, width - kOrgPhotoHeight / 2);
    _eventTitleNode.preferredFrameSize = CGSizeMake(width, constrainedSize.min.height);
    ASOverlayLayoutSpec *bG = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_orgProfilePhoto overlay:_orgButton];
    bG.layoutPosition = CGPointMake(10, width - kOrgPhotoWidth / 2);
    ASStaticLayoutSpec *badgePosition = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[bG]];
    ASOverlayLayoutSpec *overlay = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_eventTitleNode overlay:badgePosition];
    
    return overlay;
}
@end
