//
//  NotificationsViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPTopClock.h"
#import "UIView+Utilities.h"
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSLocalizedString(@"TWEAKS", nil) uppercaseString];
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    self.cellInfo = @[
                      @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: NSLocalizedString(@"TWEAKS", nil)},
                      @{kKeyTitle: NSLocalizedString(@"Add new tasks to bottom", nil),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingAddToBottom],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onAddNewTasksToBottomTouch))
                        }.mutableCopy,
                      @{kKeyTitle: NSLocalizedString(@"Use standard status bar", nil),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingUseStandardStatusBar],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onUseStandardStatusBarTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: NSLocalizedString(@"SOUNDS", nil)},
                      @{kKeyTitle: NSLocalizedString(@"In-app sounds", nil),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingAppSounds],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onInAppSoundsTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: NSLocalizedString(@"NOTIFICATIONS", nil)},
                      @{kKeyTitle: NSLocalizedString(@"Tasks snoozed for later", nil),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingNotifications],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onTasksSnoozedForLaterTouch))
                        }.mutableCopy,
                      @{kKeyTitle: NSLocalizedString(@"Daily reminder to plan the day", nil),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingDailyReminders],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onDailyReminderTouch))
                        }.mutableCopy,
                      @{kKeyTitle: NSLocalizedString(@"Weekly reminder to plan the week", nil),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingWeeklyReminders],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onWeeklyReminderTouch))
                        }.mutableCopy,
                      ];
    
    if ([self showAppSettings]) {
        self.cellInfo = [self.cellInfo arrayByAddingObjectsFromArray:@[
                                                                       @{kKeyTitle: NSLocalizedString(@"App permissions", nil),
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

- (void)onUseStandardStatusBarTouch
{
    BOOL value = [[kSettings valueForSetting:SettingUseStandardStatusBar] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingUseStandardStatusBar];
    self.cellInfo[2][kKeyIsOn] = @(value);
    [kTopClock setCurrentState:value ? TopClockStateRealStatusBar : TopClockStateClock animated:YES];
}

- (void)onInAppSoundsTouch
{
    BOOL value = [[kSettings valueForSetting:SettingAppSounds] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingAppSounds];
    self.cellInfo[4][kKeyIsOn] = @(value);
}

- (void)onTasksSnoozedForLaterTouch
{
    BOOL value = [[kSettings valueForSetting:SettingNotifications] boolValue];
    value = !value;
    if (!value) {
        [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Tasks snoozed for later", nil) andMessage:NSLocalizedString(@"Are you sure you no longer want to receive these alarms and reminders?", nil) block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [kSettings setValue:@NO forSetting:SettingNotifications];
                self.cellInfo[6][kKeyIsOn] = @(value);
                [self reloadData];
            }
        }];
    }
    else {
        [kSettings setValue:@(value) forSetting:SettingNotifications];
        self.cellInfo[6][kKeyIsOn] = @(value);
    }
}

- (void)onDailyReminderTouch
{
    BOOL value = [[kSettings valueForSetting:SettingDailyReminders] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingDailyReminders];
    self.cellInfo[7][kKeyIsOn] = @(value);
}

- (void)onWeeklyReminderTouch
{
    BOOL value = [[kSettings valueForSetting:SettingWeeklyReminders] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingWeeklyReminders];
    self.cellInfo[8][kKeyIsOn] = @(value);
}

- (void)onShowAppSettingsTouch
{
    if (&UIApplicationOpenSettingsURLString != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
