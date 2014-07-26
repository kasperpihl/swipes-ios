//
//  Global.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "Global.h"
#define iconCompare(target,result) if([iconString isEqualToString:target]) return result
@implementation Global
static Global *sharedObject;
+(Global *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[Global allocWithZone:NULL] init];
    }
    return sharedObject;
}
+(NSString *)iconStringForString:(NSString *)iconString{
    if(OSVER >= 7)
        return iconString;
    
    /* Nav bar */
    iconCompare(@"settings",                    @"\ue601");
    iconCompare(@"done",                        @"\ue602");
    iconCompare(@"today",                       @"\ue603");
    iconCompare(@"later",                       @"\ue604");
    iconCompare(@"settingsFull",                @"\ue605");
    iconCompare(@"doneFull",                    @"\ue606");
    iconCompare(@"todayFull",                   @"\ue607");
    iconCompare(@"laterFull",                   @"\ue608");
    
    /* Edit mode */
    iconCompare(@"editNotes",                   @"\ue609");
    iconCompare(@"editRepeat",                  @"\ue60a");
    iconCompare(@"editTags",                    @"\ue60b");
    iconCompare(@"editSchedule",                @"\ue60c");
    iconCompare(@"editLocation",                @"\ue60d");
    iconCompare(@"editEvernote",                @"\ue65c");
    iconCompare(@"editActionRoundedArrow",      @"\ue65d");
    iconCompare(@"editActionRoundedPlus",       @"\ue65e");
    iconCompare(@"editSyncIcon",                @"\ue615");
    
    /* Social icons */
    iconCompare(@"twitter",                     @"\ue60e");
    iconCompare(@"facebook",                    @"\ue60f");
    iconCompare(@"twitterFull",                 @"\ue610");
    iconCompare(@"facebookFull",                @"\ue611");
    
    /* Menu icons */
    iconCompare(@"settingsPlus",                @"\ue613");
    iconCompare(@"settingsSync",                @"\ue632");
    iconCompare(@"settingsLogout",              @"\ue617");
    iconCompare(@"settingsSchedule",            @"\ue653");
    iconCompare(@"settingsTheme",               @"\ue618");
    iconCompare(@"settingsAccount",             @"\ue644");
    iconCompare(@"settingsPolicy",              @"\ue616");
    iconCompare(@"settingsFeedback",            @"\ue619");
    iconCompare(@"settingsWalkthrough",         @"\ue619");
    iconCompare(@"settingsNotification",        @"\ue61b");
    iconCompare(@"settingsIntegrations",        @"\ue659");
    
    /* Menu icons full */
    iconCompare(@"settingsLogoutFull",          @"\ue620");
    iconCompare(@"settingsThemeFull",           @"\ue61d");
    iconCompare(@"settingsAccountFull",         @"\ue648");
    iconCompare(@"settingsPlusFull",            @"\ue61e");
    iconCompare(@"settingsPolicyFull",          @"\ue61f");
    iconCompare(@"settingsFeedbackFull",        @"\ue621");
    iconCompare(@"settingsWalkthroughFull",     @"\ue622");
    iconCompare(@"settingsNotificationFull",    @"\ue624");
    
    
    iconCompare(@"checkmark",                   @"\ue625");
    iconCompare(@"checkmarkThick",              @"\ue64f");
    iconCompare(@"plus",                        @"\ue626");
    iconCompare(@"back",                        @"\ue63f");
    iconCompare(@"rightArrow",                  @"\ue628");
    iconCompare(@"roundClose",                  @"\ue629");
    iconCompare(@"roundAdd",                    @"\ue62a");
    iconCompare(@"roundBack",                   @"\ue62b");
    iconCompare(@"roundConfirm",                @"\ue62c");
    iconCompare(@"rightArrowFull",              @"\ue62d");
    iconCompare(@"roundCloseFull",              @"\ue62e");
    iconCompare(@"roundAddFull",                @"\ue62f");
    iconCompare(@"roundBackFull",               @"\ue630");
    iconCompare(@"roundConfirmFull",            @"\ue631");
    iconCompare(@"actionShare",                 @"\ue633");
    iconCompare(@"actionTag",                   @"\ue634");
    iconCompare(@"actionDelete",                @"\ue635");
    iconCompare(@"actionEdit",                  @"\ue636");
    iconCompare(@"actionAttach",                @"\ue637");
    iconCompare(@"actionShareFull",             @"\ue639");
    iconCompare(@"actionTagFull",               @"\ue63a");
    iconCompare(@"actionDeleteFull",            @"\ue63b");
    iconCompare(@"actionEditFull",              @"\ue63c");
    iconCompare(@"actionSearch",                @"\ue654");
    
    /* Schedule */
    iconCompare(@"scheduleCalendar",            @"\ue63d");
    iconCompare(@"scheduleLocation",            @"\ue63e");
    iconCompare(@"scheduleCloud",               @"\ue612");
    iconCompare(@"scheduleCircle",              @"\ue640");
    iconCompare(@"scheduleGlass",               @"\ue641");
    iconCompare(@"scheduleLogbook",             @"\ue652");
    iconCompare(@"scheduleSun",                 @"\ue643");
    iconCompare(@"scheduleMoon",                @"\ue638");
    iconCompare(@"scheduleCoffee",              @"\ue645");
    
    /* Schedule full*/
    iconCompare(@"scheduleCalendarFull",        @"\ue646");
    iconCompare(@"scheduleLocationFull",        @"\ue647");
    iconCompare(@"scheduleCloudFull",           @"\ue614");
    iconCompare(@"scheduleCircleFull",          @"\ue649");
    iconCompare(@"scheduleGlassFull",           @"\ue64a");
    iconCompare(@"scheduleLogbookFull",         @"\ue64b");
    iconCompare(@"scheduleSunFull",             @"\ue64c");
    iconCompare(@"scheduleMoonFull",            @"\ue61c");
    iconCompare(@"scheduleCoffeeFull",          @"\ue64e");
    
    /* Integrations */
    iconCompare(@"integrationEvernote",         @"\ue642");
    
    /* Integrations full */
    iconCompare(@"integrationEvernoteFull",     @"\ue64d");
    
    iconCompare(@"logo",                        @"\ue600");
    iconCompare(@"signature",                   @"\ue623");
    iconCompare(@"trompet",                     @"\ue627");
    iconCompare(@"pickerWheel",                 @"\ue659");
    return iconString;
}
+(NSDateFormatter *)isoDateFormatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    return dateFormatter;
}
+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}
+(BOOL)is24Hour{
    static BOOL _is24hour = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
        _is24hour = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    });
    return _is24hour;
}

+ (CGFloat)statusBarHeight
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    else {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    }
}
+(UILabel *)iconLabelWithString:(NSString *)iconString height:(CGFloat)height{
    UILabel *label = [[UILabel alloc] init];
    label.font = iconFont(height);
    label.backgroundColor = CLEAR;
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:iconString(iconString)];
    [label sizeToFit];
    return label;
}
+(BOOL)supportsOrientation:(UIDeviceOrientation)orientation{
    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary]     objectForKey:@"UISupportedInterfaceOrientations"];
    NSString *orientationString;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationString = @"UIInterfaceOrientationPortrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationString = @"UIInterfaceOrientationPortraitUpsideDown";
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationString = @"UIInterfaceOrientationLandscapeLeft";
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationString = @"UIInterfaceOrientationLandscapeRight";
            break;
        default:
            orientationString = @"Invalid Interface Orientation";
    }
    return [supportedOrientations containsObject:orientationString];
}
@end
