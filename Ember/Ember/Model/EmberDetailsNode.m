//
//  EmberDetailsNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 8/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EmberDetailsNode.h"
#import "Video.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>


@import Firebase;
@import FirebaseCrash;

#define StrokeRoundedImages 0

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

static const CGFloat kInnerPadding = 10.0f;
static const CGFloat kOrgPhotoWidth = 50.0f;
static const CGFloat kOrgPhotoHeight = 50.0f;


@interface EmberDetailsNode () <UIGestureRecognizerDelegate> {
    

    ASTextNode *_textNode;
    BOOL _swappedTextAndImage;
    ASTextNode *_dateTextNode;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    ASButtonNode* _followButton;
    EmberSnapShot*_snapShot;
    FIRUser *_user;
    FIRDatabaseReference *_ref;
    ASNetworkImageNode *_orgProfilePhoto;
    ASTextNode *_text;
    float _scale;
    float _imageHeight;
    CGFloat screenWidth;
    ASButtonNode *_playNode;
    BOOL _followButtonHidden;
    ASTextNode *_userName;
    ASTextNode *_caption;
    NSString *uuid;
    BOOL _showFireCount;
    ASTextNode *_fireCount;
    ASButtonNode *_fire;
    NSUInteger _mediaItemsCount;
    NSString *_uid;
    ASTextNode *_noImages;
    ASTextNode *_numberInterested;
    ASDisplayNode*_divider;
    FIRDatabaseReference *_usersRef;
    
    
}

@end

@implementation EmberDetailsNode


-(ASTextNode *)getTextNode{
    return _textNode;
}

-(ASTextNode *)getDateTextNode{
    return _dateTextNode;
}

-(ASButtonNode *)getButtonNode{
    return _followButton;
}

-(ASNetworkImageNode*)getOrgProfilePhotoNode{
    return _orgProfilePhoto;
}

-(ASTextNode*)getUserNameNode{
    return _userName;
}

-(void)setFollowButtonHidden{
    _followButtonHidden = YES;
    
    _followButton.hidden = YES;
    _numberInterested.hidden = YES;
    
}

-(void)showFireCount{
    _showFireCount = YES;
}

-(void)fetchOrgProfilePhotoUrl:(NSString*) orgId{
    
    FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:[BounceConstants firebaseOrgsChild]] child:orgId]  queryLimitedToFirst:100];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSDictionary *org = snapShot.value;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _orgProfilePhoto.URL = [NSURL URLWithString:org[[BounceConstants firebaseOrgsChildSmallImageLink]]];
            
        });
    }];
}

-(void)fetchUserName{
    FIRDatabaseQuery *recentPostsQuery = [[[_usersRef child:[BounceConstants firebaseUsersChild]] child:uuid]  queryLimitedToFirst:100];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //                NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSDictionary *userInfo = snapShot.value;
        
        NSString *userName = userInfo[@"username"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_userName setAttributedString:[[NSAttributedString alloc] initWithString:userName
                                                                           attributes:[self textStyleUsername]]];
            
        });
    }];
}


- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _followButtonHidden = NO;
    _showFireCount = NO;
    
    _mediaItemsCount = 0;
    
    _numberInterested = [ASTextNode new];
    
    _usersRef = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _snapShot = snapShot;
    NSDictionary *eventDetails = [snapShot getPostDetails];
    
//    if([eventDetails[@"mediaInfo"] isKindOfClass:[NSMutableArray class]]){
//         NSLog(@"deets: %@", [eventDetails[@"mediaInfo"] allKeys]);
//    }
   
    FIRDataSnapshot *snap = [snapShot getFirebaseSnapShot];
    
//    NSDictionary *snap2 = snap.value[@"postDetails"];
    
//    NSLog(@"snap: %@", [snap2[@"mediaInfo"] allKeys]);
    
    _orgProfilePhoto = [[ASNetworkImageNode alloc] init];
    _orgProfilePhoto.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
    _orgProfilePhoto.cornerRadius = kOrgPhotoWidth / 2;
    _orgProfilePhoto.imageModificationBlock = ^UIImage *(UIImage *image) {
        
        UIImage *modifiedImage;
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, [[UIScreen mainScreen] scale]);
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kOrgPhotoWidth];
        
        [circle addClip];
        
        [image drawInRect:rect];
        
        // create a border (for white background pictures)
