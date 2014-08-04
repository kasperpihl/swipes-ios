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
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
#define trgb(num) (num/255.0)
@interface UtilityClass () <UIAlertViewDelegate>
@property (copy) SuccessfulBlock block;
@property (copy) NumberBlock numberBlock;
@end

@implementation UtilityClass
@synthesize userDefaults = _userDefaults;
static UtilityClass *sharedObject;
+(UtilityClass*)instance{
    if(sharedObject == nil) sharedObject = [[super allocWithZone:NULL] init];
    return sharedObject;
}
+(void)sendError:(NSError *)error type:(NSString *)type{
    [self.class sendError:error type:type attachment:nil];
}
+(void)sendError:(NSError *)error type:(NSString *)type attachment:(NSDictionary*)attachment{
    DLog(@"Sending error: '%@' of type: '%@'", error, type);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFObject *errorObject = [PFObject objectWithClassName:@"Error"];
        if([error description]) [errorObject setObject:[error description] forKey:@"error"];
        if(error.userInfo)
            [errorObject setObject:error.userInfo forKey:@"userInfo"];
        if(attachment)
            [errorObject setObject:attachment forKey:@"attachment"];
        if([error code]) [errorObject setObject:@([error code]) forKey:@"code"];
        if(kCurrent) [errorObject setObject:kCurrent forKey:@"user"];
        if(type) [errorObject setObject:type forKey:@"type"];
        [errorObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded) [errorObject saveEventually];
        }];
        return;
    });
    
}
+(void)sendException:(NSException*)exception type:(NSString*)type{
    DLog(@"Sending exception: '%@' of type: '%@'", exception, type);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFObject *errorObject = [PFObject objectWithClassName:@"Error"];
        if([exception description]) [errorObject setObject:[exception description] forKey:@"error"];
        [errorObject setObject:@(1337) forKey:@"code"];
        if([exception userInfo])
            [errorObject addObject:exception.userInfo forKey:@"userInfo"];
        if(kCurrent) [errorObject setObject:kCurrent forKey:@"user"];
        if(type) [errorObject setObject:type forKey:@"type"];
        [errorObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded) [errorObject saveEventually];
        }];
        return;
    });
}
+(NSString *)readableTime:(NSDate*)time showTime:(BOOL)showTime{
    if(!time) return nil;
    NSString *timeString = [UtilityClass timeStringForDate:time];
    
    NSDate *beginningOfDate = [time dateAtStartOfDay];
    NSInteger numberOfDaysAfterTodays = [beginningOfDate distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]];
    NSString *dateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    BOOL shouldFormat = NO;
    if(numberOfDaysAfterTodays == 0){
        dateString = @"Today";
        if([time isLaterThanDate:[NSDate date]]) dateString = @"Today";
    }
    else if(numberOfDaysAfterTodays == -1) dateString = @"Tomorrow";
    else if(numberOfDaysAfterTodays == 1) dateString = @"Yesterday";
    else if(numberOfDaysAfterTodays < 7 && numberOfDaysAfterTodays > -7){
        [dateFormatter setDateFormat:@"EEEE"];
        shouldFormat = YES;
    }
    else{
        if([time isSameYearAsDate:[NSDate date]]) dateFormatter.dateFormat = @"LLL d";
        else dateFormatter.dateFormat = @"LLL d  '´'yy";
        shouldFormat = YES;
    }
    if(shouldFormat){
        dateString = [dateFormatter stringFromDate:time];
    }
    dateString = [dateString capitalizedString];
    if(!showTime) return dateString;
    return [NSString stringWithFormat:@"%@, %@",dateString,timeString];
    
}
+ (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+ (UIImage *)imageWithName:(NSString *)imageName scaledToSize:(CGSize)newSize {
    return [self imageWithImage:[UIImage imageNamed:imageName] scaledToSize:newSize];
}
-(NSNumber *)versionNumber{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    return myNumber;
}
-(void)confirmBoxWithTitle:(NSString*)title andMessage:(NSString*)message block:(SuccessfulBlock)block{
    [self confirmBoxWithTitle:title andMessage:message cancel:@"No" confirm:@"Yes" block:block];
}

-(void)confirmBoxWithTitle:(NSString *)title andMessage:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm block:(SuccessfulBlock)block{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
    self.block = block;
    [alertView show];
}
-(void)popupWithTitle:(NSString *)title andMessage:(NSString *)message buttonTitles:(NSArray *)buttonTitles block:(NumberBlock)block{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    for( NSString *buttonTitle in buttonTitles ){
        [alertView addButtonWithTitle:buttonTitle];
    }
    self.numberBlock = block;
    [alertView show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( self.numberBlock ){
        self.numberBlock( buttonIndex, nil );
        self.numberBlock = nil;
        return;
    }
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
+(UIImage *)flippedImage:(UIImage*)flippingImage horizontal:(BOOL)horizontal{
    UIImageOrientation orientation = UIImageOrientationUpMirrored;
    return [UIImage imageWithCGImage:flippingImage.CGImage
                               scale:[UIScreen mainScreen].scale orientation:orientation];
}
+(UIImage *)image:(UIImage *)image withColor:(UIColor *)color multiply:(BOOL)multiply{
    UIImage *img = image;
    if(!image) return nil;
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    if(multiply) CGContextSetBlendMode(context, kCGBlendModeMultiply);
    else CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}
+(NSString*)timeStringForDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [[dateFormatter stringFromDate:date] lowercaseString];

}
+(NSString *)dayOfMonthForDate:(NSDate *)date{
    
    NSDateFormatter *prefixDateFormatter = [[NSDateFormatter alloc] init];
    [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [prefixDateFormatter setDateFormat:@"d."];//June 13th, 2013
    NSString * prefixDateString = [prefixDateFormatter stringFromDate:date];
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:date] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    
    prefixDateString = [prefixDateString stringByReplacingOccurrencesOfString:@"." withString:suffix];
    NSString *dateString =prefixDateString;
    //  NSLog(@"%@", dateString);
    return dateString;
}
+(NSString*)dayStringForDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    if([date isSameYearAsDate:[NSDate date]]) dateFormatter.dateFormat = @"d LLL";
    else dateFormatter.dateFormat = @"d LLL '´'yy";
    NSString *endingString = [dateFormatter stringFromDate:date];
    
    
    NSDate *beginningOfDate = [date dateAtStartOfDay];
    NSInteger numberOfDaysAfterTodays = [beginningOfDate distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]];
    NSString *dayString;
    if(numberOfDaysAfterTodays == 0){
        dayString = @"Today";
        if([date isLaterThanDate:[NSDate date]]) dayString = @"Today";
    }
    else if(numberOfDaysAfterTodays == -1) dayString = @"Tomorrow";
    else if(numberOfDaysAfterTodays == 1) dayString = @"Yesterday";
    else{
        dateFormatter.dateFormat = @"EEE";
    }
    if(!dayString) dayString = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@ - %@",dayString,endingString];
}
+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color{
    UIImage *img = [UIImage imageNamed:name];
    return [UtilityClass image:img withColor:color multiply:NO];
}
+ (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
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