//
//  FinalOrgTitleNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/15/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FinalOrgTitleNode.h"
#import "SubOrgTitleNode.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;

static const CGFloat kOrgPhotoWidth = 75.0f;
static const CGFloat kOrgPhotoHeight = 75.0f;

@interface FinalOrgTitleNode (){
    
    SubOrgTitleNode *_suborgTitleNode;
    ASDisplayNode *_divider;
    ASNetworkImageNode *_orgProfilePhoto;
    NSDictionary *event;
    ASButtonNode *_orgButton;
    
}

@end


@implementation FinalOrgTitleNode

-(SubOrgTitleNode *)getSubOrgTitleNode{
    return _suborgTitleNode;
}

-(ASNetworkImageNode *)getLocalNode{
    return _orgProfilePhoto;
}


- (instancetype)initWithEvent:(EmberSnapShot*)orgInfo{
    if (!(self = [super init]))
        return nil;
    
    _suborgTitleNode = [[SubOrgTitleNode alloc] initWithEvent:orgInfo];
//    _suborgTitleNode.orgID = self.orgID;

    _orgButton = [[ASButtonNode alloc] init];
    _orgProfilePhoto = [[ASNetworkImageNode alloc] init];
    _orgProfilePhoto.layerBacked = YES;
 
    _orgProfilePhoto.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
    _orgProfilePhoto.cornerRadius = kOrgPhotoHeight / 2;
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
    
 
    [_orgProfilePhoto setBorderWidth:3];
    [_orgProfilePhoto setBorderColor:[[UIColor whiteColor] CGColor]];
    
    NSDictionary *orgDetails = [orgInfo getData];
    
    _orgProfilePhoto.URL = [NSURL URLWithString:orgDetails[[BounceConstants firebaseOrgsChildSmallImageLink]]];

    
    [self addSubnode:_suborgTitleNode];
    [self addSubnode:_orgProfilePhoto];
    
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Bringing org node up to halfway point of image at the bottom
    // using image landscape ratio of 4 : 3
    CGFloat height  = width * 3/4;
    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
    _orgProfilePhoto.layoutPosition = CGPointMake(10, height - kOrgPhotoHeight / 2);
//    ASOverlayLayoutSpec *bG = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_orgProfilePhoto overlay:_orgButton];
//    bG.layoutPosition = CGPointMake(10, height - kOrgPhotoHeight / 2);
    ASStaticLayoutSpec *badgePosition = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[_orgProfilePhoto]];
    ASOverlayLayoutSpec *overlay = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_suborgTitleNode overlay:badgePosition];
    
    return overlay;
}
@end
