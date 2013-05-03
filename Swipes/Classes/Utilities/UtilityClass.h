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
+(UtilityClass*)instance;
-(NSNumber*)versionNumber;
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block;
-(void)popupBoxWithTitle:(NSString*)title andMessage:(NSString*)message buttons:(NSArray*)buttons block:(SuccessfulBlock)block;
+(NSString*)generateIdWithLength:(NSInteger)length;
+(UIColor*)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
UIImage* rotate(UIImage* src, NSInteger degrees);
@end
