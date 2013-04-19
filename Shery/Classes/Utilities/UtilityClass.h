//
//  UtilityClass.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import "LocationClass.h"
#import <Foundation/Foundation.h>
#define UTILITY [UtilityClass instance]
#define DARK_BLUE_COLOR [UtilityClass colorWithRed:0 green:8 blue:98 alpha:1]
#define PINK_COLOR [UtilityClass colorWithRed:255 green:55 blue:140 alpha:1]
#define LIGHT_BLUE_COLOR [UtilityClass colorWithRed:66 green:151 blue:255 alpha: 1]
@class GameModel;



@interface UtilityClass : NSObject
-(void)sendError:(NSError *)error message:(NSString *)message type:(NSString *)type screenshot:(BOOL)screenshot;
-(int)ageForBirthday:(NSString *)birthday;
+(UIButton*)buttonWithTitle:(NSString*)title boy:(BOOL)boy width:(CGFloat)width;
+(UtilityClass*)instance;
-(NSNumber*)versionNumber;
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block;
-(void)popupBoxWithTitle:(NSString*)title andMessage:(NSString*)message buttons:(NSArray*)buttons block:(SuccessfulBlock)block;
+(NSString*)generateIdWithLength:(NSInteger)length;
-(BOOL)settingIsSet:(NSString *)setting;
-(void)setSetting:(NSString *)setting;
-(NSDate *)dateForKey:(NSString *)setting;
-(void)setDate:(NSDate*)date forKey:(NSString *)setting;
-(void)setDictionary:(NSDictionary *)dictionary forSetting:(NSString *)setting;
-(NSDictionary*)dictionaryForSetting:(NSString *)setting;
-(NSInteger)intForSetting:(NSString *)setting;
-(void)setInt:(NSInteger)integer forSetting:(NSString *)setting;
-(NSString *)stringForSetting:(NSString *)setting;
-(void)setString:(NSString*)string forSetting:(NSString *)setting;
+(UIColor*)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

+(NSString *)readableTimeLeft:(NSInteger)timeLeft;
-(NSString *)displayBirthday:(NSString*)birthdayString;
//+(NSString *)readableChatFromTime:(NSDate *)time;
+(UIButton*)facebookButtonWithAmount:(NSInteger)amount;
@end
