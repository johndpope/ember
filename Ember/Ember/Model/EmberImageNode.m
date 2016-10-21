//
//  EmberImageNode.m
//  thrive
//
//  Created by Gabriel Wamunyu on 3/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmberImageNode.h"
#import "EmberDetailsNode.h"
#import "Video.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>


@import Firebase;

#define StrokeRoundedImages 0

// static const CGFloat kInnerPadding = 10.0f;
//static const CGFloat kOrgPhotoWidth = 75.0f;
//static const CGFloat kOrgPhotoHeight = 75.0f;


@interface EmberImageNode () <ASNetworkImageNodeDelegate, UIGestureRecognizerDelegate> {
    
    ASNetworkImageNode *_imageNode;
    ASDisplayNode *_divider;
    BOOL _swappedTextAndImage;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    EmberSnapShot*_snapShot;
    FIRUser *_user;
    FIRDatabaseReference *_ref;
    ASTextNode *_text;
    float _scale;
    float _imageHeight;
    CGFloat screenWidth;
    ASImageNode *_videoImageNode;
    ASButtonNode *_playNode;
    NSUInteger _mediaItemsCount;
    EmberDetailsNode* _emberDetailsNode;
    
}

@end

@implementation EmberImageNode


-(ASNetworkImageNode *)getImageNode{
    return _imageNode;
}

-(ASImageNode *)getVideoImageNode{
    return _videoImageNode;
}

-(EmberDetailsNode*)getDetailsNode{
    return _emberDetailsNode;
}

-(void)setFollowButtonHidden{
    [_emberDetailsNode setFollowButtonHidden];
 
}

-(void)showFireCount{
    [_emberDetailsNode showFireCount];
}

- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
     screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _emberDetailsNode = [[EmberDetailsNode alloc] initWithEvent:snapShot];
    
    self.isPoster = NO;
    
    _mediaItemsCount = 0;
    
    _user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _snapShot = snapShot;

    _imageNode = [[ASNetworkImageNode alloc] init];
    _imageNode.shouldRenderProgressImages = YES;
    
    [self addSubnode: _imageNode];
    [self addSubnode:_emberDetailsNode];

    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    _divider.spacingAfter = 5.0f;
    CGFloat pixelHeight = 1.0f;
    _divider.preferredFrameSize = CGSizeMake(screenWidth, pixelHeight);
    [self addSubnode:_divider];
    
    
    return self;
}

-(NSString*)truncateEventName:(NSString*)eventName{
    
    if([eventName length] < 30){
        return eventName;
    }
    
    // define the range you're interested in
    NSRange stringRange = {0, MIN([eventName length], 30)};
    
    
    // adjust the range to include dependent chars
    stringRange = [eventName rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *result = [eventName substringWithRange:stringRange];
    
  
    NSRange range = [result rangeOfString:@" " options:NSBackwardsSearch];
    
    if(range.location != NSNotFound){
        return [[result substringToIndex:range.location] stringByAppendingString:@"..."];
    }else{
        return eventName;
    }
    
}

-(void)sendNotif{
    
    NSDictionary *postDetails = [_snapShot getPostDetails];
    NSNumber *time = postDetails[@"eventDateObject"];
    NSString* eventName = postDetails[@"eventName"];

//    NSLog(@"current test for sendNotif");
//    NSLog(@"%@",time);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:-[time doubleValue]];
    
    NotificationItem *item = [[NotificationItem alloc] initWithDate:date title:eventName UUID:[[NSUUID UUID] UUIDString]];
    [[LocalNotifications sharedInstance] addItem:item];
    

}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    _imageNode.contentMode = UIViewContentModeScaleAspectFill;
    _imageNode.preferredFrameSize = CGSizeMake(screenWidth, screenWidth * 0.8);
    _emberDetailsNode.flexShrink = YES;
    _emberDetailsNode.preferredFrameSize = CGSizeMake(screenWidth, constrainedSize.min.height);
    
    ASLayoutSpec *horizontalSpacer =[ASLayoutSpec new];
    horizontalSpacer.flexGrow = YES;
    
    ASStackLayoutSpec *vert = nil;
    
    if(self.isPoster){
        vert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[_divider, _emberDetailsNode]];
    }else{
        vert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[_divider,_imageNode, _emberDetailsNode]];
    }
    
    
    
    return vert;
}



@end
