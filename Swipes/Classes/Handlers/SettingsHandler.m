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

#import "Global.h"
#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "NotificationHandler.h"

#ifndef APPLE_WATCH

#import "UserHandler.h"
#import <Parse/PFQuery.h>
#import <Parse/PFFile.h>

#endif

@interface SettingsHandler ()

@property (nonatomic, assign) BOOL isFetchingSettings;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) NSTimer *settingTimer;

@end

@implementation SettingsHandler

static SettingsHandler *sharedObject;

+(SettingsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[self alloc] init];
        //[sharedObject initialize];
    }
    return sharedObject;
}

-(NSArray*)syncedSettingIndexes{
    return @[ @(SettingLaterToday), @(SettingEveningStartTime), @(SettingWeekStart), @(SettingWeekStartTime), @(SettingWeekendStart), @(SettingWeekendStartTime), @(SettingAddToBottom), @(SettingTimeZone), @(SettingFilter), @(SettingUseStandardStatusBar), @(ProfileName), @(ProfilePhone), @(ProfileCompany), @(ProfilePosition), @(ProfilePictureURL) ];
}

-(KPSettings)settingForIndex:(NSString*)index{
    KPSettings setting = SettingLaterToday;
    if([index isEqualToString:@"SettingLaterToday"])
        setting = SettingLaterToday;
    else if([index isEqualToString:@"SettingEveningStart"])
        setting = SettingEveningStartTime;
    else if([index isEqualToString:@"SettingWeekStart"])
        setting = SettingWeekStart;
    else if([index isEqualToString:@"SettingWeekStartTime"])
        setting = SettingWeekStartTime;
    else if([index isEqualToString:@"SettingWeekendStart"])
        setting = SettingWeekendStart;
    else if([index isEqualToString:@"SettingWeekendStartTime"])
        setting = SettingWeekendStartTime;
    else if([index isEqualToString:@"SettingAppSounds"])
        setting = SettingAppSounds;
    else if([index isEqualToString:@"SettingNotifications"])
        setting = SettingNotifications;
    else if([index isEqualToString:@"SettingDailyReminders"])
        setting = SettingDailyReminders;
    else if([index isEqualToString:@"SettingWeeklyReminders"])
        setting = SettingWeeklyReminders;
    else if([index isEqualToString:@"SettingAddToBottom"])
        setting = SettingAddToBottom;
    else if([index isEqualToString:@"SettingLocation"])
        setting = SettingLocation;
    else if([index isEqualToString:@"SettingTimeZone"])
        setting = SettingTimeZone;
    else if([index isEqualToString:@"SettingEvernoteSync"])
        setting = SettingEvernoteSync;
    else if([index isEqualToString:@"SettingFilter"])
        setting = SettingFilter;
    else if([index isEqualToString:@"IntegrationEvernoteEnableSync"])
        setting = IntegrationEvernoteEnableSync;
    else if([index isEqualToString:@"IntegrationEvernoteSwipesTag"])
        setting = IntegrationEvernoteSwipesTag;
    else if([index isEqualToString:@"IntegrationEvernoteFindInPersonalLinkedNotebooks"])
        setting = IntegrationEvernoteFindInPersonalLinkedNotebooks;
    else if([index isEqualToString:@"IntegrationEvernoteFindInBusinessNotebooks"])
        setting = IntegrationEvernoteFindInBusinessNotebooks;
    else if([index isEqualToString:@"IntegrationGmailUsingMailbox"])
        setting = IntegrationGmailUsingMailbox;
    else if([index isEqualToString:@"SettingUseStandardStatusBar"])
        setting = SettingUseStandardStatusBar;
    else if([index isEqualToString:@"IntegrationGmailOpenType"])
        setting = IntegrationGmailOpenType;
    else if([index isEqualToString:@"ProfileName"])
        setting = ProfileName;
    else if([index isEqualToString:@"ProfilePhone"])
        setting = ProfilePhone;
    else if([index isEqualToString:@"ProfileCompany"])
        setting = ProfileCompany;
    else if([index isEqualToString:@"ProfilePosition"])
        setting = ProfilePosition;
    else if([index isEqualToString:@"ProfilePictureURL"])
        setting = ProfilePictureURL;
    else if([index isEqualToString:@"ProfilePictureUploaded"])
        setting = ProfilePictureUploaded;
    
    return setting;
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
        case SettingAppSounds:
            index = @"SettingAppSounds";
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
        case SettingAddToBottom:
            index = @"SettingAddToBottom";
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
        case SettingFilter:
            index = @"SettingFilter";
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
        case IntegrationGmailUsingMailbox:
            index = @"IntegrationGmailUsingMailbox";
            break;
        case SettingUseStandardStatusBar:
            index = @"SettingUseStandardStatusBar";
            break;
        case IntegrationGmailOpenType:
            index = @"IntegrationGmailOpenType";
            break;
        case ProfileName:
            index = @"ProfileName";
            break;
        case ProfilePhone:
            index = @"ProfilePhone";
            break;
        case ProfileCompany:
            index = @"ProfileCompany";
            break;
        case ProfilePosition:
            index = @"ProfilePosition";
            break;
        case ProfilePictureURL:
            index = @"ProfilePictureURL";
            break;
        case ProfilePictureUploaded:
            index = @"ProfilePictureUploaded";
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

#ifndef APPLE_WATCH

-(void)sendSettingsToServer{
    NSLog(@"sending sync settings");
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    for( NSNumber *indexNumber in [self syncedSettingIndexes]){
        KPSettings setting = (KPSettings)[indexNumber integerValue];
        NSString *index = [self indexForSettings:setting];
        id value = [self valueForSetting:setting];
        [settings setObject:value forKey:index];
    }
    [kUserHandler saveSettings:[settings copy]];
}

-(void)updateSettingsFromServer:(NSDictionary*)settings{
    if(!settings)
        return [self sendSettingsToServer];
    for( NSNumber *indexNumber in [self syncedSettingIndexes]){
        KPSettings setting = (KPSettings)[indexNumber integerValue];
        NSString *index = [self indexForSettings:setting];
        id currentValue = [self valueForSetting:setting];
        id newValue = [settings objectForKey:index];
        if(newValue && ![newValue isEqual:currentValue]){
            [self setValue:newValue forSetting:setting];
        }
    }
}

#endif

-(void)refreshGlobalSettingsForce:(BOOL)force{
    [self checkTimeZoneChange];
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
        case SettingAppSounds:
            return @YES;
        case SettingNotifications:
            return @YES;
        case SettingDailyReminders:
            return @YES;
        case SettingWeeklyReminders:
            return @YES;
        case SettingAddToBottom:
            return @NO;
        case SettingLocation:
            return @NO;
        case SettingEvernoteSync:
            return @YES;
        case SettingFilter:
            return @"";
        case IntegrationEvernoteEnableSync:
            return @NO;
        case IntegrationEvernoteSwipesTag:
            return @NO;
        case IntegrationEvernoteFindInPersonalLinkedNotebooks:
            return @YES;
        case IntegrationEvernoteFindInBusinessNotebooks:
            return @YES;
        case IntegrationGmailUsingMailbox:
            return @YES;
        case SettingUseStandardStatusBar:
            return @NO;
        case IntegrationGmailOpenType:
            return [self valueForSetting:IntegrationGmailUsingMailbox] ? @(1) : @(0);
        case ProfileName:
        case ProfilePhone:
        case ProfileCompany:
        case ProfilePosition:
        case ProfilePictureURL:
            return @"";
        case ProfilePictureUploaded:
            return @NO;
    }
}

