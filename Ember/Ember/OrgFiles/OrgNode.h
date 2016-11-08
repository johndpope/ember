//
//  OrgNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/22/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EmberSnapShot.h"

@import Firebase;

@interface OrgNode : ASCellNode

@property(strong, nonatomic) FIRDatabaseReference *ref;
- (instancetype)initWithBounceSnapShot:(EmberSnapShot*)snap mediaCount:(NSUInteger) mediaCount;

- (NSDictionary *)textStyle;
-(ASTextNode*)getFireCount;
-(ASNetworkImageNode *)getLocalNode;
@end
