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
+(BOOL)is24Hour{
    static BOOL _is24hour = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
        _is24hour = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    });
    return _is24hour;
}
@end