-(id)valueForSetting:(KPSettings)setting{
    @synchronized(self) {
        NSString *index = [self indexForSettings:setting];
        if(!index) return nil;
        id value = [USER_DEFAULTS objectForKey:index];
        if([value isKindOfClass:[NSDate class]]){
            value = [self repairValue:value forSetting:setting];
            if(value)
                [self setValue:value forSetting:setting notify:NO];
        }
        if(!value){
            value = [self defaultValueForSettings:setting];
            [self setValue:value forSetting:setting notify:NO];
        }
        return value;
    }
}

-(void)setValue:(id)value forSetting:(KPSettings)setting{
    [self setValue:value forSetting:setting notify:YES];
}
-(void)setValue:(id)value forSetting:(KPSettings)setting notify:(BOOL)notify{
    NSString *index = [self indexForSettings:setting];
    if(!index) return;
    [USER_DEFAULTS setObject:value forKey:index];
    [USER_DEFAULTS synchronize];
    if(setting == SettingNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
    
#ifndef APPLE_WATCH
    if(notify){
        [[NSNotificationCenter defaultCenter] postNotificationName:SH_UpdateSetting object:self userInfo:@{@"Setting":@(setting), @"Value": value }];
        NSArray *syncedSettings = [self syncedSettingIndexes];
        if([syncedSettings containsObject:@(setting)]){
            if (self.settingTimer && self.settingTimer.isValid)
                [self.settingTimer invalidate];
#ifndef APPLE_WATCH
            self.settingTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sendSettingsToServer) userInfo:nil repeats:NO];
#endif
        }
    }
#endif
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

- (NSMutableDictionary *)settings
{
    if (!_settings) {
        _settings = [USER_DEFAULTS objectForKey:kSettingsDictionaryKey];
        if(!_settings)
            _settings = [NSMutableDictionary dictionary];
        else if( ![_settings isMemberOfClass:[NSMutableDictionary class]]){
            if([_settings isKindOfClass:[NSDictionary class]])
                _settings = [self.settings mutableCopy];
            else{
                _settings = [NSMutableDictionary dictionary];
            }
        }
    }
    return _settings;
}

//-(void)initialize{
//    self.settings = [USER_DEFAULTS objectForKey:kSettingsDictionaryKey];
//    if(!self.settings)
//        self.settings = [NSMutableDictionary dictionary];
//    else if( ![self.settings isMemberOfClass:[NSMutableDictionary class]]){
//        
//        if([self.settings isKindOfClass:[NSDictionary class]])
//            self.settings = [self.settings mutableCopy];
//        else{
//            self.settings = [NSMutableDictionary dictionary];
//        }
//    }
//}

-(void)printSettings{
    NSLog(@"%@",self.settings);
    for(KPSettings setting = 0 ; setting <= IntegrationEvernoteFindInBusinessNotebooks ; setting++){
        NSLog(@"%@ - %@", [self indexForSettings:setting] ,[self valueForSetting:setting]);
    }
}
-(void)dealloc{
}

@end
