//
//  MyEventsPostDetailsNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 8/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyEventsPostDetailsNode.h"
#import "Video.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;

static const CGFloat kInnerPadding = 10.0f;
static const CGFloat kOrgPhotoWidth = 75.0f;
static const CGFloat kOrgPhotoHeight = 75.0f;


@interface MyEventsPostDetailsNode () <ASNetworkImageNodeDelegate>{
    ASTextNode *_textNode;
    ASDisplayNode *_divider;
    BOOL _swappedTextAndImage;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    EmberSnapShot*_snapShot;
    NSMutableDictionary*_events;
    FIRUser *_user;
    FIRDatabaseReference *_usersRef;
    ASTextNode *_text;
    float _scale;
    float _imageHeight;
    CGFloat screenWidth;
    ASTextNode *_numberInterested;
    ASButtonNode* _followButton;
    ASNetworkImageNode *_orgProfilePhoto;
    ASTextNode *_dateTextNode;
    ASTextNode *_eventLocation;
    ASButtonNode *_eventPageButton;
    BOOL isAdminOf;
    ASButtonNode *_cameraButton;
    
}


@end

@implementation MyEventsPostDetailsNode


-(ASTextNode *)getTextNode{
    return _textNode;
}


-(void)fetchOrgProfilePhotoUrl:(NSString*) orgId{
    
    FIRDatabaseQuery *recentPostsQuery = [[self.schoolRootRef child:[BounceConstants firebaseOrgsChild]] child:orgId];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSDictionary * event = snapShot.value;
        //        NSLog(@"%@", event[[BounceConstants firebaseOrgsChildSmallImageLink]]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _orgProfilePhoto.URL = [NSURL URLWithString:event[[BounceConstants firebaseOrgsChildSmallImageLink]]];
            
        });
    }];
}

// TODO : use String : Bool pair in Firebase instead of the current array implementation
-(void)checkIsAdmin:(NSString*)orgid {
    
    [[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_user.uid]  child:@"adminOf"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        
        if(![snapShot.value isEqual:[NSNull null]] && [snapShot.value containsObject:orgid]){
//            NSLog(@"found");
            isAdminOf = YES;
////            _followButton.hidden = YES;
//            _followButton.tintColor = [UIColor whiteColor];
//            _cameraButton.hidden = NO;
            
        }else{
//            _followButton.hidden = NO;
//            _cameraButton.tintColor = [UIColor whiteColor];
////            _cameraButton.hidden = YES;
            isAdminOf = NO;
            
        }
        
        [self setNeedsLayout];
    }];
    
    
}


- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _usersRef = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    self.schoolRootRef = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _events = [[NSMutableDictionary alloc]initWithCapacity:10];
    _snapShot = snapShot;
    //    NSDictionary* event = snapShot.value;
    NSDictionary *eventDetails = snapShot.getPostDetails;
    
    _orgProfilePhoto = [[ASNetworkImageNode alloc] init];
    _orgProfilePhoto.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
    _orgProfilePhoto.cornerRadius = kOrgPhotoWidth / 2;
    _orgProfilePhoto.imageModificationBlock = ^UIImage *(UIImage *image) {
        
        UIImage *modifiedImage;
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, [[UIScreen mainScreen] scale]);
        
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kOrgPhotoWidth] addClip];
        [image drawInRect:rect];
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return modifiedImage;
        
    };
    
    [_orgProfilePhoto addTarget:self action:@selector(orgPhotoClicked) forControlEvents:ASControlNodeEventTouchDown];
    
    if(![eventDetails isEqual:[NSNull null]]){
        [self fetchOrgProfilePhotoUrl:eventDetails[[BounceConstants firebaseEventsChildOrgId]]];
    }
    
    _followButton = [[ASButtonNode alloc] init];
    [_followButton setImage:[UIImage imageNamed:@"homeFeedInterestedUnselected"] forState:ASControlStateNormal];
    [_followButton setImage:[UIImage imageNamed:@"homeFeedInterestedSelected"] forState:ASControlStateSelected];
    
    _cameraButton = [[ASButtonNode alloc] init];
    [_cameraButton setImage:[UIImage imageNamed:@"camera"] forState:ASControlStateNormal];
