//
//  EventTitleNode.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

//
//  BounceImageNode.m
//  thrive
//
//  Created by Gabriel Wamunyu on 3/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventTitleNode.h"
#import "Video.h"
#import "OrgNode.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;

static const CGFloat kInnerPadding = 10.0f;


@interface EventTitleNode (){
    
    ASNetworkImageNode *_imageNode;
    ASDisplayNode *_divider;
    ASDisplayNode *_divider2;
    BOOL _swappedTextAndImage;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    ASTextNode*_test;
    EmberSnapShot*_snapShot;
    NSMutableDictionary*_events;
    FIRUser *_user;
    FIRDatabaseReference *_ref;
    ASTextNode *_orgName;
    OrgNode *_orgNode;
    ASTextNode *_seeWhatsHappening;
    ASTextNode *_eventTags;
    NSMutableArray *_tagsArray;
    ASDisplayNode *_backGround;
    NSMutableArray *_alltags;
}

@end

@implementation EventTitleNode


-(ASNetworkImageNode *)getImageNode{
    return _imageNode;
}


-(ASTextNode *)getOrgNameNode{
    return _orgName;
}


- (instancetype)initWithEvent:(EmberSnapShot*)snapShot{
    if (!(self = [super init]))
        return nil;
    
    _ref = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _events = [[NSMutableDictionary alloc]initWithCapacity:10];
    _snapShot = snapShot;
    NSDictionary *eventDetails = [snapShot getPostDetails];
    
    _tagsArray = [NSMutableArray new];
    
    _imageNode = [[ASNetworkImageNode alloc] init];
    _imageNode.layerBacked = YES;
    
    _backGround.backgroundColor = [BounceConstants primaryAppColor];
    
    _orgNode = [[OrgNode alloc] initWithBounceSnapShot:snapShot];
    
    [self addSubnode: _imageNode];
    

    _orgName = [[ASTextNode alloc] init];
    _orgName.layerBacked = YES;
    
    _eventTags = [ASTextNode new];
    _eventTags.layerBacked = YES;
    
    
    _alltags = [NSMutableArray new];
    
    
    if(eventDetails[@"eventTags"]){
       
        
        NSArray *eventTags = eventDetails[@"eventTags"];

        NSUInteger index = 0;
        
        NSUInteger whileCount = 0;
        
        while(index < eventTags.count){
            
            whileCount++;
            
            NSUInteger count = 10;
            
            NSUInteger indexCount = 0;
            
            ASStackLayoutSpec *tagsStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
            tagsStack.justifyContent = ASStackLayoutJustifyContentStart;
            tagsStack.alignItems = ASStackLayoutAlignItemsStretch;
            tagsStack.spacingAfter = 5;
           
            for(NSUInteger i = index; i < eventTags.count; i++){
                
                ASTextNode *tag = [ASTextNode new];
                tag.backgroundColor = [BounceConstants primaryAppColor];
                tag.cornerRadius = 4;
                tag.borderWidth = 1.0;
                tag.clipsToBounds = YES;
                tag.borderColor = [[BounceConstants primaryAppColor] CGColor];
                tag.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@   ", [eventTags objectAtIndex:index]] attributes:[self tagTextStyle]];
                tag.preferredFrameSize = CGSizeMake(tag.attributedString.size.width + 20, tag.attributedString.size.height);
                
                [_alltags addObject:tag];
                
                count += tag.attributedString.size.width + 20;
                
                if(count >= [UIScreen mainScreen].bounds.size.width){
                    [_tagsArray addObject:tagsStack];
                    break;
                }else{
                    
                    ASBackgroundLayoutSpec *back = [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:tag background:_backGround];
                    ASInsetLayoutSpec *spec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 10, 0, 0) child:back];
                    [tagsStack setChild:spec forIndex:indexCount];
                    
                    index++;
                    indexCount++;
                    
                    
                }
              
            }
            
            if(whileCount != _tagsArray.count){
                [_tagsArray addObject:tagsStack];
            }
            
        }
        
        
        
    }
    
    _seeWhatsHappening = [ASTextNode new];
    _seeWhatsHappening.attributedString = [[NSAttributedString alloc] initWithString:@"See what's happening" attributes:[self textStyleLeft]];
    
    _seeWhatsHappening.spacingBefore = 10;
    _seeWhatsHappening.spacingAfter = 10;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _orgName.attributedString = [[NSAttributedString alloc] initWithString:@" " attributes:[self textStyleOrgName]];
    _orgName.maximumNumberOfLines = 1;
                           
    _orgName.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _orgName.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _orgName.attributedString.size.height)));
   
    
    [self addSubnode:_orgName];
 
    [self addSubnode:_orgNode];
    
    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    _divider.spacingBefore = 10;
    _divider.preferredFrameSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 1.0);
    [self addSubnode:_divider];
    
    _divider2= [[ASDisplayNode alloc] init];
    _divider2.backgroundColor = [UIColor lightGrayColor];
    _divider2.spacingBefore = 10;
    _divider2.preferredFrameSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 1.0);
    [self addSubnode:_divider2];
    
    if(_alltags.count > 0){
 
        for(NSUInteger i = 0; i < _alltags.count; i++){
   
        [self addSubnode:[_alltags objectAtIndex:i]];
            
        }
 
    }
    [self addSubnode:_seeWhatsHappening];
    
    
    
    return self;
}


