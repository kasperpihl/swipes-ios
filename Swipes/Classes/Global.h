//
//  Global.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OSVER [Global OSVersion]

@interface Global : NSObject

+ (Global *)sharedInstance;
+ (NSInteger)OSVersion;
+ (BOOL)is24Hour;
+ (NSDateFormatter *)isoDateFormatter;
+ (CGFloat)statusBarHeight;

@end
