//
//  UtilityClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UtilityClass.h"
#import "AppDelegate.h"
#import "ImageClass.h"
#import "KPParseCommunicator.h"
@interface UtilityClass () <UIAlertViewDelegate>
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic) dispatch_queue_t queue;
@property (copy) SuccessfulBlock block;
@end

@implementation UtilityClass
@synthesize userDefaults = _userDefaults;
static UtilityClass *sharedObject;
-(dispatch_queue_t)queue{
    if(!_queue){
        NSString *string;
        int interval = (int)[[NSDate date] timeIntervalSince1970];
        string = [NSString stringWithFormat:@"update%i",interval];
        _queue = dispatch_queue_create([string UTF8String], NULL);
    }
    return _queue;
}
-(void)sendError:(NSError *)error message:(NSString *)message type:(NSString *)type screenshot:(BOOL)screenshot{
    /*dispatch_async(self.queue, ^{
        NSError *error;
        PFObject *errorObject = [PFObject objectWithClassName:@"Error"];
        if(message) [errorObject setObject:message forKey:@"message"];
        if([error description]) [errorObject setObject:[error description] forKey:@"error"];
        if(type) [errorObject setObject:type forKey:@"type"];
        if(screenshot){
            UIImage *screen = [ImageClass screenshot];
            NSData *screenData = UIImagePNGRepresentation(screen);
            PFFile *pictureFile = [PFFile fileWithData:screenData];
            [pictureFile save:&error];
            if(!error) [errorObject setObject:pictureFile forKey:@"screenshot"];
        }
        [errorObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded) [errorObject saveEventually];
        }];
    });*/
 
}
+(UtilityClass*)instance{
    if(sharedObject == nil) sharedObject = [[super allocWithZone:NULL] init];
    return sharedObject;
}
+(UIButton *)buttonWithTitle:(NSString *)title boy:(BOOL)boy width:(CGFloat)width{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UIColor *textColor;
    if(boy) textColor = DARK_BLUE_COLOR;
    else textColor = PINK_COLOR;
    [button setTitleColor:textColor forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    NSString *realTitle = [NSString stringWithFormat:@"%@",title];//">   "
    [button setTitle:realTitle forState:UIControlStateNormal];
    UIImage *backgroundButtonImage = [[UIImage imageNamed:@"big_button_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    
    [button setBackgroundImage:backgroundButtonImage forState:UIControlStateNormal];
    return button;
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
+(NSString *)readableTimeLeft:(NSInteger)timeLeft{
    NSString *timeString;
   
    NSInteger minutes = timeLeft/60;
    if(minutes < 5) timeString = @"<5m";
    else if(minutes <= 60) timeString = [NSString stringWithFormat:@"%im",minutes];
    else{
        NSInteger hours = timeLeft/3600;
        
        timeString = [NSString stringWithFormat:@"%ih",hours];
    }
    return timeString;
}
/*+(NSString *)readableChatFromTime:(NSDate *)time{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    if([time isToday]){
        [outputFormatter setDateFormat:@"HH:mm"];
    }
    else if([time isYesterday]){
        return @"Yesterday";
    }
    else{
        [outputFormatter setDateFormat:@"dd/MM/yyyy"];
    }
    
    
    return [outputFormatter stringFromDate:time];
}*/
+(UIColor*)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
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

#pragma mark - User Defaults
-(NSUserDefaults *)userDefaults{
    if(!_userDefaults) _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}
-(NSDate *)dateForKey:(NSString *)setting{
    return (NSDate*)[self.userDefaults objectForKey:setting];
}
-(void)setDate:(NSDate*)date forKey:(NSString *)setting{
    [self.userDefaults setObject:date forKey:setting];
}
-(NSInteger)intForSetting:(NSString *)setting{
    return [self.userDefaults integerForKey:setting];
}
-(void)setInt:(NSInteger)integer forSetting:(NSString *)setting{
    [self.userDefaults setInteger:integer forKey:setting];
}
-(NSString *)stringForSetting:(NSString *)setting{
    return [self.userDefaults stringForKey:setting];
}
-(void)setString:(NSString*)string forSetting:(NSString *)setting{
    [self.userDefaults setObject:string forKey:setting];
}
-(BOOL)settingIsSet:(NSString *)setting{
    return [self.userDefaults boolForKey:setting];
}
-(void)setDictionary:(NSDictionary *)dictionary forSetting:(NSString *)setting{
    [self.userDefaults setObject:dictionary forKey:setting];
}
-(NSDictionary*)dictionaryForSetting:(NSString *)setting{
    return [self.userDefaults dictionaryForKey:setting];
}
-(void)setSetting:(NSString *)setting{
    [self.userDefaults setBool:YES forKey:setting];
}
-(void)unsetSetting:(NSString *)setting{
    [self.userDefaults setBool:NO forKey:setting];
}
-(NSString *)displayBirthday:(NSString*)birthdayString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dateFormat dateFromString:birthdayString];
    
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    [outputFormat setDateFormat:@"dd/MM/yyyy"];
    return [outputFormat stringFromDate:date];
    
}
+(UIButton*)facebookButtonWithAmount:(NSInteger)amount{
    CGFloat leftInset = 45;
    CGFloat rightInset = 8;
    NSString *titleText;
    if(amount > 0) titleText = [NSString stringWithFormat:@"Share     +%ip",amount];
    else titleText = @"Share";
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 42)];
    [facebookButton setBackgroundImage:[[UIImage imageNamed:@"facebook_button_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 40, 5, 5)] forState:UIControlStateNormal];
    [facebookButton setTitle:titleText forState:UIControlStateNormal];
    facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    [facebookButton sizeToFit];
    facebookButton.frame = CGRectMake(0, 0, facebookButton.frame.size.width+leftInset+rightInset, 42);
    return facebookButton;
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
-(void)dealloc{
    dispatch_release(self.queue);
}
@end