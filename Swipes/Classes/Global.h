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
@interface Global : NSObject
@property (nonatomic) CGFloat fontMultiplier;
+ (Global *)sharedInstance;
+ (NSInteger)OSVersion;
+ (BOOL)is24Hour;
+ (NSDateFormatter *)isoDateFormatter;
+ (UILabel*)iconLabelWithString:(NSString*)iconString height:(CGFloat)height;
+ (NSString*)iconStringForString:(NSString*)iconString;
+ (BOOL)supportsOrientation:(UIDeviceOrientation)orientation;
@end