#if StrokeRoundedImages
        circle.lineWidth = 1;
        [[UIColor darkGrayColor] set];
        [circle stroke];
#endif
        
        
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return modifiedImage;
        
    };
    
    [_orgProfilePhoto addTarget:self action:@selector(orgPhotoClicked) forControlEvents:ASControlNodeEventTouchDown];
    
    [self fetchOrgProfilePhotoUrl:eventDetails[[BounceConstants firebaseEventsChildOrgId]]];
    
    _textNode = [[ASTextNode alloc] init];
    _textNode.layerBacked = YES;
    
    _noImages = [ASTextNode new];
    _noImages.layerBacked = YES;
    _noImages.attributedString = [[NSAttributedString alloc] initWithString:@"   images"
                                                                attributes:[self textStyleNoImages]];
    
    NSString *eventName = eventDetails[[BounceConstants firebaseEventsChildEventName]];
    
    _textNode.attributedString = [[NSAttributedString alloc] initWithString:eventName
                                                                 attributes:[self textStyle]];
    
    if(IS_IPHONE_5){
        _textNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.55, _textNode.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.55, _textNode.attributedString.size.height * 2)));
    }else{
       _textNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.605, _textNode.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.605, _textNode.attributedString.size.height * 2)));
    }
    
    
    _textNode.maximumNumberOfLines = 2;
    _textNode.truncationMode = NSLineBreakByTruncatingTail;
    
    _userName = [ASTextNode new];
    _caption = [ASTextNode new];
    
    
    uuid = nil;
    
    
    if(!eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]]){
        
        
        if([eventDetails[[BounceConstants firebaseHomefeedMediaInfo]] isKindOfClass:[NSDictionary class]]){
            NSArray *values = [eventDetails[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
            _mediaItemsCount = values.count;
            if ([values count] != 0){
                if(values.count == 1){
                    _noImages.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu image", values.count]
                                                                                 attributes:[self textStyleNoImages]];
                }else{
                    _noImages.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu images", values.count]
                                                                                 attributes:[self textStyleNoImages]];
                }
                
                NSDictionary *first = [values objectAtIndex:0];
                uuid = first[@"userID"];
                
                if(![first[@"mediaCaption"] isEqualToString:@"(null)"]){
                    _caption.attributedString = [[NSAttributedString alloc] initWithString:first[@"mediaCaption"]
                                                                                attributes:[self textStyleLeft]];
                }
                
            }
            
        }else{
            
            NSArray *values = eventDetails[[BounceConstants firebaseHomefeedMediaInfo]];
            _mediaItemsCount = values.count;
            if(values.count == 1){
                _noImages.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu image", values.count]
                                                                             attributes:[self textStyleNoImages]];
            }else{
                _noImages.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu images", values.count]
                                                                             attributes:[self textStyleNoImages]];
            }
            
            NSDictionary *first = [values objectAtIndex:0];
