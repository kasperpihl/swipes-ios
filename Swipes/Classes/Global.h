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

#define LOCALIZE_STRING(string) NSLocalizedString(string, nil)

@interface Global : NSObject

+ (Global *)sharedInstance;
+ (NSInteger)OSVersion;
+ (BOOL)is24Hour;
+ (NSDateFormatter *)isoDateFormatter;
+ (NSString*)iconStringForString:(NSString*)iconString;
+ (NSURL *)coreDataUrl;
+ (void)initCoreData;
+ (NSUserDefaults *)sharedDefaults;
+ (void)clearUserDefaults;
+ (BOOL)supportsOrientation:(UIDeviceOrientation)orientation;
+ (UILabel*)iconLabelWithString:(NSString*)iconString height:(CGFloat)height;
@property (nonatomic) CGFloat fontMultiplier;

@end
