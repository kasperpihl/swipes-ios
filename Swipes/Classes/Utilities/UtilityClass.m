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
    return nil;
    /*return [UtilityClass imageWithColor:];
    CGFloat navbarWidth = 1;
    CGFloat navbarHeight = 44;
    CGFloat sepHeight = .5;
    CGSize navbarSize = CGSizeMake(navbarWidth, navbarHeight);
    UIGraphicsBeginImageContext(navbarSize);
    UIImage *topColorImage = [UtilityClass imageWithColor:NAVBAR_BACKROUND];
    UIImage *bottomColorImage = [UtilityClass imageWithColor:SEGMENT_SELECTED];
    [topColorImage drawInRect:CGRectMake(0, 0, navbarWidth, navbarHeight-sepHeight)];
    [bottomColorImage drawInRect:CGRectMake(0, navbarHeight-sepHeight, navbarWidth, sepHeight)];
    return UIGraphicsGetImageFromCurrentImageContext();*/
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
+(UIImage *)flippedImage:(UIImage*)flippingImage horizontal:(BOOL)horizontal{
    UIImageOrientation orientation = UIImageOrientationUpMirrored;
    return [UIImage imageWithCGImage:flippingImage.CGImage
                               scale:[UIScreen mainScreen].scale orientation:orientation];
}
+(UIImage *)image:(UIImage *)image withColor:(UIColor *)color{
    UIImage *img = image;
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
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
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
+(UIColor *)inverseColor:(UIColor*)color {
    
    CGColorRef oldCGColor = color.CGColor;
    
    int numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    // can not invert - the only component is the alpha
    // e.g. self == [UIColor groupTableViewBackgroundColor]
    if (numberOfComponents == 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    int i = numberOfComponents - 1;
    newComponentColors[i] = oldComponentColors[i]; // alpha
    while (--i >= 0) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    return newColor;
}
+(NSString*)timeStringForDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [[dateFormatter stringFromDate:date] lowercaseString];

}
+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color{
    UIImage *img = [UIImage imageNamed:name];
    return [UtilityClass image:img withColor:color];
}
+ (UIColor *)lighterColor:(UIColor*)c
{
    float h, s, b, a;
    if ([c getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)darkerColor:(UIColor*)c
{
    float h, s, b, a;
    if ([c getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
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