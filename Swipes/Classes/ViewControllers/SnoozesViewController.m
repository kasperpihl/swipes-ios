//
//  SnoozesViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "DayPickerSettingsCell.h"
#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "KPTimePicker.h"
#import "AppDelegate.h"
#import "IntegrationTitleView.h"
#import "SnoozesViewController.h"

static CGFloat const kTopMargin = 60;
static CGFloat const kBottomMargin = 45;

@interface SnoozesViewController () <UITableViewDataSource,UITableViewDelegate,KPTimePickerDelegate,DayPickerSettingsDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) SnoozeSettings activeSnooze;
@property (nonatomic, strong) IntegrationTitleView* titleView;
@property (nonatomic, strong) UIButton* backButton;

@end

@implementation SnoozesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titleView = [[IntegrationTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTopMargin)];
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleView.title = LOCALIZE_STRING(@"SNOOZES");
    [self.view addSubview:_titleView];

    self.activeSnooze = SnoozeNone;
    self.view.backgroundColor = tcolor(BackgroundColor);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopMargin, self.view.bounds.size.width, self.view.bounds.size.height - kTopMargin - kBottomMargin)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self.tableView setSeparatorColor:tcolor(TextColor)];
    [self.tableView setTableFooterView:[UIView new]];
    [self.view addSubview:self.tableView];

    // setup back button
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - kBottomMargin, kBottomMargin, kBottomMargin - 15)];
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    self.backButton.titleLabel.font = iconFont(23);
    [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}

- (void)pressedBack:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(NSString*)settingForSnooze:(SnoozeSettings)snooze
{
    NSString *setting;
    switch (snooze) {
        case SnoozeWeekStartTime:
            setting = LOCALIZE_STRING(@"Start my day at");
            break;
        case SnoozeEveningStartTime:
            setting = LOCALIZE_STRING(@"Start my evening at");
            break;
        case SnoozeWeekendStartTime:
            setting = LOCALIZE_STRING(@"Start my weekends at");
            break;
        case SnoozeWeekStart:
            setting = LOCALIZE_STRING(@"My week starts");
            break;
        case SnoozeWeekendStart:
            setting = LOCALIZE_STRING(@"My weekend starts");
            break;
        case SnoozeLaterToday:
            setting = LOCALIZE_STRING(@"Snooze Later Today");
            break;
        default:break;
    }
    return setting;
}

-(KPSettings)settingValForSnooze:(SnoozeSettings)snooze
{
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
        default:
            return -1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SnoozeTotalNumber;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SettingCell";
    DayPickerSettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DayPickerSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
	return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(DayPickerSettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnoozeSettings snooze = indexPath.row;
    NSString *valueString;
    KPSettings setting = [self settingValForSnooze:snooze];
    NSNumber *settingValue = (NSNumber*)[kSettings valueForSetting:setting];
    NSDate *settingDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    BOOL capitalizeString = NO;
    switch (snooze) {
        case SnoozeWeekStartTime:
        case SnoozeEveningStartTime:
        case SnoozeWeekendStartTime:{
            settingDate = [[[NSDate date] dateAtStartOfDay] dateByAddingTimeInterval:settingValue.integerValue];
            [formatter setLocale:[NSLocale currentLocale]];
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            break;
        }
        case SnoozeWeekStart:
        case SnoozeWeekendStart:{
            settingDate = [NSDate dateThisOrNextWeekWithDay:settingValue.integerValue hours:8 minutes:0];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:LOCALIZE_STRING(@"en_US")]];
            [formatter setDateFormat:@"EEEE"];
            [cell.dayPicker setSelectedDay:settingDate.weekday];
            capitalizeString = YES;
            break;
        }
        case SnoozeLaterToday:{
            settingDate = [[[NSDate date] dateAtStartOfDay] dateByAddingTimeInterval:settingValue.integerValue];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [formatter setDateFormat:LOCALIZE_STRING(@"'+'H':'mm'h'")];
            break;
        }
        default:break;
    }
    valueString = [formatter stringFromDate:settingDate];
    if(capitalizeString)
        valueString = [valueString capitalizedString];
    [cell setSetting:[self settingForSnooze:indexPath.row] value:valueString];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnoozeSettings snooze = indexPath.row;
    if(snooze == self.activeSnooze){
        if(snooze == SnoozeWeekendStart || snooze == SnoozeWeekStart) return 2*kCellHeight;
    }
    return kCellHeight;
}

