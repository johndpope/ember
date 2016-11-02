//
//  VideoViewController.h
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/26/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoViewController : UIViewController
- (instancetype)initWithVideoUrl:(NSURL *)url mEventID:(NSString *) eventID mEventDate:(NSString *) eventDate mEventName:(NSString *) eventName mEventTime:(NSString *) eventTime mOrgID:(NSString *) orgID mHomefeedMediaKey:(NSString *) homeFeedMediaKey mOrgProfImage:(NSString *) orgProfImage mEventDateObject:(NSNumber *) eventDateObject;
@end
