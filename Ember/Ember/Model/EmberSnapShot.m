//
//  EmberSnapShot.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmberSnapShot.h"

#import "Ember-Swift.h"

@import Firebase;

@interface EmberSnapShot(){
    
    NSDictionary *_eventDetails;
    NSDictionary*_values;
    NSMutableArray<EmberSnapShot *> *bounceSnapShots;
    FIRDataSnapshot *_snap;
    
}

@end

@implementation EmberSnapShot

-(instancetype)initWithSnapShot:(FIRDataSnapshot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    _snap = snapShot;
    _values = snapShot.value;
     _eventDetails = _values[[BounceConstants firebaseHomefeedPostDetails]];
    
    self.key = snapShot.key;
    
    return self;
}

-(instancetype)initWithEventsSnapShot:(FIRDataSnapshot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    _snap = snapShot;
    _values = snapShot.value;
    self.key = snapShot.key;
    
    return self;
}

-(instancetype)init{
    if (!(self = [super init]))
        return nil;
    
    bounceSnapShots = [[NSMutableArray alloc] init];
    return self;
    
}

-(instancetype)initWithMyEventsSnapShot:(FIRDataSnapshot*)snapShot key:(NSString*)key{
    if (!(self = [super init]))
        return nil;
    _snap = snapShot;
    _values = snapShot.value;
    _eventDetails = _values[[BounceConstants firebaseHomefeedPostDetails]];
    self.key = key;
    
    return self;
}

-(instancetype)initWithOrgsSnapShot:(FIRDataSnapshot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    _values = snapShot.value;
    _eventDetails = _values;
    self.key = snapShot.key;
    
    return self;
}

-(BOOL)addOrgsSnapShot:(FIRDataSnapshot*)snap user:(EmberUser*)user{
    
    EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithOrgsSnapShot:snap];
    
    NSDictionary *val = snap.value;
    NSString *orgID = snap.key;
    
    if(![user userFollowsOrg:orgID]){
        
        if(val[@"preferences"]){
            //                    NSLog(@"past: %@", val[@"preferences"]);
            NSDictionary *prefs = val[@"preferences"];
 
            if([user matchesUserPreferences:prefs]){ // Add orgs that match prefs at top of list
                
                [bounceSnapShots insertObject:newSnap atIndex:0];
                
                
            }else{
                [bounceSnapShots addObject:newSnap];
            }
            
            return YES;
        }else{
            
            [bounceSnapShots addObject:newSnap];
            return YES;
        }
        
    }
    
    return NO;
    
  
}

-(void)addMyEventsSnapShot:(FIRDataSnapshot*)snap key:(NSString*)key{
    
    EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithMyEventsSnapShot:snap key:key];
    [bounceSnapShots addObject:newSnap];
}

-(BOOL)isEventPoster{
    
    if(_eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]])
        return true;
    return false;
}


/**
 *  Adds post to beginning of list if the snap matches user's preferences, user follows org or if user made the post
 *
 *  @param snap - The Homefeed tree post
 */
-(void)addSnapShot:(FIRDataSnapshot*)snap{
    
    NSDictionary *post = snap.value;
    NSDictionary *postDetails = post[[BounceConstants firebaseHomefeedPostDetails]];
    
    NSArray *values = [postDetails[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
//        NSLog(@"values: %lu", (unsigned long)values.count);
    NSMutableArray *valuesMutable = [values mutableCopy];
    
    if(values.count >= [BounceConstants maxPhotosInGallery]){

        while (valuesMutable.count > 0) {
            EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snap];
            NSDictionary *eventDetails = [newSnap getPostDetails];
             NSArray *replacement = [valuesMutable subarrayWithRange:NSMakeRange(0, MIN([BounceConstants maxPhotosInGallery],valuesMutable.count))];
            replacement = [[replacement reverseObjectEnumerator] allObjects];
            [eventDetails setValue:replacement forKeyPath:@"mediaInfo"];
            [newSnap replaceMediaLinks:replacement];
            [valuesMutable removeObjectsInRange:NSMakeRange(0, MIN([BounceConstants maxPhotosInGallery],valuesMutable.count))];
            [bounceSnapShots insertObject:newSnap atIndex:0];
            
        }
        
        
    }else{
        
        EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snap];
        [bounceSnapShots insertObject:newSnap atIndex:0];
        
    }
    
}

