//
//  EmberImageNode.h
//  thrive
//
//  Created by Gabriel Wamunyu on 3/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>
#import "EmberSnapShot.h"
#import "EmberDetailsNode.h"
@import Firebase;



@interface EmberImageNode : ASCellNode <ASNetworkImageNodeDelegate>

@property(strong, nonatomic) FIRDatabaseReference *ref;
- (instancetype)initWithEvent:(EmberSnapShot *)event;

-(ASNetworkImageNode*) getImageNode;
-(EmberDetailsNode*)getDetailsNode;
- (NSDictionary *)textStyle;
-(ASImageNode *)getVideoImageNode;
-(void)setFollowButtonHidden;
-(void)showFireCount;


@end


