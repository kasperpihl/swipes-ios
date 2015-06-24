//
//  Global.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OSVER [Global OSVersion]
#define iconString(string) string //[Global iconStringForString:string]
#define iconLabel(key,iconHeight) [Global iconLabelWithString:key height:iconHeight]
#define iconFont(fontSize) [UIFont fontWithName:@"swipes" size:fontSize]
#define USER_DEFAULTS  [Global sharedDefaults]

//#undef NSLocalizedString
//#ifndef ONESKY_OTA
//#define NSLocalizedString(key, comment) \
//    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]
//#else
//#define NSLocalizedString(key, comment) \
//    OSLocalizedString(key, comment)
//#endif

extern NSString* const SHARED_GROUP_NAME;
extern NSString* const SHARED_KEYCHAIN_NAME;

@interface Global : NSObject

+ (Global *)sharedInstance;
+ (BOOL)is24Hour;
+ (NSDateFormatter *)isoDateFormatter;
+ (NSString*)iconStringForString:(NSString*)iconString;
+ (NSURL *)coreDataUrl;
+ (NSUserDefaults *)sharedDefaults;
+ (void)clearUserDefaults;

#ifndef APPLE_WATCH

+ (BOOL)isFirstRun;
+ (void)initCoreData;
+ (NSInteger)OSVersion;
+ (BOOL)supportsOrientation:(UIDeviceOrientation)orientation;
+ (UILabel*)iconLabelWithString:(NSString*)iconString height:(CGFloat)height;

@property (nonatomic, assign) CGFloat fontMultiplier;

#endif

@end
