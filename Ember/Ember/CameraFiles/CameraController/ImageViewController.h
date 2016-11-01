//
//  ImageViewController.h
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/26/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
- (instancetype)initWithImage:(UIImage *)image mEventID:(NSString *) eventID mEventDate:(NSString *) eventDate mEventTime:(NSString *) eventTime mOrgID:(NSString *) orgID mHomefeedMediaKey:(NSString *) homeFeedMediaKey mOrgProfImage:(NSString *) orgProfImage mEventDateObject:(NSNumber *) eventDateObject;
@end
