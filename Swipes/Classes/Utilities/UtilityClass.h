//
//  UtilityClass.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import <Foundation/Foundation.h>

#define UTILITY [UtilityClass instance]

@interface UtilityClass : NSObject

+(instancetype)instance;
+(NSString*)generateIdWithLength:(NSInteger)length;
+(void)sendError:(NSError *)error type:(NSString *)type;
+(void)sendError:(NSError *)error type:(NSString *)type attachment:(NSDictionary*)attachment;
+(void)sendException:(NSException*)exception type:(NSString*)type;
+ (BOOL) validateEmail: (NSString *) candidate;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
+ (UIImage *)image:(UIImage *)image withColor:(UIColor *)color multiply:(BOOL)multiply;
+ (UIImage *)imageWithName:(NSString *)imageName scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(NSString*)dayStringForDate:(NSDate*)date;
+(NSString*)timeStringForDate:(NSDate*)date;
+(NSString*)dayOfMonthForDate:(NSDate*)date;
+(NSString *)readableTime:(NSDate*)time showTime:(BOOL)showTime;

@property (nonatomic,strong) NSUserDefaults *userDefaults;

//+ (UIImage *)imageWithColor:(UIColor *)color;
-(int)ageForBirthday:(NSString *)birthday;
-(NSNumber*)versionNumber;
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block;
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message cancel:(NSString*)cancel confirm:(NSString*)confirm block:(SuccessfulBlock)block;
-(void)popupWithTitle:(NSString*)title andMessage:(NSString*)message buttonTitles:(NSArray*)buttonTitles block:(NumberBlock)block;

@end