-(void)timePicker:(KPTimePicker *)timePicker selectedDate:(NSDate *)date
{
    if(date) [kSettings setValue:@([date timeIntervalSinceDate:[date dateAtStartOfDay]]) forSetting:[self settingValForSnooze:self.activeSnooze]];
    [UIView animateWithDuration:0.1 animations:^{
        timePicker.alpha = 0;
    } completion:^(BOOL finished) {
        [timePicker removeFromSuperview];
    }];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.activeSnooze inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    self.activeSnooze = SnoozeNone;
}

-(NSString *)timePicker:(KPTimePicker *)timePicker clockForDate:(NSDate *)time
{
    if(self.activeSnooze == SnoozeLaterToday){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setDateFormat:LOCALIZE_STRING(@"'+'H':'mm'h'")];
        return [formatter stringFromDate:time];
    }
    else return nil;
}

-(NSString *)timePicker:(KPTimePicker *)timePicker titleForDate:(NSDate *)time
{
    return [self settingForSnooze:self.activeSnooze];
}

-(void)dayPickerCell:(DayPickerSettingsCell *)cell pickedWeekDay:(NSInteger)weekday
{
    KPSettings setting = [self settingValForSnooze:self.activeSnooze];
    NSNumber *weekdayDate = (NSNumber*)[kSettings valueForSetting:setting];
    if(weekday != weekdayDate.integerValue){
        [kSettings setValue:@(weekday) forSetting:setting];
    }
    SnoozeSettings snooze = self.activeSnooze;
    self.activeSnooze = SnoozeNone;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:snooze inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnoozeSettings snooze = indexPath.row;
    if(self.activeSnooze == snooze && (self.activeSnooze == SnoozeWeekendStart || self.activeSnooze == SnoozeWeekStart)){
        self.activeSnooze = SnoozeNone;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:snooze inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    else if(self.activeSnooze != SnoozeNone)
        return;
    
    self.activeSnooze = snooze;
    KPSettings setting = [self settingValForSnooze:snooze];
    NSNumber *settingValue = (NSNumber*)[kSettings valueForSetting:setting];
    
    switch (snooze) {
        case SnoozeLaterToday:
        case SnoozeWeekStartTime:
        case SnoozeEveningStartTime:
        case SnoozeWeekendStartTime:{
            NSDate *settingDate = [[[NSDate date] dateAtStartOfDay] dateByAddingTimeInterval:settingValue.integerValue];
            KPTimePicker *timePicker = [[KPTimePicker alloc] initWithFrame:self.view.bounds];
            timePicker.pickingDate = settingDate;
            timePicker.minimumDate = [settingDate dateAtStartOfDay];
            if(self.activeSnooze == SnoozeLaterToday){
                timePicker.minimumDate = [timePicker.minimumDate dateByAddingMinutes:10];
                timePicker.hideIcons = YES;
            }
            timePicker.maximumDate = [[[settingDate dateByAddingDays:1] dateAtStartOfDay] dateBySubtractingMinutes:5];
            timePicker.delegate = self;
            timePicker.alpha = 0;
            [self.view addSubview:timePicker];
            [UIView animateWithDuration:0.1 animations:^{
                timePicker.alpha = 1;
            }];
        }
        case SnoozeWeekStart:
        case SnoozeWeekendStart:{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:snooze inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        default:break;
    }
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
