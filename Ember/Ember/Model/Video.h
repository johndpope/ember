//
//  Video.h
//  [x]
//
//  Created by Gabriel Wamunyu on 3/10/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASVideoNode.h>

@interface Video : ASVideoNode

- (instancetype)init;

-(UIImage *)placeholderImage;

-(void)setPlaceholderImage:(UIImage*)img;

@end
