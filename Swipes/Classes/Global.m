//
//  Global.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "Global.h"

@implementation Global
static Global *sharedObject;
+(Global *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[Global allocWithZone:NULL] init];
    }
    return sharedObject;
}
+ (NSInteger)OSVersion
{
    
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}
@end
