//
//  EventViewController.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/20/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "EmberSnapShot.h"
#import "EmberNode.h"

@import Firebase;

@interface EventViewController : ASViewController
@property(strong, nonatomic) FIRDatabaseReference *ref;
@property(nonatomic) EmberSnapShot *eventNode;
@property(nonatomic) BOOL isFromSearch;
@end
