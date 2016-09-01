//
//  OrgNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/22/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrgNode.h"
#import "Video.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;

@interface OrgNode (){
    
    ASDisplayNode *_divider;
    ASDisplayNode *_divider2;
    EmberSnapShot*_snapShot;
    NSMutableDictionary*_events;
    FIRUser *_user;
    FIRDatabaseReference *_ref;
    ASTextNode *_noInterested;
    ASDisplayNode *_line;
    ASButtonNode *_fire;
    ASTextNode *_eventName;
    ASTextNode *_dateTextNode;
    ASTextNode *_fireCount;
    ASTextNode *_eventDesc;
    ASTextNode *_noInterestedBelow;
    NSString *_uid;
    ASTextNode *_eventLocation;
    
    
}

@end

@implementation OrgNode

-(ASTextNode*)getFireCount{
    return  _fireCount;
}

- (instancetype)initWithBounceSnapShot:(EmberSnapShot *)snap mediaCount:(NSUInteger)mediaCount{
    if (!(self = [super init]))
        return nil;
    
    NSLog(@"mediaCount: %lu", mediaCount);
    
    _ref = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    
    _noInterested = [[ASTextNode alloc] init];
    _noInterestedBelow = [ASTextNode new];
    _eventName  = [ASTextNode new];
    
    _snapShot = snap;
    
    _fireCount = [[ASTextNode alloc] init];
    
    NSDictionary *details = [snap getData];
    
//    NSLog(@"details: %@", details);
    
    _fireCount.attributedString = [[NSAttributedString alloc] initWithString:@"+    "
                                                                  attributes:[self textStyleFireUnselected]];
    
    _noInterested.attributedString = [[NSAttributedString alloc] initWithString:@"     " attributes:[self textStyle]];
    FIRDatabaseQuery *recentPostsQuery = [[[_ref child:[BounceConstants firebaseHomefeed]] child:snap.key] child:@"fireCount"];
    [recentPostsQuery observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSUInteger noInterested = [snapShot.value integerValue];
        NSUInteger fireCount = noInterested + mediaCount;
        
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", (unsigned long)fireCount]
                                                                      attributes:[self textStyleFireUnselected]];
        
        _noInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)noInterested] attributes:[self textStyle]];
        
    }];

    
    _noInterestedBelow.attributedString = [[NSAttributedString alloc] initWithString:@"Interested" attributes:[self textStyle]];
    
    NSDictionary *eventDetails = snap.getPostDetails;
    
    if(eventDetails[@"eventName"]){
        _eventName.attributedString = [[NSAttributedString alloc] initWithString:eventDetails[@"eventName"] attributes:[self textStyleLeft]];
    }else{
       _eventName.attributedString = [[NSAttributedString alloc] initWithString:details[@"eventName"] attributes:[self textStyleLeft]];
    }
    
    
    _dateTextNode = [[ASTextNode alloc] init];
    _dateTextNode.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", eventDetails[@"eventDate"], eventDetails[@"eventTime"]]
                                                                     attributes:[self textStyleLeft]];
    
    _eventLocation = [[ASTextNode alloc] init];
    _eventLocation.attributedString = [[NSAttributedString alloc] initWithString:eventDetails[@"eventLocation"]
                                                                     attributes:[self textStyleLeft]];
    
    
    _eventDesc = [[ASTextNode alloc] init];
    _eventDesc.spacingBefore = 10;
    _eventDesc.maximumNumberOfLines = 3;
    
    _eventDesc.attributedString = [[NSAttributedString alloc] initWithString:@" "
                                                                 attributes:[self textStyleDesc]];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _eventDesc.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _eventDesc.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _eventDesc.attributedString.size.height)));
    
    FIRDatabaseReference *ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    

    FIRDatabaseQuery *recentPostsQuery2 = [[[ref child:[BounceConstants firebaseEventsChild]] child:eventDetails[@"eventID"]] child:@"eventDesc"];
    [recentPostsQuery2 observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        _eventDesc.attributedString = [[NSAttributedString alloc] initWithString:snapShot.value
                                                                      attributes:[self textStyleDesc]];
        
    }];
    
    _line = [[ASDisplayNode alloc] init];
    _line.backgroundColor  = [UIColor lightGrayColor];
    _line.preferredFrameSize = CGSizeMake(2, 30);
    
    
    _fire = [[ASButtonNode alloc] init];
    
    [_fire setImage:[UIImage imageNamed:@"homeFeedFireUnselected"] forState:ASControlStateNormal];
    [_fire setImage:[UIImage imageNamed:@"homeFeedFireSelected"] forState:ASControlStateSelected];
    
    [_fire addTarget:self
              action:@selector(fireButtonTapped)
    forControlEvents:ASControlNodeEventTouchDown];
    
    
    _uid = [[[FIRAuth auth] currentUser] uid];
    
    [[[[[_ref child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"postsFired"] child:_snapShot.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snap){
        //                NSLog(@"%@  %@", snapShot.key, snapShot.value);
        if(![snap.value isEqual:[NSNull null]]){
            [_fire setSelected:YES];
            
            NSUInteger count = [[[_fireCount attributedString] string] integerValue];
            _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", (unsigned long)count]
                                                                          attributes:[self textStyleFire]];
            
            
        }else{
            [_fire setSelected:NO];
            // No need to change color of fireCount since it was set before
        }
        
        
    }];
    
    
    [self addSubnode:_fire];
    [self addSubnode:_noInterested];
    [self addSubnode:_line];
    [self addSubnode:_eventName];
    [self addSubnode:_dateTextNode];
    [self addSubnode:_eventDesc];
    [self addSubnode:_fireCount];
    [self addSubnode:_noInterestedBelow];
    [self addSubnode:_eventLocation];

    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    
    
    [self addSubnode:_divider];
    
    
    return self;
}

