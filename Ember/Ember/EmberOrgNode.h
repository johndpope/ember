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

@import Firebase;

@interface EmberOrgNode : ASCellNode
-(instancetype)initWithOrg: (EmberSnapShot*) snapShot;
@end

