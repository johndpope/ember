//
//  MyEventsNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyEventsNode.h"
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
//static const CGFloat kOrgPhotoWidth = 75.0f;
//static const CGFloat kOrgPhotoHeight = 75.0f;


@interface MyEventsNode () <ASNetworkImageNodeDelegate> {
    
    ASNetworkImageNode *_imageNode;
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
    MyEventsPostDetailsNode *_myeventsPostDetailsNode;
    
}

@end

@implementation MyEventsNode


-(ASNetworkImageNode *)getImageNode{
    return _imageNode;
}

-(MyEventsPostDetailsNode*)getDetailsNode{
    return _myeventsPostDetailsNode;
}



- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _ref = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    _events = [[NSMutableDictionary alloc]initWithCapacity:10];
    _snapShot = snapShot;
 
    _myeventsPostDetailsNode = [[MyEventsPostDetailsNode alloc] initWithEvent:snapShot];
   
//    if([event isEqual:[NSNull null]]){
//        return nil;
//    }
    
    background = [[ASDisplayNode alloc] init];
    background.flexGrow = YES;
    background.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    background.layerBacked = YES;
    
    _imageNode = [[ASNetworkImageNode alloc] init];
    
    // PREVENTS CLICK EVENTS!
//    _imageNode.layerBacked = YES;
    _imageNode.delegate = self;
    [_imageNode addTarget:self action:@selector(eventImageClicked) forControlEvents:ASControlNodeEventTouchDown];
    
    
    [self addSubnode:_myeventsPostDetailsNode];
   

    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    _divider.spacingAfter = 5.0f;
    CGFloat pixelHeight = 1.0f;
    _divider.preferredFrameSize = CGSizeMake(screenWidth, pixelHeight);
    [self addSubnode:_divider];
    
    return self;
}

-(void)eventImageClicked{
    id<MyEventsImageClickedDelegate> strongDelegate = self.myEventsImageDelegate;
    if ([strongDelegate respondsToSelector:@selector(myEventsImageClicked:)]) {
        [strongDelegate myEventsImageClicked:_snapShot];
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
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    //    CGFloat kInsetHorizontal = 16.0;
//    CGFloat kInsetTop = 6.0;
    //    CGFloat kInsetBottom = 6.0;
    
    //    CGFloat kOuterPadding = 10.0f;
    
    //    NSLog(@"screen width: %f", screenWidth);
    _imageNode.contentMode = UIViewContentModeScaleAspectFill;
    _imageNode.preferredFrameSize = CGSizeMake(screenWidth, screenWidth * 0.8);
    
    _myeventsPostDetailsNode.flexGrow = YES;
    _myeventsPostDetailsNode.preferredFrameSize = CGSizeMake(screenWidth, constrainedSize.max.height);
    
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;
    
//    ASBackgroundLayoutSpec *bG = [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:_imageNode background:_imageNode];
//    
    ASStackLayoutSpec *vert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[_myeventsPostDetailsNode, _divider]];
    
    ASInsetLayoutSpec *lastSpecs = [[ASInsetLayoutSpec alloc] init];
    lastSpecs.insets = UIEdgeInsetsMake(0, 0, kInnerPadding, 0);
    lastSpecs.child = vert;
    
    return lastSpecs;
}



@end
