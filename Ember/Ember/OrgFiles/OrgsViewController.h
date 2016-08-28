//
//  OrgsViewController.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
@import Firebase;

@interface OrgsViewController : ASViewController
@property(strong, nonatomic) FIRDatabaseReference *ref;
@end

