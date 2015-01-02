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

#define kSettingsDictionaryKey @"SettingsDictionary"

#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "NotificationHandler.h"
#import <Parse/PFQuery.h>
#import <Parse/PFFile.h>
@interface SettingsHandler ()
@property (nonatomic,copy) ImageBlock block;
@property BOOL isFetchingSettings;
@property BOOL isFetchingImage;
@property NSMutableDictionary *settings;
@end
@implementation SettingsHandler
static SettingsHandler *sharedObject;
+(SettingsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[self allocWithZone:NULL] init];
        [sharedObject initialize];
    }
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
            break;
        case SettingDailyReminders:
            index = @"SettingDailyReminders";
            break;
        case SettingWeeklyReminders:
            index = @"SettingWeeklyReminders";
            break;
        case SettingLocation:
            index = @"SettingLocation";
            break;
        case SettingTimeZone:
            index = @"SettingTimeZone";
            break;
        case SettingEvernoteSync:
            index = @"SettingEvernoteSync";
            break;
        case IntegrationEvernoteEnableSync:
            index = @"IntegrationEvernoteEnableSync";
            break;
        case IntegrationEvernoteSwipesTag:
            index = @"IntegrationEvernoteSwipesTag";
            break;
        case IntegrationEvernoteFindInPersonalLinkedNotebooks:
            index = @"IntegrationEvernoteFindInPersonalLinkedNotebooks";
            break;
        case IntegrationEvernoteFindInBusinessNotebooks:
            index = @"IntegrationEvernoteFindInBusinessNotebooks";
            break;

    }
    return index;
}


-(void)checkTimeZoneChange{
    //NSLog(@"checking timezone");
    NSInteger deviceTimeZone = [NSTimeZone localTimeZone].secondsFromGMT;
    NSInteger settingTimeZone = [[self valueForSetting:SettingTimeZone] integerValue];
    //NSLog(@"%lu - %lu",(long)deviceTimeZone,(long)settingTimeZone);
    if(deviceTimeZone != settingTimeZone){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updated time zone" object:self userInfo:@{@"from":@(settingTimeZone),@"to":@(deviceTimeZone)}];
    }
}

-(void)refreshGlobalSettingsForce:(BOOL)force{
    [self checkTimeZoneChange];
    
    if(self.isFetchingSettings)
        return;
}

-(NSNumber*)repairValue:(NSDate*)date forSetting:(KPSettings)setting{
    //NSLog(@"defaultval for:%i",setting);
    switch (setting) {
        case SettingLaterToday:
        case SettingWeekendStartTime:
        case SettingEveningStartTime:
        case SettingWeekStartTime:
            return @( date.hour * D_HOUR + date.minute * D_MINUTE );
        case SettingWeekStart:
        case SettingWeekendStart:
            return @( date.weekday );
        default:
            return nil;
    }
}

-(id)defaultValueForSettings:(KPSettings)setting{
    //NSLog(@"defaultval for:%i",setting);
    
    switch (setting) {
        case SettingLaterToday:
            return @( 3 * D_HOUR );
        case SettingWeekStart:
            return @( 2 );
        case SettingWeekStartTime:
            return @(kDefWeekStartTime * D_HOUR);
        case SettingEveningStartTime:
            return @(kDefEveningStartTime * D_HOUR);
        case SettingWeekendStart:
            return @( 7 );
        case SettingWeekendStartTime:
            return @(kDefWeekendStartTime * D_HOUR);
        case SettingTimeZone:
            return @([NSTimeZone localTimeZone].secondsFromGMT);
        case SettingNotifications:
            return @YES;
        case SettingDailyReminders:
            return @YES;
        case SettingWeeklyReminders:
            return @YES;
        case SettingLocation:
            return @NO;
        case SettingEvernoteSync:
            return @YES;
        case IntegrationEvernoteEnableSync:
            return @NO;
        case IntegrationEvernoteSwipesTag:
            return @NO;
        case IntegrationEvernoteFindInPersonalLinkedNotebooks:
            return @YES;
        case IntegrationEvernoteFindInBusinessNotebooks:
            return @YES;
    }
}

-(id)valueForSetting:(KPSettings)setting{
    
    NSString *index = [self indexForSettings:setting];
    if(!index) return nil;
    id value = [USER_DEFAULTS objectForKey:index];
    if([value isKindOfClass:[NSDate class]]){
        value = [self repairValue:value forSetting:setting];
        if(value)
            [self setValue:value forSetting:setting];
    }
    if(!value){
        value = [self defaultValueForSettings:setting];
        [self setValue:value forSetting:setting];
    }
    return value;
}

-(void)setValue:(id)value forSetting:(KPSettings)setting{
    NSString *index = [self indexForSettings:setting];
    if(!index) return;
    [USER_DEFAULTS setObject:value forKey:index];
    [USER_DEFAULTS synchronize];
    if(setting == SettingNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
}

-(BOOL)settingForKey:(NSString *)key{
    BOOL setting = [[self.settings objectForKey:key] boolValue];
    return setting;
}

-(void)setSetting:(BOOL)setting forKey:(NSString *)key{
    [self.settings setObject:@(setting) forKey:key];
    [USER_DEFAULTS setObject:self.settings forKey:kSettingsDictionaryKey];
    [USER_DEFAULTS synchronize];
}

-(void)initialize{
    self.settings = [USER_DEFAULTS objectForKey:kSettingsDictionaryKey];
    if(!self.settings)
        self.settings = [NSMutableDictionary dictionary];
    else if( ![self.settings isMemberOfClass:[NSMutableDictionary class]]){
        
        if([self.settings isKindOfClass:[NSDictionary class]])
            self.settings = [self.settings mutableCopy];
        else{
            self.settings = [NSMutableDictionary dictionary];
        }
    }
}

-(void)printSettings{
    NSLog(@"%@",self.settings);
}

@end
