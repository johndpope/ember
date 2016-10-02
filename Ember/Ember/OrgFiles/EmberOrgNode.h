//
//  EmberOrgNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//


#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EmberSnapShot.h"
#import "FollowNode.h"

@import Firebase;

@protocol FindOrgsImageClickedDelegate;

@interface EmberOrgNode : ASCellNode

@property (nonatomic, weak) id<FindOrgsImageClickedDelegate> findOrgsImageClickedDelegate;
-(instancetype)initWithOrg: (EmberSnapShot*) snapShot;
-(FollowNode*)getFollowNode;
@end

@protocol FindOrgsImageClickedDelegate <NSObject>
-(void)findOrgsImageClicked:(NSString*)orgId;
@end

