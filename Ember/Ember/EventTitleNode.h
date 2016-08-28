//
//  EventTitleNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>
#import "EmberSnapShot.h"
#import "OrgNode.h"
@import Firebase;

@interface EventTitleNode : ASCellNode

@property(strong, nonatomic) FIRDatabaseReference *ref;
- (instancetype)initWithEvent:(EmberSnapShot*)event;

-(ASNetworkImageNode*) getImageNode;
- (NSDictionary *)textStyle;
-(ASTextNode *)getOrgNameNode;

@end