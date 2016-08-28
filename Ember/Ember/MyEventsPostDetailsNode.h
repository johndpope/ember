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

@interface MyEventsPostDetailsNode : ASCellNode <ASNetworkImageNodeDelegate>


@property (nonatomic, weak) id<MyEventsNodeDelegate> myEventsNodeDelegate;
@property (nonatomic, weak) id<MyEventsOrgImageClickedDelegate> myEventsOrgImageDelegate;
@property(strong, nonatomic) FIRDatabaseReference *ref;
- (instancetype)initWithEvent:(EmberSnapShot *)event;

-(ASTextNode *) getTextNode;
@end

@protocol MyEventsNodeDelegate <NSObject>

-(void)unfollowClicked:(NSString*)snapshotKey;

@end

@protocol MyEventsOrgImageClickedDelegate <NSObject>

-(void)orgClicked:(NSString*)orgId;

@end

