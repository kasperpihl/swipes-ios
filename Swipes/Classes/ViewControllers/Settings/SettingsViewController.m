//
//  NotificationsViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "UIView+Utilities.h"
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"OPTIONS";
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    self.cellInfo = @[
                      @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: LOCALIZE_STRING(@"TWEAKS")},
                      @{kKeyTitle: LOCALIZE_STRING(@"Add new tasks to bottom"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingAddToBottom],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onAddNewTasksToBottomTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: LOCALIZE_STRING(@"SOUNDS")},
                      @{kKeyTitle: LOCALIZE_STRING(@"In-app sounds"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingAppSounds],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onInAppSoundsTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: LOCALIZE_STRING(@"NOTIFICATIONS")},
                      @{kKeyTitle: LOCALIZE_STRING(@"Tasks snoozed for later"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingNotifications],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onTasksSnoozedForLaterTouch))
                        }.mutableCopy,
                      @{kKeyTitle: LOCALIZE_STRING(@"Daily reminder to plan the day"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingDailyReminders],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onDailyReminderTouch))
                        }.mutableCopy,
                      @{kKeyTitle: LOCALIZE_STRING(@"Weekly reminder to plan the week"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingWeeklyReminders],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onWeeklyReminderTouch))
                        }.mutableCopy,
                      ];
    if ([self showAppSettings]) {
        self.cellInfo = [self.cellInfo arrayByAddingObjectsFromArray:@[
                                                                       @{kKeyTitle: LOCALIZE_STRING(@"App permissions"),
                                                                         kKeyCellType: @(kIntegrationCellTypeViewMore),
                                                                         kKeyTouchSelector: NSStringFromSelector(@selector(onShowAppSettingsTouch))
                                                                         },
                                                                       ]];
    }
}

- (BOOL)showAppSettings
{
    return (&UIApplicationOpenSettingsURLString != nil);
}

#pragma mark - selectors

- (void)onAddNewTasksToBottomTouch
{
    BOOL value = [[kSettings valueForSetting:SettingAddToBottom] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingAddToBottom];
    self.cellInfo[1][kKeyIsOn] = @(value);
}

- (void)onInAppSoundsTouch
{
    BOOL value = [[kSettings valueForSetting:SettingAppSounds] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingAppSounds];
    self.cellInfo[3][kKeyIsOn] = @(value);
}

- (void)onTasksSnoozedForLaterTouch
{
    BOOL value = [[kSettings valueForSetting:SettingNotifications] boolValue];
    value = !value;
    if (!value) {
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Tasks snoozed for later") andMessage:LOCALIZE_STRING(@"Are you sure you no longer want to receive these alarms and reminders?") block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [kSettings setValue:@NO forSetting:SettingNotifications];
                self.cellInfo[5][kKeyIsOn] = @(value);
                [self reloadData];
            }
        }];
    }
    else {
        [kSettings setValue:@(value) forSetting:SettingNotifications];
        self.cellInfo[5][kKeyIsOn] = @(value);
    }
}

- (void)onDailyReminderTouch
{
    BOOL value = [[kSettings valueForSetting:SettingDailyReminders] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingDailyReminders];
    self.cellInfo[6][kKeyIsOn] = @(value);
}

- (void)onWeeklyReminderTouch
{
    BOOL value = [[kSettings valueForSetting:SettingWeeklyReminders] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingWeeklyReminders];
    self.cellInfo[6][kKeyIsOn] = @(value);
}

- (void)onShowAppSettingsTouch
{
    if (&UIApplicationOpenSettingsURLString != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
