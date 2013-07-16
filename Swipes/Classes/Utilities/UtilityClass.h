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
+(UIImage*)navbarImage;
+(UtilityClass*)instance;
-(NSNumber*)versionNumber;
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block;
-(void)popupBoxWithTitle:(NSString*)title andMessage:(NSString*)message buttons:(NSArray*)buttons block:(SuccessfulBlock)block;
+ (UIColor *)darkerColor:(UIColor*)c;
+(NSString*)generateIdWithLength:(NSInteger)length;
UIImage* rotate(UIImage* src, NSInteger degrees);
+ (BOOL) validateEmail: (NSString *) candidate;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
+ (UIImage *)image:(UIImage *)image withColor:(UIColor *)color;
+(UIImage *)flippedImage:(UIImage*)flippingImage horizontal:(BOOL)horizontal;
+(UIColor *)inverseColor:(UIColor*)color;
@end
