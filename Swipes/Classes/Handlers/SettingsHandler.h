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
    SettingNotifications
} KPSettings;
#import <Foundation/Foundation.h>
#define kSettings [SettingsHandler sharedInstance]
@interface SettingsHandler : NSObject
+(SettingsHandler*)sharedInstance;
-(id)valueForSetting:(KPSettings)setting;
-(void)setValue:(id)value forSetting:(KPSettings)setting;
@end