//            NSLog(@"classname: %@", className);
//            NSLog(@"%@", eventDetails[[BounceConstants firebaseHomefeedMediaInfo]]);
            uuid = first[@"userID"];
            
            FIRCrashLog(@"eventDetails: %@", eventDetails[[BounceConstants firebaseHomefeedMediaInfo]]);
            FIRCrashLog(@"values: %@", values);
            FIRCrashLog(@"first: %@", first);

            if(![first[@"mediaCaption"] isEqualToString:@"(null)"]){
                FIRCrashLog(@"first[mediaCaption]: %@", first[@"mediaCaption"]);
                _caption.attributedString = [[NSAttributedString alloc] initWithString:first[@"mediaCaption"]
                                                                            attributes:[self textStyleLeft]];
            }
            
        }
        
        // Using 0.820 since that's the best width to allow some space for text with number of gallery images
        _caption.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.820, _caption.attributedString.size.height * 2)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.820, _caption.attributedString.size.height * 2)));
        
        _userName.attributedString = [[NSAttributedString alloc] initWithString:@" "
                                                                     attributes:[self textStyleUsername]];
        
        _userName.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _userName.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _userName.attributedString.size.height)));
        
        
        [self fetchUserName];
    }else{
//        _userName.hidden = YES;
//        _caption.hidden = YES;
//        
//        NSDictionary *allPostInfo = snapShot.getData;
//        NSString *fireCountString = [NSString stringWithFormat:@"+%@", allPostInfo[@"fireCount"]];
//        NSUInteger fireCountNum = [fireCountString integerValue];
//        _numberInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", fireCountNum]
//                                                                      attributes:[self textStyleInterested]];
    }
    
    _fireCount = [[ASTextNode alloc] init];
    
    if(![([snapShot getData][@"fireCount"]) isEqual:[NSNull null]]){
        
        NSString *fireCountString = [NSString stringWithFormat:@"+%@", [snapShot getData][@"fireCount"]];
        NSUInteger fireCountNum = [fireCountString integerValue] + _mediaItemsCount;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", fireCountNum]
                                                                      attributes:[self textStyleFireUnselected]];
    }
    
    _fire = [[ASButtonNode alloc] init];
    [_fire setImage:[UIImage imageNamed:@"homeFeedFireUnselected"] forState:ASControlStateNormal];
    [_fire setImage:[UIImage imageNamed:@"homeFeedFireSelected"] forState:ASControlStateSelected];
    
    [_fire addTarget:self
              action:@selector(fireButtonTapped)
    forControlEvents:ASControlNodeEventTouchDown];
    
    _uid = [[[FIRAuth auth] currentUser] uid];
    
    [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"postsFired"] child:_snapShot.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snap){
        //                NSLog(@"%@  %@", snapShot.key, snapShot.value);
        if(![snap.value isEqual:[NSNull null]]){
            [_fire setSelected:YES];
            
            NSString *fireCountString = [NSString stringWithFormat:@"+%@", [snapShot getData][@"fireCount"]];
            NSUInteger fireCountNum = [fireCountString integerValue] + _mediaItemsCount;
            _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", (unsigned long)fireCountNum]
                                                                          attributes:[self textStyleFire]];
            
            NSUInteger count = [[[_fireCount attributedString] string] integerValue];
            count++;
            
            
        }else{
            [_fire setSelected:NO];
            // No need to change color of fireCount since it was set before
        }
        
        
    }];
    
    
    _userName.maximumNumberOfLines = 1;
    _userName.truncationMode = NSLineBreakByTruncatingTail;
    
    
    _caption.maximumNumberOfLines = 2;
    _caption.truncationMode = NSLineBreakByTruncatingTail;
    
    _dateTextNode = [[ASTextNode alloc] init];
    _dateTextNode.layerBacked = YES;
    
    _dateTextNode.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", eventDetails[[BounceConstants firebaseEventsChildEventDate]], eventDetails[[BounceConstants firebaseEventsChildEventTime]]]
                                                                     attributes:[self textStyleItalic]];
    
    _dateTextNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.204, _dateTextNode.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth * 0.204, _dateTextNode.attributedString.size.height)));
    _dateTextNode.maximumNumberOfLines = 1;
    _dateTextNode.truncationMode = NSLineBreakByTruncatingTail;
    
    
    _followButton = [[ASButtonNode alloc] init];
    [_followButton setImage:[UIImage imageNamed:@"homeFeedInterestedUnselected"] forState:ASControlStateNormal];
    [_followButton setImage:[UIImage imageNamed:@"homeFeedInterestedSelected"] forState:ASControlStateSelected];
    
  
    
    //    NSLog(@"key homefeed: %@", _snapShot.key);
    
    [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"eventsFollowed"] child:_snapShot.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //                NSLog(@"%@  %@", snapShot.key, snapShot.value);
        if(![snapShot.value isEqual:[NSNull null]]){
            
            [_followButton setSelected:YES];
//            NSLog(@"%@", _uid);
            NSDictionary *attrDict = @{
                                       NSFontAttributeName : [UIFont systemFontOfSize:14.0],
                                       NSForegroundColorAttributeName : [UIColor colorWithRed: 32.0/255.0 green: 173.0/255.0 blue: 5.0/255.0 alpha: 1.0]
                                       };
            NSUInteger count = [[[_numberInterested attributedString] string] integerValue];
            _numberInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", count]
                                                                           attributes:attrDict];
            
        }else{
            [_followButton setSelected:NO];
        }
        
        
    }];
    
    
    [_followButton addTarget:self
                      action:@selector(buttonTapped)
            forControlEvents:ASControlNodeEventTouchDown];
    
    
    
    [self addSubnode:_followButton];
    [self addSubnode:_userName];
    [self addSubnode:_caption];
    [self addSubnode:_noImages];
    [self addSubnode:_textNode];
    [self addSubnode:_dateTextNode];
    [self addSubnode:_orgProfilePhoto];
    [self addSubnode:_fire];
    [self addSubnode:_numberInterested];
    

    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    [self addSubnode:_divider];

    return self;
}

