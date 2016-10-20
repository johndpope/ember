//
//  BounceNode.h
//  thrive
//
//  Created by Gabriel Wamunyu on 3/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>
#import "EmberVideoNode.h"
#import "EmberImageNode.h"
#import "EmberSnapShot.h"

@protocol ImageClickedDelegate;
@protocol BounceImageClickedDelegate;
@protocol LongPressDelegate;

@interface EmberNode : ASCellNode

@property (nonatomic, weak) id<ImageClickedDelegate> delegate;
@property (nonatomic, weak) id<BounceImageClickedDelegate> imageDelegate;
@property (nonatomic, weak) id<LongPressDelegate> longPressDelegate;

- (instancetype)initWithEvent:(EmberSnapShot *)snapShot;
-(ASVideoNode *)getSubVideoNode;
-(ASNetworkImageNode *)getSubImageNode;
-(EmberVideoNode *)getSuperVideoNode;
-(EmberImageNode *)getSuperImageNode;
-(ASImageNode *)getVideoImageNode;
-(UITapGestureRecognizer*)getButtonTap;
-(UITapGestureRecognizer*)getImageTap;
-(EmberSnapShot*)getBounceSnapShot;
@end

@protocol ImageClickedDelegate <NSObject>

- (void)childNode:(EmberNode*)childImage
    didClickImage:(UIImage*)image withLinks:(NSArray*)array withHomeFeedID:(NSString*)homefeedID;

@end

@protocol BounceImageClickedDelegate <NSObject>

- (void)bounceImageClicked:(EmberSnapShot*)snap;

@end
@protocol LongPressDelegate <NSObject>

- (void)longPressDetected:(EmberSnapShot*)snap;

@end