-(void)fireButtonTapped{
    if(_fire.selected){
        
        
        NSUInteger count = [[[_fireCount attributedString] string] integerValue];
        count--;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", count]
                                                                      attributes:[self textStyleFireUnselected]];
        
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_snapShot.key];
        [[[[[_ref child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"postsFired"] child:_snapShot.key] removeValue];
        
        
        [_fire setSelected:NO];
        
        [self decreaseFireCount];
        
        
    }
    else{
        
        
        NSUInteger count = [[[_fireCount attributedString] string] integerValue];
        count++;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", count]
                                                                      attributes:[self textStyleFire]];
        
        [[[[[_ref child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"postsFired"] child:_snapShot.key] setValue:[NSNumber numberWithBool:YES]];
        [_fire setSelected:YES];
        
        [self increaseFireCount];
        
        // TODO I forget what this is for...
//        [self sendNotif];
        
        
    }
    
}

- (NSDictionary *)textStyleFireUnselected{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    }

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

-(FIRDatabaseReference*)getHomeFeedPostReference{
    return [[[_ref child:[BounceConstants firebaseHomefeed]] child:_snapShot.key] child:@"fireCount"];
}

-(void)increaseFireCount{
    
    [[self getHomeFeedPostReference] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *post = currentData.value;
        //        NSLog(@"post: %@", post);
        if (!post || [post isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        
        int starCount = [currentData.value intValue];
        starCount++;
        [currentData setValue:[NSNumber numberWithInt:starCount]];
        // Set value and report transaction success
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error,
                           BOOL committed,
                           FIRDataSnapshot * _Nullable snapshot) {
        // Transaction completed
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

-(void)decreaseFireCount{
    
    [[self getHomeFeedPostReference] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *post = currentData.value;
        if (!post || [post isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        
        int starCount = [currentData.value intValue];
        starCount--;
        
        // Set value and report transaction success
        [currentData setValue:[NSNumber numberWithInt:starCount]];
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error,
                           BOOL committed,
                           FIRDataSnapshot * _Nullable snapshot) {
        // Transaction completed
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}


-(FIRDatabaseReference*) getFollowersReference{
    return [[[[_ref child:@"users"] child:_user.uid] child:@"eventsFollowed"] childByAutoId];
}

- (NSDictionary *)textStyle{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;

    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleDesc{
    
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightLight];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightLight];
    }

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentLeft;
    
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleFire{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    }

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor colorWithRed: 213.0/255.0 green: 29.0/255.0 blue: 36.0/255.0 alpha: 1.0], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleFireLit{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:8.0f weight:UIFontWeightRegular];
    }else{
        font = [UIFont systemFontOfSize:10.0f weight:UIFontWeightRegular];
    }
 
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor colorWithRed: 213.0/255.0 green: 29.0/255.0 blue: 36.0/255.0 alpha: 1.0], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleLeft{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightSemibold];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightSemibold];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentLeft;
    
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGFloat kInsetHorizontal = 16.0;
    CGFloat kInsetTop = 6.0;
    CGFloat kInsetBottom = 6.0;
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;

    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, kInsetHorizontal, kInsetBottom, kInsetHorizontal);
    
    ASStackLayoutSpec *vertInterested = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[_noInterested, _noInterestedBelow]];
    ASInsetLayoutSpec *newSpec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 50, 0, 0) child:vertInterested];
    
    
    ASStackLayoutSpec *vert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[newSpec,horizontalSpacer]];
    
    ASStackLayoutSpec *fireStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:5.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:@[ _fire,_fireCount]];
    
    ASStackLayoutSpec *followingStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:5.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[ horizontalSpacer,vert,horizontalSpacer, _line,horizontalSpacer,fireStack, horizontalSpacer]];

    
    ASInsetLayoutSpec *followingSpecs = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:followingStack];

    ASStackLayoutSpec *vertical = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[followingSpecs, _eventName, _dateTextNode, _eventLocation,_eventDesc,_divider]];
   
    
    return vertical;
}

@end