-(void)orgPhotoClicked{
    
    NSDictionary *eventDetails = [_snapShot getPostDetails];
    
    NSString* orgId = eventDetails[[BounceConstants firebaseEventsChildOrgId]];
    
    id<OrgImageClickedDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(orgClicked:)]) {
        [strongDelegate orgClicked:orgId];
    }
    
    
}

- (NSDictionary *)textStyleFire{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
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

- (NSDictionary *)textStyleFireUnselected{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
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

-(NSString*)truncateEventName:(NSString*)eventName{
    
    if([eventName length] < 30){
        return eventName;
    }
    
    // define the range you're interested in
    NSRange stringRange = {0, MIN([eventName length], 30)};
    
    
    // adjust the range to include dependent chars
    stringRange = [eventName rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *result = [eventName substringWithRange:stringRange];
    
    
    NSRange range = [result rangeOfString:@" " options:NSBackwardsSearch];
    
    if(range.location != NSNotFound){
        return [[result substringToIndex:range.location] stringByAppendingString:@"..."];
    }else{
        return eventName;
    }
    
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

-(FIRDatabaseReference*)getHomeFeedPostReference{
    return [[[_ref child:[BounceConstants firebaseHomefeed]] child:_snapShot.key] child:@"fireCount"];
}

-(void)fireButtonTapped{
    if(_fire.selected){

        
        NSUInteger count = [[[_fireCount attributedString] string] integerValue];
        count--;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", count]
                                                                      attributes:[self textStyleFireUnselected]];
        
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_snapShot.key];
        [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"postsFired"] child:_snapShot.key] removeValue];
     
        [_fire setSelected:NO];
        
        [self decreaseFireCount];
        
        
    }
    else{
        
     
        NSUInteger count = [[[_fireCount attributedString] string] integerValue];
        count++;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", count]
                                                                      attributes:[self textStyleFire]];
      
        [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_uid] child:@"postsFired"] child:_snapShot.key] setValue:[NSNumber numberWithBool:YES]];
        [_fire setSelected:YES];
        
        [self increaseFireCount];
        
    }
    
}

-(void)buttonTapped{
    if(_followButton.selected){
        
        NSDictionary *attrDict = @{
                                   NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightRegular],
                                   NSForegroundColorAttributeName : [UIColor lightGrayColor]
                                   };
        
        
        NSUInteger count = [[[_numberInterested attributedString] string] integerValue];
        count--;
        _numberInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", count]
                                                                             attributes:attrDict];

        [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:[BounceConstants firebaseUsersChildEventsFollowed]] child:_snapShot.key] removeValue];
        
        [_followButton setSelected:NO];
        
        [self decreaseFireCount];
        
        
    }
    else{
  
        NSDictionary *attrDict = @{
                                   NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
                                   NSForegroundColorAttributeName : [UIColor colorWithRed: 32.0/255.0 green: 173.0/255.0 blue: 5.0/255.0 alpha: 1.0]
                                   };
        NSUInteger count = [[[_numberInterested attributedString] string] integerValue];
        count++;
        _numberInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", count]
                                                                             attributes:attrDict];
        FIRDatabaseReference *ref = [self getFollowersReference];
        
        // TODO use String : Bool pair
        [ref setValue:[NSNumber numberWithBool:YES]];
        [_followButton setSelected:YES];
        
        [self increaseFireCount];
        
        [self sendNotif];
        
        
    }
    
}

-(void)sendNotif{
    
    NSDictionary *postDetails = [_snapShot getPostDetails];
    NSNumber *time = postDetails[@"eventDateObject"];
    NSString* eventName = postDetails[@"eventName"];
    
    //    NSLog(@"current test for sendNotif");
    //    NSLog(@"%@",time);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:-[time doubleValue]];
    
    NotificationItem *item = [[NotificationItem alloc] initWithDate:date title:eventName UUID:[[NSUUID UUID] UUIDString]];
    [[LocalNotifications sharedInstance] addItem:item];
    
    
}
-(FIRDatabaseReference*) getFollowersReference{
    return [[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:[BounceConstants firebaseUsersChildEventsFollowed]] child:_snapShot.key];
}

