//
//  SubOrgTitleNode.h
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/15/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import <UIKit/UIKit.h>

#import "EmberSnapShot.h"
#import "bounceapp-Swift.h"

@import Firebase;

@interface SubOrgTitleNode : ASCellNode

@property(strong, nonatomic) FIRDatabaseReference *ref;
@property(strong, nonatomic) NSString *orgID;
- (instancetype)initWithEvent:(EmberSnapShot*)orgInfo;

-(ASNetworkImageNode*) getImageNode;
-(OrgDetailsNode*)getOrgDetailsNode;
-(ASTextNode *) getTextNode;
-(ASButtonNode *)getButtonNode;
- (NSDictionary *)textStyle;

@end
