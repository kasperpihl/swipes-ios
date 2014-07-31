//
//  SettingsHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
typedef enum {
    SettingWeekStartTime,
    SettingWeekendStartTime,
    SettingEveningStartTime,
    SettingWeekStart,
    SettingWeekendStart,
    SettingLaterToday,
    SettingNotifications,
    SettingDailyReminders,
    SettingWeeklyReminders,
    SettingLocation,
    SettingEvernoteSync,
    
    IntegrationEvernoteEnableSync,
    IntegrationEvernoteSwipesTag
} KPSettings;
#import <Foundation/Foundation.h>
#define kSettings [SettingsHandler sharedInstance]
@interface SettingsHandler : NSObject
+(SettingsHandler*)sharedInstance;

-(id)valueForSetting:(KPSettings)setting;
-(void)setValue:(id)value forSetting:(KPSettings)setting;
-(void)refreshGlobalSettingsForce:(BOOL)force;
-(UIImage*)getDailyImage;

/* Boolean settings in ns user defaults */
-(BOOL)settingForKey:(NSString*)key;
-(void)setSetting:(BOOL)setting forKey:(NSString*)key;
@end
