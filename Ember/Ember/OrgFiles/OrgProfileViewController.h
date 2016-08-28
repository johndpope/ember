//
//  OrgProfileViewController.h
//  bounceapp
//
//  Created by Michael Umenta on 7/11/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "EmberNode.h"
#import "EmberSnapShot.h"

@import Firebase;

@interface OrgProfileViewController : ASViewController
@property(strong, nonatomic) FIRDatabaseReference *ref;
@property(nonatomic) EmberSnapShot *eventNode;
@property(nonatomic) NSString *orgId;
@end