/**
 *  Adds post to end of list if the snap does not match user's preferences, user does not follow org or if user didn't make the post
 *
 *  @param snap - The Homefeed tree post
 */
-(void)addSnapShotToEnd:(FIRDataSnapshot *)snap{
    
    NSDictionary *post = snap.value;
    NSDictionary *postDetails = post[[BounceConstants firebaseHomefeedPostDetails]];
    
    NSArray *values = [postDetails[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
    //        NSLog(@"values: %lu", (unsigned long)values.count);
    NSMutableArray *valuesMutable = [values mutableCopy];
    
    if(values.count >= [BounceConstants maxPhotosInGallery]){
        
        while (valuesMutable.count > 0) {
            EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snap];
            NSDictionary *eventDetails = [newSnap getPostDetails];
            NSArray *replacement = [valuesMutable subarrayWithRange:NSMakeRange(0, MIN([BounceConstants maxPhotosInGallery],valuesMutable.count))];
            replacement = [[replacement reverseObjectEnumerator] allObjects];
            [eventDetails setValue:replacement forKeyPath:@"mediaInfo"];
            [newSnap replaceMediaLinks:replacement];
            [valuesMutable removeObjectsInRange:NSMakeRange(0, MIN([BounceConstants maxPhotosInGallery],valuesMutable.count))];
            [bounceSnapShots addObject:newSnap];
            
        }
        
        
    }else{
        
        EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snap];
        [bounceSnapShots addObject:newSnap];
        
    }
    
}

-(void)addIndividualProfileSnapShot:(FIRDataSnapshot*)snap{
    
    
    FIRUser *user = [FIRAuth auth].currentUser;
    NSString *uid = user.uid;
    
    NSDictionary *post = snap.value;
    NSDictionary *postDetails = post[[BounceConstants firebaseHomefeedPostDetails]];
    
    NSArray *values = [postDetails[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
//            NSLog(@"values: %lu", (unsigned long)values.count);
    NSMutableArray *valuesMutable = [NSMutableArray new];
    
    for(int i = 0; i < values.count; i ++){
        NSDictionary *val = [values objectAtIndex:i];
 
        if([val[@"userID"] isEqualToString:uid]){
           
            [valuesMutable addObject:val];
        }
    }
    
    if(values.count >= 1){
        
        while (valuesMutable.count > 0) {
            EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snap];
            NSDictionary *eventDetails = [newSnap getPostDetails];
            NSArray *replacement = [valuesMutable subarrayWithRange:NSMakeRange(0, MIN( 1,valuesMutable.count))];
            [eventDetails setValue:replacement forKeyPath:@"mediaInfo"];
            [newSnap replaceMediaLinks:replacement];
            [valuesMutable removeObjectsInRange:NSMakeRange(0, MIN( 1 ,valuesMutable.count))];
            [bounceSnapShots addObject:newSnap];
            
        }
        
        
    }else{
        
        EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snap];
        [bounceSnapShots addObject:newSnap];
        
    }
        
}

-(NSUInteger)getNoOfBounceSnapShots{
    return bounceSnapShots.count;
}

-(EmberSnapShot*)getBounceSnapShotAtIndex:(NSUInteger)index{
    return [bounceSnapShots objectAtIndex:index];
    
}

-(void)removeSnapShotAtIndex: (NSUInteger)index{
    [bounceSnapShots removeObjectAtIndex:index];
}

-(void)removeAllSnapShots{
    [bounceSnapShots removeAllObjects];
}

-(void)replaceMediaLinks:(NSArray*)mediaLinks{
    
    [_eventDetails setValue:mediaLinks forKeyPath:@"mediaInfo"];
}

-(NSDictionary*)getPostDetails{
    
    if(_eventDetails != nil){
        return _eventDetails;
    }
    return nil;
   
}

-(NSDictionary*)getMediaInfo{
    
    if(_eventDetails[@"mediaInfo"] != nil){
        return _eventDetails[@"mediaInfo"];
    }
    return nil;
    
}

-(FIRDataSnapshot*)getFirebaseSnapShot{
    return _snap;
}

// Returns higher tree level with fireCount
-(NSDictionary*)getData{
    return _values;
}



@end