//
//  SettingsHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SettingWeekStartTime,
    SettingWeekendStartTime,
    SettingEveningStartTime,
    SettingWeekStart,
    SettingWeekendStart,
    SettingLaterToday,
    SettingAppSounds,
    SettingNotifications,
    SettingDailyReminders,
    SettingWeeklyReminders,
    SettingLocation,
    SettingAddToBottom,
    SettingEvernoteSync,
    SettingTimeZone,
    SettingFilter,
    
    IntegrationEvernoteEnableSync,
    IntegrationEvernoteSwipesTag,
    IntegrationEvernoteFindInPersonalLinkedNotebooks,
    IntegrationEvernoteFindInBusinessNotebooks,

    IntegrationGmailUsingMailbox,

    SettingUseStandardStatusBar,

    IntegrationGmailOpenType,
    
} KPSettings;

#define SH_UpdateSetting @"SH_UpdateSetting"
#define kSettings [SettingsHandler sharedInstance]

@interface SettingsHandler : NSObject

+(SettingsHandler*)sharedInstance;

-(id)valueForSetting:(KPSettings)setting;
-(void)setValue:(id)value forSetting:(KPSettings)setting;
-(void)refreshGlobalSettingsForce:(BOOL)force;

/* Boolean settings in ns user defaults */
-(BOOL)settingForKey:(NSString*)key;
-(void)setSetting:(BOOL)setting forKey:(NSString*)key;
-(void)setValue:(id)value forSetting:(KPSettings)setting notify:(BOOL)notify;

-(void)printSettings;

#ifndef APPLE_WATCH
-(void)updateSettingsFromServer:(NSDictionary*)settings;
#endif

@end
