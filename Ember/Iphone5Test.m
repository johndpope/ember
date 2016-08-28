//
//  Iphone5Test.m
//  Ember
//
//  Created by Gabriel Wamunyu on 8/28/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Iphone5Test.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface Iphone5Test() {
    
}

@end

@implementation Iphone5Test

-(instancetype)init{
    if (!(self = [super init]))
        return nil;
    
    return self;
}

+(BOOL)isIphone5{
    return IS_IPHONE_5;
}

@end