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
    ASDisplayNode *background;
    EmberSnapShot*_snapShot;
    NSMutableDictionary*_events;
    FIRUser *_user;
    FIRDatabaseReference *_ref;
    ASTextNode *_text;
    float _scale;
    float _imageHeight;
    CGFloat screenWidth;
    ASTextNode *_interested;
    ASButtonNode* _followButton;
    ASNetworkImageNode *_orgProfilePhoto;
    ASTextNode *_dateTextNode;
}


@end

@implementation MyEventsPostDetailsNode


-(ASTextNode *)getTextNode{
    return _textNode;
}


-(void)fetchOrgProfilePhotoUrl:(NSString*) orgId{
    
    FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:[BounceConstants firebaseOrgsChild]] child:orgId]  queryLimitedToFirst:100];
    [[recentPostsQuery queryOrderedByKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSDictionary * event = snapShot.value;
        //        NSLog(@"%@", event[[BounceConstants firebaseOrgsChildSmallImageLink]]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _orgProfilePhoto.URL = [NSURL URLWithString:event[[BounceConstants firebaseOrgsChildSmallImageLink]]];
            
        });
    }];
}



- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _ref = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _events = [[NSMutableDictionary alloc]initWithCapacity:10];
    _snapShot = snapShot;
    //    NSDictionary* event = snapShot.value;
    NSDictionary *eventDetails = [snapShot getPostDetails];
    
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
    
    _interested = [[ASTextNode alloc] init];
    _interested.attributedString = [[NSAttributedString alloc] initWithString:@"Interested"
                                                                   attributes:[self textStyle]];
    
    //    NSLog(@"key: %@", _snapShot.key);
    if([[NSUserDefaults standardUserDefaults] objectForKey:_snapShot.key] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:_snapShot.key] isEqualToString:@"pastFireCount"]){
        [_followButton setSelected:YES];
        NSDictionary *attrDict = @{
                                   NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0],
                                   NSForegroundColorAttributeName : [UIColor colorWithRed: 32.0/255.0 green: 173.0/255.0 blue: 5.0/255.0 alpha: 1.0]
                                   };
        _interested.attributedString = [[NSAttributedString alloc] initWithString:@"Interested"
                                                                       attributes:attrDict];
    }else{
        
        [_followButton setSelected:NO];
    }
    
    
    [_followButton addTarget:self
                      action:@selector(buttonTapped)
            forControlEvents:ASControlNodeEventTouchDown];
    
    //    if([event isEqual:[NSNull null]]){
    //        return nil;
    //    }
    
    background = [[ASDisplayNode alloc] init];
    background.flexGrow = YES;
    background.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    background.layerBacked = YES;
    
    [self addSubnode:background];
    
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
    
    
  
    [self addSubnode:_textNode];
    [self addSubnode:_followButton];
    [self addSubnode:_interested];
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
    return [[[[_ref child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:@"eventsFollowed"] childByAutoId];
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

-(void)scalingTemplate{
    
    
    //    float widthRatioText = screenWidth / _textNode.calculatedSize.width;
    //    float heightRatioText = _textNode.calculatedSize.height;
    //    float scaleText = MIN(widthRatioText, heightRatioText);
    //    float imageWidthText = scaleText * _textNode.calculatedSize.width;
    //    float imageHeightText = scaleText * _textNode.calculatedSize.height;
    
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    

    CGFloat kInsetTop = 6.0;
 
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;
    
    //    NSLog(@"screenwidth: %f", screenWidth);
    
    NSArray *info = @[ _textNode, _dateTextNode];
    NSArray *info_2 = @[_followButton, _interested];
    
    ASStackLayoutSpec *infoStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                                    justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStart children:info];
    
    
    ASStackLayoutSpec *followingRegion = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
                                                                          justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:info_2];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, 0, 0, 10);
    
    ASInsetLayoutSpec *orgPhotoInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:_orgProfilePhoto];
    

    
    ASStackLayoutSpec *infoStack_2  = [ASStackLayoutSpec horizontalStackLayoutSpec];
    infoStack_2.direction = ASStackLayoutDirectionHorizontal;
    infoStack_2.alignItems         = ASStackLayoutAlignItemsStretch;
    infoStack_2.justifyContent     = ASStackLayoutJustifyContentCenter;
    infoStack_2.children = @[orgPhotoInset,infoStack, horizontalSpacer,followingRegion];

    

    UIEdgeInsets insets_2 = UIEdgeInsetsMake(10, 10, 10, 10);
    
    ASInsetLayoutSpec *spec_2 = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets_2 child:infoStack_2];
    
    
    
    // MAKES NODE STRETCH TO FILL AVAILABLE SPACE
    //            spec_2.flexGrow = YES;
    
    
    ASInsetLayoutSpec *lastSpecs = [[ASInsetLayoutSpec alloc] init];
    lastSpecs.insets = UIEdgeInsetsMake(0, 0, kInnerPadding, 0);
    lastSpecs.child = spec_2;
    
    return lastSpecs;
}



@end

