//
//  BounceNode.m
//  thrive
//
//  Created by Gabriel Wamunyu on 3/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmberNode.h"
#import "Video.h"
#import "EmberVideoNode.h"
#import "EmberImageNode.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@import Firebase;


@interface EmberNode ()<UIGestureRecognizerDelegate>{
    
    EmberImageNode *_imageNode;
    EmberVideoNode *_videoNode;
    ASTextNode *_textNode;
    ASDisplayNode *_divider;
    BOOL _swappedTextAndImage;
    ASTextNode *_dateTextNode;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    NSString *_url;
    CALayer *_placeholderLayer;
    UITapGestureRecognizer *tap;
    BOOL isFullScreen;
    CGRect prevFrame;
    ASButtonNode *_buttonNode;
    NSDictionary *_eventDetails;
    NSArray *values;
    EmberSnapShot *_snapShot;
    UITapGestureRecognizer *_buttonTap;
    UITapGestureRecognizer *_imageTap;
    NSString *_userName;
}

@end

@implementation EmberNode

-(ASVideoNode *)getSubVideoNode{
    return _videoNode.getVideoNode;
}

-(ASImageNode *)getVideoImageNode{
    return _imageNode.getVideoImageNode;
}

-(EmberVideoNode *)getSuperVideoNode{
    return _videoNode;
}

-(EmberImageNode *)getSuperImageNode{
    return _imageNode;
}

-(ASNetworkImageNode *)getSubImageNode{
    return _imageNode.getImageNode;
}

-(UITapGestureRecognizer*)getButtonTap{
    return _buttonTap;
}

-(UITapGestureRecognizer*)getImageTap{
    return _imageTap;
}
-(EmberSnapShot*)getBounceSnapShot{
    return _snapShot;
}

-(instancetype)initWithEvent:(EmberSnapShot *)snapShot upcoming:(BOOL)upcoming{
    if (!(self = [super init]))
        return nil;
    
    _snapShot = snapShot;
    _buttonNode = [[ASButtonNode alloc] init];
    

    _eventDetails = [snapShot getPostDetails];
//    NSLog(@"eventDetails: %@", _eventDetails);

    
    if(_eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]]){
        
        _url = _eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]];
        if(_url != nil){
            
            if([_url containsString:@"mp4"]  || [_url containsString:@"mov"]){
                _videoNode = [[EmberVideoNode alloc] initWithEvent:snapShot];
                
                [self addSubnode:_videoNode];
                
            }else{
                _imageNode = [[EmberImageNode alloc] initWithEvent:snapShot];
                
                if(!upcoming){
                    [_imageNode setFollowButtonHidden];
                    [_imageNode showFireCount];
                }
                
                [self addSubnode:_imageNode];
                
               
            }
        }
        
    }else{
        if([_eventDetails[[BounceConstants firebaseHomefeedMediaInfo]] isKindOfClass:[NSDictionary class]]){
            values = [_eventDetails[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
            if ([values count] != 0){
                NSDictionary *first = [values objectAtIndex:0];
                _url = first[@"mediaLink"];
                _userName = first[@"userID"];
            }
            
        }else{
            values = _eventDetails[[BounceConstants firebaseHomefeedMediaInfo]];
            NSDictionary *first = [values objectAtIndex:0];

            _url = first[@"mediaLink"];
            _userName = first[@"userID"];
            
        }
        
        
        if([_url containsString:@"mp4"]  || [_url containsString:@"mov"]){
            _videoNode = [[EmberVideoNode alloc] initWithEvent:snapShot];
            
            [_videoNode setFollowButtonHidden];
            [_videoNode showFireCount];
            [_videoNode setIsVideo];
            
            [self addSubnode:_videoNode];
            
        }else{
            _imageNode = [[EmberImageNode alloc] initWithEvent:snapShot];
            
            [_imageNode setFollowButtonHidden];
            [_imageNode showFireCount];
            
            [self addSubnode:_imageNode];
            [self addSubnode:_buttonNode];

        }
      
    }
   
    return self;
}

-(void)didLoad{
    [super didLoad];
    
    _buttonTap = [[UITapGestureRecognizer alloc]
                  initWithTarget:self
                  action:@selector(buttonTapped)];
    _buttonTap.numberOfTapsRequired = 1;
    _buttonTap.delegate = self;
    [_buttonNode.view addGestureRecognizer:_buttonTap];
    [_buttonNode setUserInteractionEnabled:YES];
    
    if(_eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]]){
        
        if(![_url containsString:@"mp4"]  && ![_url containsString:@"mov"]){
            
            _imageTap = [[UITapGestureRecognizer alloc]
                         initWithTarget:self
                         action:@selector(imageTapped)];
            _imageTap.numberOfTapsRequired = 1;
            _imageTap.delegate = self;
            [self.view addGestureRecognizer:_imageTap];
        }
        
        
        // Enabling long press for Event Posters so that gallery images can only be reported if the user opens the
        // full screen image
        UILongPressGestureRecognizer *longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressRecognizer)];
        
        longPressGestureRecognizer.numberOfTouchesRequired = 1;
        longPressGestureRecognizer.minimumPressDuration = 0.2;
        [longPressGestureRecognizer requireGestureRecognizerToFail:[self getButtonTap]];
        if([self getImageTap]){
            [longPressGestureRecognizer requireGestureRecognizerToFail:[self getImageTap]];
        }
        
        longPressGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:longPressGestureRecognizer];
        
    }else{
        
        
        
    }
    

    
}

