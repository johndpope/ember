//
//  FollowNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FollowNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASButtonNode.h>

@import Firebase;


@interface FollowNode (){
    
    ASTextNode *_textNode;
    ASButtonNode *_followButton;
    NSMutableDictionary*_orgs;
    FIRUser *_user;
    EmberSnapShot*_snapShot;
    
}

@end

@implementation FollowNode

-(instancetype)initWithSnapShot:(EmberSnapShot*)snapShot{
    self = [super init];

    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _user = [FIRAuth auth].currentUser;
    _orgs = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    if(self){
      
        _snapShot = snapShot;
        
        _textNode = [[ASTextNode alloc] init];
        _textNode.attributedString = [[NSAttributedString alloc] initWithString:@"Follow"
                                                                     attributes:[self textStyle]];
        _textNode.placeholderColor = [UIColor whiteColor];
        
        
        _followButton = [[ASButtonNode alloc] init];
        [_followButton setImage:[UIImage imageNamed:@"plus-small"] forState:ASControlStateNormal];
        [_followButton setImage:[UIImage imageNamed:@"event-selected-small"] forState:ASControlStateSelected];
        
//        NSLog(@"Key: %@, value: %@", snapShot.key, snapShot.value);
        if(snapShot != nil && [[NSUserDefaults standardUserDefaults] objectForKey:snapShot.key] != nil){
            [_followButton setSelected:YES];
        }else{
            [_followButton setSelected:NO];
        }
        
        
        [_followButton addTarget:self
                          action:@selector(buttonTapped)
                forControlEvents:ASControlNodeEventTouchDown];
        
        
        
        [self addSubnode:_textNode];
        [self addSubnode:_followButton];
    }
    
    return self;
}



-(void)buttonTapped{
    
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

-(FIRDatabaseReference*) getOrgListOfFollowersReference{
    return [[[[_ref child:[BounceConstants firebaseOrgsChild]] child:_snapShot.key] child:@"followers"] child:_user.uid];
}

-(FIRDatabaseReference*) getOrgFollowersReference{
    return [[[[_ref child:[BounceConstants firebaseUsersChild]] child:_user.uid] child:[BounceConstants firebaseUsersChildOrgsFollowed]] child:_snapShot.key];
}

- (NSDictionary *)textStyle{
    UIFont *font = [UIFont systemFontOfSize:30.0f];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGFloat kInsetHorizontal = 16.0;
    CGFloat kInsetTop = 6.0;
    CGFloat kInsetBottom = 6.0;
    
    
    NSArray *info = @[_textNode, _followButton];
    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _textNode.flexShrink = YES;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(kInsetTop, kInsetHorizontal, kInsetBottom, kInsetHorizontal);
    
    ASStackLayoutSpec *followingStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:3.0 justifyContent:ASStackLayoutJustifyContentStart alignItems:ASStackLayoutAlignItemsCenter children:info];
    
    ASInsetLayoutSpec *followingSpecs = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:followingStack];
  
    
    return followingSpecs;
}

@end
