//
//  SettingsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefWeekStartTime 9
#define kDefWeekendStartTime 10
#define kDefEveningStartTime 19

#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "NotificationHandler.h"
@implementation SettingsHandler
static SettingsHandler *sharedObject;
+(SettingsHandler *)sharedInstance{
    if(!sharedObject) sharedObject = [[self allocWithZone:NULL] init];
    return sharedObject;
}
-(NSString*)indexForSettings:(KPSettings)setting{
    NSString *index;
    switch (setting) {
        case SettingLaterToday:
            index = @"SettingLaterToday";
            break;
        case SettingEveningStartTime:
            index = @"SettingEveningStartTime";
            break;
        case SettingWeekStart:
            index = @"SettingWeekStart";
            break;
        case SettingWeekStartTime:
            index = @"SettingWeekStartTime";
            break;
        case SettingWeekendStart:
            index = @"SettingWeekendStart";
            break;
        case SettingWeekendStartTime:
            index = @"SettingWeekendStartTime";
            break;
        case SettingNotifications:
            index = @"SettingNotifications";
    }
    return index;
}
-(id)defaultValueForSettings:(KPSettings)setting{
    //NSLog(@"defaultval for:%i",setting);
    switch (setting) {
        case SettingLaterToday:
            return [[NSDate date] dateAtHours:3 minutes:0];
        case SettingWeekStart:
            return [NSDate dateThisOrNextWeekWithDay:2 hours:8 minutes:0];
        case SettingWeekStartTime:
            return [[NSDate date] dateAtHours:kDefWeekStartTime minutes:0];
        case SettingEveningStartTime:
            return [[NSDate date] dateAtHours:kDefEveningStartTime minutes:0];
        case SettingWeekendStart:
            return [NSDate dateThisOrNextWeekWithDay:7 hours:8 minutes:0];
        case SettingWeekendStartTime:
            return [[NSDate date] dateAtHours:kDefWeekendStartTime minutes:0];
        case SettingNotifications:
            return @YES;
    }
}
-(id)valueForSetting:(KPSettings)setting{
    NSString *index = [self indexForSettings:setting];
    if(!index) return nil;
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:index];
    if(!value) value = [self defaultValueForSettings:setting];
    return value;
}
-(void)setValue:(id)value forSetting:(KPSettings)setting{
    NSString *index = [self indexForSettings:setting];
    if(!index) return;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:index];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(setting == SettingNotifications) [NOTIHANDLER updateLocalNotifications];
}
@end