-(void)handleLongPressRecognizer{
   
    id<LongPressDelegate> strongDelegate = self.longPressDelegate;
    if ([strongDelegate respondsToSelector:@selector(longPressDetected:)]) {
        [strongDelegate longPressDetected:_snapShot];
    }
}

-(void)imageTapped{
    
        id<BounceImageClickedDelegate> strongDelegate = self.imageDelegate;
        if ([strongDelegate respondsToSelector:@selector(bounceImageClicked:)]) {
            [strongDelegate bounceImageClicked:_snapShot];
        }
}

// TODO - If video file is the first in the gallery all other files in the array
// will not be displayed coz a button click causes video to play instead
// of opening gallery

/**
 *  Called when the button layer over a gallery is clicked on the homefeed
 */

-(void)buttonTapped{
    
    id<ImageClickedDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(childNode:didClickImage:withLinks:withHomeFeedID:)]) {
        [strongDelegate childNode:self didClickImage:_imageNode.getImageNode.image withLinks:values withHomeFeedID: _snapShot.key];
    }
}

-(void)cellNodeVisibilityEvent:(ASCellNodeVisibilityEvent)event inScrollView:(UIScrollView *)scrollView withCellFrame:(CGRect)cellFrame{
    
    if(event == ASCellNodeVisibilityEventVisible && _videoNode.getVideoNode.isPlaying){
        [_videoNode.getVideoNode pause];
    }
    if(event == ASCellNodeVisibilityEventWillBeginDragging && _videoNode.getVideoNode.isPlaying){
        [_videoNode.getVideoNode pause];
    }
    
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
//    _placeholderLayer = [[CALayer alloc] init];
//    _placeholderLayer.contents = [UIImage imageNamed:@"cardPlaceholder"].CIImage;
//    _placeholderLayer.contentsGravity = kCAGravityCenter;
//    _placeholderLayer.contentsScale = [UIScreen mainScreen].scale;
//    _placeholderLayer.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1].CGColor;
//    [self.layer addSublayer:_placeholderLayer];
    
    
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {

    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
   // CGFloat height = [UIScreen mainScreen].bounds.size.height;

//    CGFloat cellWidth                  = constrainedSize.max.width;
//    NSLog(@"screen width: %f", cellWidth);
    _buttonNode.preferredFrameSize = CGSizeMake(width, width * 0.8);
//    _imageNode.preferredFrameSize = CGSizeMake(cellWidth, cellWidth * 0.8);
    ASStaticLayoutSpec *spec = [ASStaticLayoutSpec staticLayoutSpecWithChildren:@[_buttonNode]];
    
    _placeholderLayer.frame = self.bounds;
    _textNode.flexShrink = YES;
    
    ASStackLayoutSpec *stackSpec = nil;
    
    
    if(_url != nil){
        
        if([_url containsString:@"mp4"] || [_url containsString:@"mov"]){
                stackSpec = [[ASStackLayoutSpec alloc] init];
                [stackSpec setChildren:@[_videoNode]];
        }else{
            ASOverlayLayoutSpec *bG = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_imageNode overlay:spec];
            stackSpec = [[ASStackLayoutSpec alloc] init];
            [stackSpec setChildren:@[bG]];
            }
    }else{
        stackSpec = [[ASStackLayoutSpec alloc] init];
        [stackSpec setChildren:@[_videoNode]];
    }
    
    return stackSpec;
}

@end
