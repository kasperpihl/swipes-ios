//
//  UtilityClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "KPParseCommunicator.h"
#import "NSDate-Utilities.h"
#import "UtilityClass.h"

#define trgb(num) (num/255.0)

@interface UtilityClass () <UIAlertViewDelegate>
@property (copy) SuccessfulBlock block;
@property (copy) NumberBlock numberBlock;
@property (copy) StringBlock stringBlock;

@end

@implementation UtilityClass

+ (instancetype)instance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)sendError:(NSError *)error type:(NSString *)type{
    [self.class sendError:error type:type attachment:nil];
}

+ (PFObject*)emptyErrorObjectForDevice{
    PFObject *errorObject = [PFObject objectWithClassName:@"Error"];
    [errorObject setObject:@"iOS" forKey:@"Platform"];
    [errorObject setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"AppVersion"];
    NSString* data = [UIDevice currentDevice].systemVersion;
    if (data)
        [errorObject setObject:data forKey:@"OSVersion"];
    data = [UIDevice currentDevice].name;
    if (data)
        [errorObject setObject:data forKey:@"Device"];
    return errorObject;
}

+ (void)sendError:(NSError *)error type:(NSString *)type attachment:(NSDictionary*)attachment{
    DLog(@"Sending error: '%@' of type: '%@'", error, type);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFObject *errorObject = [self.class emptyErrorObjectForDevice];
        if ([error description])
            [errorObject setObject:[error description] forKey:@"error"];
        if (error.userInfo){
            NSError *parseError;
            @try {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:error.userInfo
                                                                   options:0 // Pass 0 if you don't care about the readability of the generated string
                                                                     error:&parseError];
                if(!parseError && jsonData){
                    [errorObject setObject:error.userInfo forKey:@"userInfo"];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Error trying to send '%@' to parse", parseError);
            }
           
        }
        if (attachment)
            [errorObject setObject:attachment forKey:@"attachment"];
        if ([error code])
            [errorObject setObject:@([error code]) forKey:@"code"];
        if (kCurrent)
            [errorObject setObject:kCurrent forKey:@"user"];
        if (type)
            [errorObject setObject:type forKey:@"type"];
        [errorObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded)
                [errorObject saveEventually];
        }];
        return;
    });
    
}
+(void)sendException:(NSException*)exception type:(NSString*)type{
    DLog(@"Sending exception: '%@' of type: '%@'", exception, type);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFObject *errorObject = [self.class emptyErrorObjectForDevice];
        if ([exception description])
            [errorObject setObject:[exception description] forKey:@"error"];
        [errorObject setObject:@(1337) forKey:@"code"];
        if ([exception userInfo])
            [errorObject addObject:exception.userInfo forKey:@"userInfo"];
        if (kCurrent)
            [errorObject setObject:kCurrent forKey:@"user"];
        if (type)
            [errorObject setObject:type forKey:@"type"];
        [errorObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded)
                [errorObject saveEventually];
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

-(void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
#ifndef NOT_APPLICATION
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
#else
#warning Test support on iOS 8
    if (self.rootViewController) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        [self.rootViewController presentViewController:alert animated:NO completion:nil];
    }
#endif
}

-(void)inputAlertWithTitle:(NSString*)title message:(NSString*)message placeholder:(NSString*)placeholder cancel:(NSString *)cancel confirm:(NSString *)confirm block:(StringBlock)block{
#ifndef NOT_APPLICATION
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:self
                              cancelButtonTitle:cancel
                              otherButtonTitles:confirm, nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    self.stringBlock = block;
    [alertView show];
#else
    if (self.rootViewController) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = placeholder;
        }];
        [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            UITextField *login = alert.textFields.firstObject;
            if(login.isFirstResponder)
                [login resignFirstResponder];
            if (block)
                block(nil, nil);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *login = alert.textFields.firstObject;
            if(login.isFirstResponder)
                [login resignFirstResponder];
            if (block)
                block(login.text, nil);
        }]];
        [self.rootViewController presentViewController:alert animated:NO completion:^{
            UITextField *login = alert.textFields.firstObject;
            [login becomeFirstResponder];
        }];
    }
#endif
}

-(void)confirmBoxWithTitle:(NSString *)title andMessage:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm block:(SuccessfulBlock)block{
#ifndef NOT_APPLICATION
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
    self.block = block;
    [alertView show];
#else
#warning Test support on iOS 8
    if (self.rootViewController) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
           if (block)
               block(NO, nil);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (block)
                block(YES, nil);
        }]];
        [self.rootViewController presentViewController:alert animated:NO completion:nil];
    }
#endif
}

-(void)popupWithTitle:(NSString *)title andMessage:(NSString *)message buttonTitles:(NSArray *)buttonTitles block:(NumberBlock)block{
#ifndef NOT_APPLICATION
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    for( NSString *buttonTitle in buttonTitles ){
        [alertView addButtonWithTitle:buttonTitle];
    }
    self.numberBlock = block;
    [alertView show];
#else
#warning Test support on iOS 8
    if (self.rootViewController) {
        void (^buttonBlock)(UIAlertAction *action) = ^(UIAlertAction *action) {
            NSUInteger counter = 0;
            if (block) {
                for (NSString* title in buttonTitles) {
                    if ([title isEqualToString:action.title]) {
                        block(counter, nil);
                    }
                    counter++;
                }
            }
        };
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        for (NSString* title in buttonTitles) {
            [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:buttonBlock]];
        }
        [self.rootViewController presentViewController:alert animated:NO completion:nil];
    }
#endif
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(self.stringBlock){
        if(buttonIndex == 1){
            UITextField *input = [alertView textFieldAtIndex:0];
            self.stringBlock(input.text, nil);
        }
        else
            self.stringBlock(nil, nil);
        return;
    }
    
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
    if(!_userDefaults) _userDefaults = USER_DEFAULTS;
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