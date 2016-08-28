//
//  Video.m
//  [x]
//
//  Created by Gabriel Wamunyu on 3/10/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"


#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>

#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@interface Video(){
    ASVideoNode *_videoNode;
    BOOL _placeholderEnabled;
    UIImage *placeholderImage;
    
}

@end
@implementation Video

- (instancetype)init{
    if (!(self = [super init]))
        return nil;
    
    _videoNode = [[ASVideoNode alloc] init];
    _videoNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _videoNode.player.muted = NO;
    
    return self;
    
}

-(UIImage *)placeholderImage{
    return placeholderImage;
}

-(void)setPlaceholderEnabled:(BOOL)placeholderEnabled{
    _placeholderEnabled = placeholderEnabled;
}

-(void)setPlaceholderImage:(UIImage*)img{
    placeholderImage = img;
}

@end
