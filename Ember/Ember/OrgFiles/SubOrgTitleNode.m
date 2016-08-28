//
//  SubOrgTitleNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/15/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubOrgTitleNode.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;

static const CGFloat kInnerPadding = 10.0f;

@interface SubOrgTitleNode (){
    
    ASNetworkImageNode *_imageNode;
    ASTextNode *_textNode;
    ASDisplayNode *_divider;
    BOOL _swappedTextAndImage;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    ASDisplayNode *background;
    ASButtonNode* _followButton;
    ASTextNode*_test;
    EmberSnapShot*_snapShot;
    NSMutableDictionary*_events;
    FIRUser *_user;
    FIRDatabaseReference *_ref;
    OrgDetailsNode *_orgNode;
    NSString* orgId;
}

@end

@implementation SubOrgTitleNode


-(ASNetworkImageNode *)getImageNode{
    return _imageNode;
}

-(ASTextNode *)getTextNode{
    return _textNode;
}

-(ASButtonNode *)getButtonNode{
    return _followButton;
}

-(OrgDetailsNode*)getOrgDetailsNode{
    return _orgNode;
}

- (instancetype)initWithEvent:(EmberSnapShot*)orgInfo{
    if (!(self = [super init]))
        return nil;
    
    _ref = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _events = [[NSMutableDictionary alloc]initWithCapacity:10];
    _snapShot = orgInfo;
 

    background = [[ASDisplayNode alloc] init];
    background.flexGrow = YES;
    background.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    background.layerBacked = YES;
    
    _imageNode = [[ASNetworkImageNode alloc] init];
//    _imageNode.layerBacked = YES;
    
    
    _orgNode = [[OrgDetailsNode alloc] initWithOrgInfo:orgInfo];
    
    [self addSubnode: _imageNode];
    
    [self addSubnode:background];
    
    _textNode = [[ASTextNode alloc] init];
    
    _followButton = [[ASButtonNode alloc] init];
    [_followButton setImage:[UIImage imageNamed:@"plus-not-filled"] forState:ASControlStateNormal];
    [_followButton setImage:[UIImage imageNamed:@"event-selected"] forState:ASControlStateSelected];
    
    if(orgInfo != nil && [[NSUserDefaults standardUserDefaults] objectForKey:orgInfo.key] != nil){
        [_followButton setSelected:YES];
    }else{
        [_followButton setSelected:NO];
    }
    

    [_followButton addTarget:self action:@selector(followButtonClicked) forControlEvents:ASControlNodeEventTouchDown];
    
    NSDictionary *orgDetails = [orgInfo getData];
    
    _textNode.attributedString = [[NSAttributedString alloc] initWithString:orgDetails[@"orgName"]
                                                                 attributes:[self textStyle]];
    
    
    [self addSubnode:_textNode];
    
    [self addSubnode:_followButton];
    
    [self addSubnode:_orgNode];
    
    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    [self addSubnode:_divider];
    
    return self;
}


-(void)followButtonClicked{
  
    if(_followButton.selected){
        NSString *key = [[NSUserDefaults standardUserDefaults] valueForKey:_snapShot.key];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_snapShot.key];
        [[[[[_ref child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:[BounceConstants firebaseUsersChildOrgsFollowed]] child:key] removeValue];
        
        [[[[[_ref child:[BounceConstants firebaseOrgsChild]] child: _snapShot.key] child:@"followers"] child:_user.uid] removeValue];
   
        [_followButton setSelected:NO];
    }
    else{
        
        FIRDatabaseReference* ref = self.getOrgFollowersReference;
        FIRDatabaseReference *orgListRef = self.getOrgListOfFollowersReference;
        
        [ref setValue:[NSNumber numberWithBool:YES]];
        [orgListRef setValue:[NSNumber numberWithBool:YES]]; // Won't add a new entry since the key is the user ID and using number format of bool
        // since Firebase doesn't allow keys without values
        
        [[NSUserDefaults standardUserDefaults] setValue:ref.key forKey:_snapShot.key];
        [_followButton setSelected:YES];
        
    }
}

-(FIRDatabaseReference*) getOrgFollowersReference{
    return [[[[_ref child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:[BounceConstants firebaseUsersChildOrgsFollowed]] child:_snapShot.key];
}

-(FIRDatabaseReference*) getOrgListOfFollowersReference{
    return [[[[_ref child:[BounceConstants firebaseOrgsChild]] child:_snapShot.key] child:@"followers"] child:_user.uid];
}


-(FIRDatabaseReference*) getFollowersReference{
    return [[[[_ref child:@"users"] child:_user.uid] child:@"eventsFollowed"] childByAutoId];
}

- (NSDictionary *)textStyle{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f];
    }else{
        font = [UIFont systemFontOfSize:20.0f];
    }
     
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGFloat kInsetHorizontal = 16.0;
    CGFloat kInsetTop = 6.0;
    CGFloat kInsetBottom = 6.0;
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;

    NSArray *info = @[_textNode];

    NSArray *followingRegion = @[horizontalSpacer, _followButton];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // 4 : 3 Landscape size of image
    CGFloat height = width * 3/4;
    _imageNode.preferredFrameSize = CGSizeMake(width, height);
    _textNode.flexShrink = YES;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, kInsetHorizontal, kInsetBottom, kInsetHorizontal);
    
    ASStackLayoutSpec *followingStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0 justifyContent:ASStackLayoutJustifyContentStart alignItems:ASStackLayoutAlignItemsBaselineLast children:followingRegion];
    
    ASStackLayoutSpec *infoStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                                    justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:info];
    
    ASInsetLayoutSpec *followingSpecs = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:followingStack];
    
    
    ASInsetLayoutSpec *spec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:infoStack];
    spec.flexGrow = YES;
    
//    UIEdgeInsets insetsName = UIEdgeInsetsMake(0, 0, 0, 20);
    
//    ASInsetLayoutSpec *specName = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insetsName child:_orgName];
    spec.flexGrow = YES;
    
//    ASStackLayoutSpec *orgPhotoStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:1.0
//                                                                        justifyContent:ASStackLayoutJustifyContentStart alignItems:ASStackLayoutAlignItemsBaselineLast children:@[horizontalSpacer, specName]];
    
    ASStackLayoutSpec *textStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentEnd alignItems:ASStackLayoutAlignItemsStretch children:@[followingSpecs, spec]];
    
    
    ASOverlayLayoutSpec *bG = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_imageNode overlay:background];
    
    ASOverlayLayoutSpec *overlay = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:bG overlay:textStack];
    
    
    ASStackLayoutSpec *textStack_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[overlay, _orgNode]];
    
    
    ASInsetLayoutSpec *lastSpecs = [[ASInsetLayoutSpec alloc] init];
    lastSpecs.insets = UIEdgeInsetsMake(kInnerPadding, 0, kInnerPadding, 0);
    lastSpecs.child = overlay;
    
    return textStack_2;
}

@end