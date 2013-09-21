//
//  SnoozesViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SnoozesViewController.h"
#import "DayPickerSettingsCell.h"
#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "KPTimePicker.h"
#import "AppDelegate.h"
@interface SnoozesViewController () <UITableViewDataSource,UITableViewDelegate,KPTimePickerDelegate,DayPickerSettingsDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) SnoozeSettings activeSnooze;
@end

@implementation SnoozesViewController
-(NSString*)settingForSnooze:(SnoozeSettings)snooze{
    NSString *setting;
    switch (snooze) {
        case SnoozeWeekStartTime:
            setting = @"Start my day at";
            break;
        case SnoozeEveningStartTime:
            setting = @"Start my evening at";
            break;
        case SnoozeWeekendStartTime:
            setting = @"Start my weekends at";
            break;
        case SnoozeWeekStart:
            setting = @"My week starts";
            break;
        case SnoozeWeekendStart:
            setting = @"My weekend starts";
            break;
        case SnoozeLaterToday:
            setting = @"Snooze Later Today";
            break;
        default:break;
    }
    return setting;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activeSnooze = SnoozeNone;
    self.view.backgroundColor = CLEAR;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    if(OSVER >= 7){
        CGRectSetY(self.tableView, 20);
        CGRectSetHeight(self.tableView, self.view.bounds.size.height-20);
    }
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.tableView setSeparatorColor:tbackground(TimePickerWheelBackground)];
    [self.tableView setTableFooterView:[UIView new]];
    NSLog(@"loaded snoozes");
    [self.view addSubview:self.tableView];
	// Do any additional setup after loading the view.
}
-(KPSettings)settingValForSnooze:(SnoozeSettings)snooze{
    switch (snooze) {
        case SnoozeWeekStartTime:
            return SettingWeekStartTime;
        case SnoozeEveningStartTime:
            return SettingEveningStartTime;
        case SnoozeWeekendStartTime:
            return SettingWeekendStartTime;
        case SnoozeWeekStart:
            return SettingWeekStart;
        case SnoozeWeekendStart:
            return SettingWeekendStart;
        case SnoozeLaterToday:
            return SettingLaterToday;
        default:return -1;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return SnoozeTotalNumber;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"SettingCell";
    DayPickerSettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DayPickerSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
	return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(DayPickerSettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    SnoozeSettings snooze = indexPath.row;
    NSString *valueString;
    KPSettings setting = [self settingValForSnooze:snooze];
    NSDate *settingDate = (NSDate*)[kSettings valueForSetting:setting];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    switch (snooze) {
        case SnoozeWeekStartTime:
        case SnoozeEveningStartTime:
        case SnoozeWeekendStartTime:{
            [formatter setLocale:[NSLocale currentLocale]];
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            break;
        }
        case SnoozeWeekStart:
        case SnoozeWeekendStart:{
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [formatter setDateFormat:@"EEEE"];
            [cell.dayPicker setSelectedDay:settingDate.weekday];
            break;
        }
        case SnoozeLaterToday:{
            [formatter setDateFormat:@"'+'H':'mm'h'"];
            break;
        }
        default:break;
    }
    valueString = [formatter stringFromDate:settingDate];
    [cell setSetting:[self settingForSnooze:indexPath.row] value:valueString];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SnoozeSettings snooze = indexPath.row;
    if(snooze == self.activeSnooze){
        if(snooze == SnoozeWeekendStart || snooze == SnoozeWeekStart) return 2*kCellHeight;
    }
    return kCellHeight;
}
-(void)timePicker:(KPTimePicker *)timePicker selectedDate:(NSDate *)date{
    if(date) [kSettings setValue:date forSetting:[self settingValForSnooze:self.activeSnooze]];
    [UIView animateWithDuration:0.1 animations:^{
        timePicker.alpha = 0;
    } completion:^(BOOL finished) {
        [timePicker removeFromSuperview];
    }];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.activeSnooze inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    self.activeSnooze = SnoozeNone;
}
-(NSString *)timePicker:(KPTimePicker *)timePicker clockForDate:(NSDate *)time{
    if(self.activeSnooze == SnoozeLaterToday){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'+'H':'mm'h'"];
        return [formatter stringFromDate:time];
    }
    else return nil;
}
-(NSString *)timePicker:(KPTimePicker *)timePicker titleForDate:(NSDate *)time{
    return [self settingForSnooze:self.activeSnooze];
}
-(void)dayPickerCell:(DayPickerSettingsCell *)cell pickedWeekDay:(NSInteger)weekday{
    KPSettings setting = [self settingValForSnooze:self.activeSnooze];
    NSDate *weekdayDate = (NSDate*)[kSettings valueForSetting:setting];
    NSLog(@"old:%i new:%i",weekdayDate.weekday,weekday);
    if(weekday != weekdayDate.weekday){
        weekdayDate = [NSDate dateThisOrNextWeekWithDay:weekday hours:8 minutes:0];
        [kSettings setValue:weekdayDate forSetting:setting];
    }
    SnoozeSettings snooze = self.activeSnooze;
    self.activeSnooze = SnoozeNone;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:snooze inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SnoozeSettings snooze = indexPath.row;
    if(self.activeSnooze == snooze && (self.activeSnooze == SnoozeWeekendStart || self.activeSnooze == SnoozeWeekStart)){
        self.activeSnooze = SnoozeNone;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:snooze inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        return;
    }
    else if(self.activeSnooze != SnoozeNone) return;
    self.activeSnooze = snooze;
    KPSettings setting = [self settingValForSnooze:snooze];
    NSDate *settingDate = (NSDate*)[kSettings valueForSetting:setting];
    switch (snooze) {
        case SnoozeLaterToday:
        case SnoozeWeekStartTime:
        case SnoozeEveningStartTime:
        case SnoozeWeekendStartTime:{
            KPTimePicker *timePicker = [[KPTimePicker alloc] initWithFrame:[self parentViewController].view.bounds];
            timePicker.pickingDate = settingDate;
            timePicker.minimumDate = [settingDate dateAtStartOfDay];
            if(self.activeSnooze == SnoozeLaterToday){
                timePicker.minimumDate = [timePicker.minimumDate dateByAddingMinutes:10];
                timePicker.hideIcons = YES;
            }
            timePicker.maximumDate = [[[settingDate dateByAddingDays:1] dateAtStartOfDay] dateBySubtractingMinutes:5];
            timePicker.delegate = self;
            timePicker.alpha = 0;
            [self.parentViewController.view addSubview:timePicker];
            [UIView animateWithDuration:0.1 animations:^{
                timePicker.alpha = 1;
            }];
        }
        case SnoozeWeekStart:
        case SnoozeWeekendStart:{
            [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:snooze inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

            [self.tableView endUpdates];
        }
        default:break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
