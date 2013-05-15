//
//  UtilityClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UtilityClass.h"
#import "AppDelegate.h"
#import "KPParseCommunicator.h"
@interface UtilityClass () <UIAlertViewDelegate>
@property (copy) SuccessfulBlock block;
@end

@implementation UtilityClass
@synthesize userDefaults = _userDefaults;
static UtilityClass *sharedObject;
+(UtilityClass*)instance{
    if(sharedObject == nil) sharedObject = [[super allocWithZone:NULL] init];
    return sharedObject;
}
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+(UIImage *)navbarImage{
    CGFloat navbarWidth = 1;
    CGFloat navbarHeight = 44;
    CGSize navbarSize = CGSizeMake(navbarWidth, navbarHeight);
    UIGraphicsBeginImageContext(navbarSize);
    UIImage *topColorImage = [UtilityClass imageWithColor:NAVBAR_BACKROUND];
    UIImage *bottomColorImage = [UtilityClass imageWithColor:SEGMENT_SELECTED];
    [topColorImage drawInRect:CGRectMake(0, 0, navbarWidth, navbarHeight-COLOR_SEPERATOR_HEIGHT)];
    [bottomColorImage drawInRect:CGRectMake(0, navbarHeight-COLOR_SEPERATOR_HEIGHT, navbarWidth, COLOR_SEPERATOR_HEIGHT)];
    return UIGraphicsGetImageFromCurrentImageContext();
}
-(NSNumber *)versionNumber{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    return myNumber;
}
-(void)popupBoxWithTitle:(NSString*)title andMessage:(NSString*)message buttons:(NSArray*)buttons block:(SuccessfulBlock)block{
    if(buttons.count < 1) return;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:[buttons objectAtIndex:0] otherButtonTitles:[buttons objectAtIndex:1], nil];
    self.block = block;
    [alertView show];
}
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    self.block = block;
    [alertView show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            if(self.block) self.block(NO,nil);
        }
            break;
        case 1:
        {
            if(self.block) self.block(YES,nil);
        }
            break;
    }
    self.block = nil;
}
+(NSString*)generateIdWithLength:(NSInteger)length{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}
static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, NSInteger degrees)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextRotateCTM (context, radians(degrees));
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}
#pragma mark - User Defaults
-(NSUserDefaults *)userDefaults{
    if(!_userDefaults) _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}
-(int)ageForBirthday:(NSString *)birthday{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dateFormat dateFromString:birthday];
    int time = [[NSDate date] timeIntervalSinceDate:date];
    int allDays = (((time/60)/60)/24);
    int days = allDays%365;
    int years = (allDays-days)/365;
    return years;
}
@end