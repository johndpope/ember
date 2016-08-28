//
//  EmberSnapShot.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

@import Firebase;
@class EmberUser;

@interface EmberSnapShot : NSObject

@property(strong, nonatomic) NSString *key;

- (instancetype)initWithSnapShot:(FIRDataSnapshot *)snapShot;

-(instancetype)initWithMyEventsSnapShot:(FIRDataSnapshot*)snapShot key:(NSString*)key;
-(void)addMyEventsSnapShot:(FIRDataSnapshot*)snap key:(NSString*)key;

- (instancetype)init;
-(void)addSnapShot:(FIRDataSnapshot*)snap;
-(void)addSnapShotToEnd:(FIRDataSnapshot *)snap;

-(instancetype)initWithOrgsSnapShot:(FIRDataSnapshot*)snapShot;
-(BOOL)addOrgsSnapShot:(FIRDataSnapshot*)snap user:(EmberUser*)user;

-(void)addIndividualProfileSnapShot:(FIRDataSnapshot*)snap;
-(NSDictionary*)getMediaInfo;


-(FIRDataSnapshot*)getFirebaseSnapShot;
-(BOOL)isEventPoster;
-(NSUInteger)getNoOfBounceSnapShots;
-(EmberSnapShot*)getBounceSnapShotAtIndex:(NSUInteger)index;
-(void)removeSnapShotAtIndex: (NSUInteger)index;
-(void)removeAllSnapShots;
-(void)replaceMediaLinks:(NSArray*)mediaLinks;
-(NSDictionary*)getPostDetails;
-(NSDictionary*)getData;

@end
