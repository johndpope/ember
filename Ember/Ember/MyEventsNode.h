//
//  MyEventsNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "MyEventsPostDetailsNode.h"
#import "EmberSnapShot.h"

@import Firebase;

@protocol MyEventsImageClickedDelegate;

@interface MyEventsNode : ASCellNode <ASNetworkImageNodeDelegate>

@property (nonatomic, weak) id<MyEventsImageClickedDelegate> myEventsImageDelegate;
@property(strong, nonatomic) FIRDatabaseReference *ref;
- (instancetype)initWithEvent:(EmberSnapShot *)event;

-(ASNetworkImageNode*) getImageNode;
- (NSDictionary *)textStyle;
-(MyEventsPostDetailsNode*)getDetailsNode;
@end

@protocol MyEventsImageClickedDelegate <NSObject>

-(void)myEventsImageClicked:(EmberSnapShot*)snap;

@end