//    [_cameraButton setImage:[UIImage imageNamed:@"homeFeedInterestedSelected"] forState:ASControlStateSelected];
    
    NSDictionary *postDetails = snapShot.getPostDetails;
    [self checkIsAdmin:postDetails[@"orgID"]];
    
    _numberInterested = [[ASTextNode alloc] init];
    
    NSDictionary *allPostInfo = snapShot.getData;
//    NSLog(@"allpost: %@", allPostInfo);
    NSString *fireCountString = [NSString stringWithFormat:@"+%@", allPostInfo[@"fireCount"]];
    NSUInteger fireCountNum = [fireCountString integerValue];
    _numberInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", fireCountNum]
                                                                         attributes:[self textStyle]];
    
    //    NSLog(@"key: %@", _snapShot.key);
    NSString *uid = [[[FIRAuth auth] currentUser] uid];
    
    [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:uid] child:@"eventsFollowed"] child:_snapShot.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        
//        NSLog(@"%@  %@", snapShot.key, snapShot.value);
//        NSLog(@"snapshot key: %@", _snapShot.key);
        if(![snapShot.value isEqual:[NSNull null]]){
            
            if([snapShot.key isEqualToString:_snapShot.key]){
                [_followButton setSelected:YES];
                //            NSLog(@"%@", _uid);
                NSDictionary *attrDict = @{
                                           NSFontAttributeName : [UIFont systemFontOfSize:14.0],
                                           NSForegroundColorAttributeName : [UIColor colorWithRed: 32.0/255.0 green: 173.0/255.0 blue: 5.0/255.0 alpha: 1.0]
                                           };
                
                NSUInteger count = [[[_numberInterested attributedString] string] integerValue];
                _numberInterested.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", count]
                                                                                     attributes:attrDict];
            }
            
        }else{
            [_followButton setSelected:NO];
        }
        
        
    }];
    
    
    [_followButton addTarget:self
                      action:@selector(buttonTapped)
            forControlEvents:ASControlNodeEventTouchDown];
    
    [_cameraButton addTarget:self
                      action:@selector(cameraTapped)
            forControlEvents:ASControlNodeEventTouchDown];
    
    //    if([event isEqual:[NSNull null]]){
    //        return nil;
    //    }
    
    _textNode = [[ASTextNode alloc] init];
    _textNode.layerBacked = YES;
    
    NSString *eventName = eventDetails[[BounceConstants firebaseEventsChildEventName]];
    
    eventName = [self truncateEventName:eventName];
    _textNode.attributedString = [[NSAttributedString alloc] initWithString:eventName
                                                                 attributes:[self textStyle]];
    _dateTextNode = [[ASTextNode alloc] init];
    _dateTextNode.layerBacked = YES;
    _dateTextNode.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", eventDetails[[BounceConstants firebaseEventsChildEventDate]], eventDetails[[BounceConstants firebaseEventsChildEventTime]]]
                                                                     attributes:[self textStyleItalic]];
    _dateTextNode.maximumNumberOfLines = 1;
    _dateTextNode.truncationMode = NSLineBreakByTruncatingTail;
    
    _eventPageButton = [ASButtonNode new];
    
    [self addSubnode:_textNode];
    [self addSubnode:_followButton];
    [self addSubnode:_cameraButton];
//    [self addSubnode:_numberInterested];
    [self addSubnode:_orgProfilePhoto];
    [self addSubnode:_dateTextNode];
    
    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    [self addSubnode:_divider];
    
    return self;
}


-(void)orgPhotoClicked{
    
    NSDictionary *eventDetails = [_snapShot getPostDetails];
    NSString* orgId = eventDetails[[BounceConstants firebaseEventsChildOrgId]];
    id<MyEventsOrgImageClickedDelegate> strongDelegate = self.myEventsOrgImageDelegate;
    if ([strongDelegate respondsToSelector:@selector(orgClicked:)]) {
        [strongDelegate orgClicked:orgId];
    }
    
}

