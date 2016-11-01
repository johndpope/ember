//
//  CameraViewController.h
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/26/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"

@interface CameraViewController : UIViewController
- (instancetype)initWithEventID:(NSString *) eventID mEventDate:(NSString *) eventDate mEventTime:(NSString *) eventTime mOrgID:(NSString *) orgID mHomefeedMediaKey:(NSString *) homeFeedMediaKey mOrgProfImage:(NSString *) orgProfImage mEventDateObject:(NSNumber *) eventDateObject;
@end