- (NSDictionary *)textStyle{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleNoImages{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:10.0f];
    }else{
        font = [UIFont systemFontOfSize:12.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentRight;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleInterested{
    UIFont *font = nil;
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentRight;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleLeft{
    UIFont *font = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleUsername{
    
    UIFont *font = nil;
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:10.0f];
    }else{
        font = [UIFont systemFontOfSize:12.0f];
    }
 
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleItalic{
    UIFont *font = nil;
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentRight;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}
-(void)scalingTemplate{
    
    
    //    float widthRatioText = screenWidth / _textNode.calculatedSize.width;
    //    float heightRatioText = _textNode.calculatedSize.height;
    //    float scaleText = MIN(widthRatioText, heightRatioText);
    //    float imageWidthText = scaleText * _textNode.calculatedSize.width;
    //    float imageHeightText = scaleText * _textNode.calculatedSize.height;
    
}


- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    //    CGFloat kInsetHorizontal = 16.0;
    CGFloat kInsetTop = 6.0;
    //    CGFloat kInsetBottom = 6.0;
    
    //    CGFloat kOuterPadding = 10.0f;
    
    //    NSLog(@"screen width: %f", screenWidth);
    
    ASLayoutSpec *horizontalSpacer =[ASLayoutSpec new];
    horizontalSpacer.flexGrow = YES;
    
    ASStaticLayoutSpec *captionStatic = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[_caption]];
//    ASStaticLayoutSpec *numberImagesStatic = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[_noImages]];
     ASInsetLayoutSpec *specNumberImages = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 20) child:_noImages];
 
    ASStackLayoutSpec *captionRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
                                                                          justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[captionStatic, horizontalSpacer,specNumberImages]];
    
    

    
    ASStaticLayoutSpec *eventNameStatic = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[_textNode]];
    
    NSArray *info = @[ eventNameStatic, _dateTextNode];
    NSArray *info_2 = @[ _numberInterested, _followButton];
    
    ASStackLayoutSpec *infoStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                                    justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStart children:info];
    // TODO : image not centered if flex region is increased
//    if(_followButtonHidden){
//        
//        //        infoStack.flexBasis = ASRelativeDimensionMakeWithPoints(220);
//    }else{
//        infoStack.flexBasis = ASRelativeDimensionMakeWithPoints(180);
//    }
    
    
    ASStackLayoutSpec *followingRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
                                                                          justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:info_2];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, 0, 0, 10);
    
    ASInsetLayoutSpec *orgPhotoInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:_orgProfilePhoto];
    
    
    ASStackLayoutSpec *infoStack_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
                                                                      justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[orgPhotoInset,infoStack,horizontalSpacer, followingRegion]];
    ASStackLayoutSpec *infoStackVert = nil;
    if(_followButtonHidden){
        
        
        if(_showFireCount){
//            infoStack_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0.0
//                                                           justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:@[orgPhotoInset,infoStack,horizontalSpacer, _fire, _fireCount]];

            ASInsetLayoutSpec *fireInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 30) child:_fire];
            
            infoStack_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
                                                           justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[orgPhotoInset,infoStack,horizontalSpacer, fireInset]];
        }
        
        if(_userName.hidden && _caption.hidden){
            infoStackVert = infoStack_2;
        }else{
            
            ASStaticLayoutSpec *userNameStatic = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[_userName]];
            
            infoStackVert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                             justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[captionRegion, userNameStatic, infoStack_2]];
        }
        
    }else{
        
        
        infoStackVert = infoStack_2;
    }
    
    ASStackLayoutSpec* final =  [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                                 justifyContent:ASStackLayoutJustifyContentStart alignItems:ASStackLayoutAlignItemsStart children:@[infoStackVert]];

    
    UIEdgeInsets insets_2 = UIEdgeInsetsMake(10, 10, 10, 10);
    
    ASInsetLayoutSpec *spec_2 = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets_2 child:final];
    
    // MAKES NODE STRETCH TO FILL AVAILABLE SPACE
    //        spec_2.flexGrow = YES;

    
    return spec_2;
}



@end
