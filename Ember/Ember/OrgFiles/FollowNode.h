//
//  FollowNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EmberSnapShot.h"

@import Firebase;

@protocol FindOrgsFollowButtonClickedDelegate;

@interface FollowNode : ASControlNode

@property (nonatomic, weak) id<FindOrgsFollowButtonClickedDelegate> findOrgsFollowButtonClickedDelegate;
@property(strong, nonatomic) FIRDatabaseReference *ref;

-(instancetype)initWithSnapShot:(EmberSnapShot*)snapShot;
@end

@protocol FindOrgsFollowButtonClickedDelegate <NSObject>
-(void)findOrgsFollowButtonClicked:(EmberSnapShot*)snap;
@end