-(void)buttonTapped{
    
    if(_followButton.selected){
        
        id<MyEventsNodeDelegate> strongDelegate = self.myEventsNodeDelegate;
        if ([strongDelegate respondsToSelector:@selector(unfollowClicked:)]) {
            [strongDelegate unfollowClicked:_snapShot.key];
        }
        
    }
    
}

-(void)cameraTapped{
    
    NSDictionary *eventDetails = [_snapShot getPostDetails];
    NSString *eventId = eventDetails[@"eventID"];
    NSString *eventDate = eventDetails[@"eventDate"];
    NSString *eventTime = eventDetails[@"eventTime"];
    NSString *orgId = eventDetails[@"orgID"];
    NSString *homefeedMediaKey = _snapShot.key;
    NSString *orgProfileImage = eventDetails[@"orgProfileImage"];
    NSNumber *eventDateObject = eventDetails[@"eventDateObject"];
    NSString *eventName = eventDetails[@"eventName"];
    
    id<MyEventsCameraClickedDelegate> strongDelegate = self.myEventsCamerClickedDelegate;
    if ([strongDelegate respondsToSelector:@selector(openCamera:eventDate:eventTime:orgId:homefeedMediaKey:orgProfileImage:eventDateObject:eventName:)]) {
        [strongDelegate openCamera:eventId eventDate:eventDate eventTime:eventTime orgId:orgId homefeedMediaKey:homefeedMediaKey orgProfileImage:orgProfileImage eventDateObject:eventDateObject eventName:eventName];
    }
    
}

- (NSDictionary *)textStyleItalic{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
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

-(FIRDatabaseReference*) getFollowersReference{
    //    return [[[self.ref child:@"Bounce"] child:@"Followers"] childByAutoId];
    return [[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:@"eventsFollowed"] childByAutoId];
}

- (NSDictionary *)textStyle{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
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

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    

    CGFloat kInsetTop = 6.0;
 
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;
    
    //    NSLog(@"screenwidth: %f", screenWidth);
    
    NSArray *info = @[ _textNode, _dateTextNode];
    
    NSArray *info_2 = @[ _followButton, _cameraButton];;
    

    if(isAdminOf){
        _followButton.hidden = YES;
        _cameraButton.hidden = NO;
       
    }else{
        _followButton.hidden = NO;
        _cameraButton.hidden = YES;

    }

    ASStackLayoutSpec *infoStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                                    justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStart children:info];
    
    ASStackLayoutSpec *followingRegion = followingRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
                                                                                            justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:info_2];
    
//    if(isAdminOf){
//        followingRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
//                                                                              justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:@[_cameraButton]];
//    }else{
//        followingRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
//                                                                              justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:@[_followButton]];
//    }
    
    
//    ASStackLayoutSpec *followingRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
//                                                                          justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:info_2];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, 0, 0, 10);
    
    ASInsetLayoutSpec *orgPhotoInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:_orgProfilePhoto];

    ASStackLayoutSpec *infoStack_2  = [ASStackLayoutSpec horizontalStackLayoutSpec];
    infoStack_2.direction = ASStackLayoutDirectionHorizontal;
    infoStack_2.alignItems         = ASStackLayoutAlignItemsStretch;
    infoStack_2.justifyContent     = ASStackLayoutJustifyContentCenter;
    infoStack_2.children = @[orgPhotoInset,infoStack, horizontalSpacer,followingRegion];

    UIEdgeInsets insets_2 = UIEdgeInsetsMake(10, 10, 10, 10);
    
    ASInsetLayoutSpec *spec_2 = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets_2 child:infoStack_2];

    ASInsetLayoutSpec *lastSpecs = [[ASInsetLayoutSpec alloc] init];
    lastSpecs.insets = UIEdgeInsetsMake(0, 0, kInnerPadding, 0);
    lastSpecs.child = spec_2;
    
    return lastSpecs;
}

@end

