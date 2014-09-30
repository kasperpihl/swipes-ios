//
//  Global.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OSVER [Global OSVersion]
#define iconString(string) [Global iconStringForString:string]
#define iconLabel(key,iconHeight) [Global iconLabelWithString:key height:iconHeight]
#define iconFont(fontSize) [UIFont fontWithName:@"swipes" size:fontSize]
#define USER_DEFAULTS  [Global sharedDefaults]

@interface Global : NSObject

+ (Global *)sharedInstance;
+ (BOOL)isEvernoteInstalled;
+ (NSInteger)OSVersion;
+ (BOOL)is24Hour;
+ (NSDateFormatter *)isoDateFormatter;
+ (UILabel*)iconLabelWithString:(NSString*)iconString height:(CGFloat)height;
+ (NSString*)iconStringForString:(NSString*)iconString;
+ (BOOL)supportsOrientation:(UIDeviceOrientation)orientation;
+ (NSURL *)coreDataUrl;
+ (NSUserDefaults *)sharedDefaults;

@property (nonatomic) CGFloat fontMultiplier;

@end
