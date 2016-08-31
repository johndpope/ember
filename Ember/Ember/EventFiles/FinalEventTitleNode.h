//
//  FinalEventTitleNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/23/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EventTitleNode.h"
#import "EmberSnapShot.h"

@import Firebase;

@interface FinalEventTitleNode : ASCellNode

@property(strong, nonatomic) FIRDatabaseReference *ref;
- (instancetype)initWithEvent:(EmberSnapShot*)event mediaCount: (NSUInteger)mediaCount;
-(EventTitleNode *)getTitleNode;
-(ASNetworkImageNode *)getLocalNode;

@end
