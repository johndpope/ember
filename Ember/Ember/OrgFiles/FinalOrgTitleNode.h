//
//  FinalOrgTitleNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/15/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EmberSnapShot.h"

#import "SubOrgTitleNode.h"

@import Firebase;

@interface FinalOrgTitleNode : ASCellNode

@property(strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) NSString *orgID;
- (instancetype)initWithEvent:(EmberSnapShot*)orgInfo;
-(ASNetworkImageNode *)getLocalNode;
-(SubOrgTitleNode *)getSubOrgTitleNode;

@end
