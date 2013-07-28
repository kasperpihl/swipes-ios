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
-(int)ageForBirthday:(NSString *)birthday;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
+ (UIImage *)imageWithColor:(UIColor *)color;
+(UtilityClass*)instance;
-(NSNumber*)versionNumber;
+ (UIImage *)radialGradientImage:(CGSize)size start:(UIColor*)start end:(UIColor*)end centre:(CGPoint)centre radius:(float)radius;
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block;
-(void)popupBoxWithTitle:(NSString*)title andMessage:(NSString*)message buttons:(NSArray*)buttons block:(SuccessfulBlock)block;
+ (UIColor *)darkerColor:(UIColor*)c;
+ (UIColor *)lighterColor:(UIColor*)c;
+(NSString*)generateIdWithLength:(NSInteger)length;
UIImage* rotate(UIImage* src, NSInteger degrees);
+ (BOOL) validateEmail: (NSString *) candidate;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
+ (UIImage *)image:(UIImage *)image withColor:(UIColor *)color;
+ (UIImage *)imageWithName:(NSString *)imageName scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+(UIImage *)flippedImage:(UIImage*)flippingImage horizontal:(BOOL)horizontal;
+(UIColor *)inverseColor:(UIColor*)color;
+(NSString*)timeStringForDate:(NSDate*)date;

@end
