//
//  MyEventsPostDetailsNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 8/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EmberSnapShot.h"

@import Firebase;

@protocol MyEventsNodeDelegate;

@protocol MyEventsOrgImageClickedDelegate;

@protocol MyEventsCameraClickedDelegate;

@interface MyEventsPostDetailsNode : ASCellNode <ASNetworkImageNodeDelegate>


@property (nonatomic, weak) id<MyEventsNodeDelegate> myEventsNodeDelegate;
@property (nonatomic, weak) id<MyEventsOrgImageClickedDelegate> myEventsOrgImageDelegate;
@property (nonatomic, weak) id<MyEventsCameraClickedDelegate> myEventsCamerClickedDelegate;
@property(strong, nonatomic) FIRDatabaseReference *schoolRootRef;
- (instancetype)initWithEvent:(EmberSnapShot *)event;

-(ASTextNode *) getTextNode;
@end

@protocol MyEventsNodeDelegate <NSObject>

-(void)unfollowClicked:(NSString*)snapshotKey;

@end

@protocol MyEventsOrgImageClickedDelegate <NSObject>

-(void)orgClicked:(NSString*)orgId;

@end

@protocol MyEventsCameraClickedDelegate <NSObject>

-(void)openCamera:(NSString*)eventId eventDate:(NSString*)eventDate eventTime:(NSString*)eventTime orgId:(NSString*)orgId homefeedMediaKey:(NSString*)homefeedMediaKey orgProfileImage:(NSString*)orgProfileImage eventDateObject:(NSNumber*)eventDateObject eventName:(NSString*)eventName;

@end