-(FIRDatabaseReference*) getFollowersReference{
    return [[[[_ref child:@"users"] child:_user.uid] child:@"eventsFollowed"] childByAutoId];
}

- (NSDictionary *)textStyleLeft{
    
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
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)tagTextStyle{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
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

- (NSDictionary *)textStyleOrgName{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:18.0f];
    }else{
        font = [UIFont systemFontOfSize:20.0f];
    }
    
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
}

- (void)layout
{
    [super layout];
    
    // Manually layout the divider.
//    CGFloat pixelHeight = 1.0f / [[UIScreen mainScreen] scale];
//    _divider.frame = CGRectMake(0.0f, 0.0f, self.calculatedSize.width, pixelHeight);
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
//    CGFloat kInsetHorizontal = 16.0;
//    CGFloat kInsetTop = 6.0;
//    CGFloat kInsetBottom = 6.0;
    
    ASLayoutSpec *horizontalSpacer =[[ASLayoutSpec alloc] init];
    horizontalSpacer.flexGrow = YES;
    
    _backGround.flexGrow = YES;
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _imageNode.preferredFrameSize = CGSizeMake(width, width);
    
    
    UIEdgeInsets insetsName = UIEdgeInsetsMake(0, 0, 0, 20);
    
    ASInsetLayoutSpec *specName = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insetsName child:_orgName];
    
    ASStackLayoutSpec *orgPhotoStackVert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0
                                                                        justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[horizontalSpacer, specName]];
    
    ASOverlayLayoutSpec *overlay = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_imageNode overlay:orgPhotoStackVert];
    
    ASInsetLayoutSpec *specOrgNode = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(kInnerPadding, 10, kInnerPadding, 10) child:_orgNode];
    
    ASInsetLayoutSpec *specSeeWhatsHappening = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(kInnerPadding, 10, kInnerPadding, 10) child:_seeWhatsHappening];
    
    ASStackLayoutSpec *textStack_2 = nil;
    
    if(_tagsArray.count > 0){
        
        NSMutableArray *arr = [NSMutableArray new];
        [arr addObject:specOrgNode];
        [arr addObjectsFromArray:_tagsArray];
        [arr addObject:_divider];
        [arr addObject:specSeeWhatsHappening];
        [arr addObject:_divider2];
      
        textStack_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:arr];
    }else{
        textStack_2 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[specOrgNode,_divider,specSeeWhatsHappening, _divider2]];
    }
    
    
    ASStackLayoutSpec *textStack_3 = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[overlay, textStack_2]];
    
    
    return textStack_3;
}

@end
