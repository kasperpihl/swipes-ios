//
//  NotificationsViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define kLocalCellHeight 55
#define kSwitchTag 13

#import "UIView+Utilities.h"
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "SettingsViewController.h"

//typedef enum {
//    IndexPathTweaks = 0,
//    IndexPathSounds,
//    IndexPathNotifications
//} IndexPathSettings;
//
@interface SettingsViewController ()

//@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    self.title = @"OPTIONS";
    [super viewDidLoad];

//    self.view.backgroundColor = CLEAR;
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    self.tableView.delegate = self;
//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.dataSource = self;
//    self.tableView.rowHeight = kLocalCellHeight;
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    //[self.tableView setSeparatorColor:tcolor(TextColor)];
//    [self.tableView setTableFooterView:[UIView new]];
//    [self.view addSubview:self.tableView];
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    self.cellInfo = @[
                      @{kKeyTitle: LOCALIZE_STRING(@"Add new tasks to bottom"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingAddToBottom],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onAddNewTasksToBottomTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
                      @{kKeyTitle: LOCALIZE_STRING(@"In-app sounds"),
                        kKeyCellType: @(kIntegrationCellTypeCheck),
                        kKeyIsOn: [kSettings valueForSetting:SettingAppSounds],
                        kKeyTouchSelector: NSStringFromSelector(@selector(onInAppSoundsTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
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
}

- (void)onAddNewTasksToBottomTouch
{
    BOOL value = [[kSettings valueForSetting:SettingAddToBottom] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingAddToBottom];
    self.cellInfo[0][kKeyIsOn] = @(value);
}

- (void)onInAppSoundsTouch
{
    BOOL value = [[kSettings valueForSetting:SettingAppSounds] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingAppSounds];
    self.cellInfo[2][kKeyIsOn] = @(value);
}

- (void)onTasksSnoozedForLaterTouch
{
    BOOL value = [[kSettings valueForSetting:SettingNotifications] boolValue];
    value = !value;
    if (!value) {
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Tasks snoozed for later") andMessage:LOCALIZE_STRING(@"Are you sure you no longer want to receive these alarms and reminders?") block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [kSettings setValue:@NO forSetting:SettingNotifications];
                self.cellInfo[4][kKeyIsOn] = @(value);
                [self reloadData];
            }
        }];
    }
    else {
        [kSettings setValue:@(value) forSetting:SettingNotifications];
        self.cellInfo[4][kKeyIsOn] = @(value);
    }
}

- (void)onDailyReminderTouch
{
    BOOL value = [[kSettings valueForSetting:SettingDailyReminders] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingDailyReminders];
    self.cellInfo[5][kKeyIsOn] = @(value);
}

- (void)onWeeklyReminderTouch
{
    BOOL value = [[kSettings valueForSetting:SettingWeeklyReminders] boolValue];
    value = !value;
    [kSettings setValue:@(value) forSetting:SettingWeeklyReminders];
    self.cellInfo[6][kKeyIsOn] = @(value);
}

//- (void)dealloc
//{
//    self.tableView.dataSource = nil;
//    self.tableView.delegate = nil;
//    [self.tableView removeFromSuperview];
//    self.tableView = nil;
//}
//
//-(KPSettings)settingForIndexPath:(NSIndexPath*)indexPath{
//    KPSettings setting = SettingNotifications;
//    if(indexPath.section == IndexPathTweaks){
//        setting = SettingAddToBottom;
//    }
//    else if(indexPath.section == IndexPathSounds){
//        setting = SettingAppSounds;
//    }
//    else if (indexPath.section == IndexPathNotifications){
//        switch (indexPath.row) {
//            case 0:
//                setting = SettingNotifications;
//                break;
//            case 1:
//                setting = SettingDailyReminders;
//                break;
//            case 2:
//                setting = SettingWeeklyReminders;
//                break;
//            default:
//                break;
//        }
//    }
//    
//    return setting;
//}
//-(NSString*)titleForIndexPath:(NSIndexPath *)indexPath{
//    NSString *title;
//    if(indexPath.section == IndexPathTweaks){
//        switch (indexPath.row) {
//            case 0:
//                title = LOCALIZE_STRING(@"Add new tasks to bottom");
//                break;
//            default:
//                break;
//        }
//
//    }
//    else if(indexPath.section == IndexPathSounds){
//        title = LOCALIZE_STRING(@"In-app sounds");
//    }
//    else if(indexPath.section == IndexPathNotifications){
//        switch (indexPath.row) {
//            case 0:
//                title = LOCALIZE_STRING(@"Tasks snoozed for later");
//                break;
//            case 1:
//                title = LOCALIZE_STRING(@"Daily reminder to plan the day");
//                break;
//            case 2:
//                title = LOCALIZE_STRING(@"Weekly reminder to plan the week");
//                break;
//            default:
//                break;
//        }
//    }
//    
//    return title;
//}
//
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    switch (section) {
//        case IndexPathTweaks:
//            return LOCALIZE_STRING(@"Tweaks");
//        case IndexPathSounds:
//            return LOCALIZE_STRING(@"Sounds");
//        case IndexPathNotifications:
//            return LOCALIZE_STRING(@"Notifications");
//        default:
//            return @"";
//    }
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    switch (section) {
//        case IndexPathTweaks:
//            return 1;
//        case IndexPathSounds:
//            return 1;
//        case IndexPathNotifications:
//            return 3;
//        default:
//            return 0;
//    }
//}
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 3;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *cellIdentifier = @"SwitchCell";
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//
//    if ( cell == nil ){
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        cell.contentView.backgroundColor = CLEAR;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = CLEAR;
//        cell.textLabel.font = KP_REGULAR(13);
//        UISwitch *aSwitch = [[UISwitch alloc] init];
//        aSwitch.tag = kSwitchTag;
//        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        CGRectSetCenter(aSwitch, cell.frame.size.width-aSwitch.frame.size.width/2 - 5, kLocalCellHeight/2);
//        [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
//        
//        [cell.contentView addSubview:aSwitch];
//    }
//	return cell;
//}
//
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    KPSettings setting = [self settingForIndexPath:indexPath];
//    BOOL settingIsOn = [[kSettings valueForSetting:setting] boolValue];
//    NSString *title = [self titleForIndexPath:indexPath];
//    cell.textLabel.textColor = tcolor(TextColor);
//    
//    UISwitch *aSwitch = (UISwitch*)[cell viewWithTag:kSwitchTag];
//    cell.textLabel.text = title;
//    aSwitch.on = settingIsOn;
//}
//
//-(void)switchChanged:(UISwitch*)sender{
//    UITableViewCell *cell = (UITableViewCell*)[sender firstSuperviewOfClass:[UITableViewCell class]];
//    NSIndexPath *switchHandled = [self.tableView indexPathForCell:cell];
//    KPSettings setting = [self settingForIndexPath:switchHandled];
//    if(sender.on){
//        [kSettings setValue:@YES forSetting:setting];
//    }
//    else{
//        if(switchHandled.section == IndexPathNotifications){
//            [UTILITY confirmBoxWithTitle:[self titleForIndexPath:switchHandled] andMessage:LOCALIZE_STRING(@"Are you sure you no longer want to receive these alarms and reminders?") block:^(BOOL succeeded, NSError *error) {
//                if(succeeded)
//                    [kSettings setValue:@NO forSetting:setting];
//                else
//                    sender.on = YES;
//            }];
//        }
//        else {
//            [kSettings setValue:@NO forSetting:setting];
//        }
//    }
//    
//}
//
@end
