//
//  ScheduleInterfaceController.m
//  Swipes
//
//  Created by demosten on 3/3/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
#import "SWAIncludes.h"
#import "SWADefinitions.h"
#import "CoreData/KPToDo.h"
#import "ScheduleInterfaceController.h"

static NSString * const kCellIdentifier = @"SWAScheduleCell";

typedef NS_ENUM(NSUInteger, KPScheduleButtons){
    KPScheduleButtonLaterToday = 0,
    KPScheduleButtonThisEvening = 1,
    KPScheduleButtonTomorrow = 2,
    KPScheduleButtonIn2Days = 3,
    KPScheduleButtonThisWeekend = 4,
    KPScheduleButtonNextWeek = 5,
    KPScheduleButtonUnscheduled = 6,
    KPScheduleButtonCancel = 7,
};

static NSArray* g_weekDays;

@interface ScheduleInterfaceController ()

@property (nonatomic, strong) KPToDo* todo;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* laterButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* nextWeekButton;

@end

@implementation ScheduleInterfaceController

+ (void)initialize
{
    g_weekDays = @[NSLocalizedString(@"Mon", nil), NSLocalizedString(@"Sun", nil), NSLocalizedString(@"Mon", nil),
                   NSLocalizedString(@"Tue", nil), NSLocalizedString(@"Wed", nil), NSLocalizedString(@"Thu", nil),
                   NSLocalizedString(@"Fri", nil), NSLocalizedString(@"Sat", nil)];
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _todo = context;
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSNumber *laterToday = (NSNumber*)[kSettings valueForSetting:SettingLaterToday];
    // TODO figure our a better way to have this formated
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"+%luh", nil),(long)(laterToday.integerValue/3600)];
    [_laterButton setTitle:title];
    NSNumber *weekStart = (NSNumber*)[kSettings valueForSetting:SettingWeekStart];
    [_nextWeekButton setTitle:weekStart ? g_weekDays[[weekStart unsignedIntValue]] : g_weekDays[2]];
}

- (void)openAppForDate:(NSDate*)scheduleDate
{
    [WKInterfaceController openParentApplication:@{kKeyCmdSchedule: _todo.tempId, kKeyCmdDate: scheduleDate} reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            [self popController];
        }
        else {
            [self popToRootController];
        }
    }];
}

- (IBAction)onLaterToday:(id)sender
{
    NSDate* scheduleDate = [self dateForTableRow:KPScheduleButtonLaterToday];
    [self openAppForDate:scheduleDate];
}

- (IBAction)onTomorrow:(id)sender
{
    NSDate* scheduleDate = [self dateForTableRow:KPScheduleButtonTomorrow];
    [self openAppForDate:scheduleDate];
}

- (IBAction)onThisEvening:(id)sender
{
    NSDate* scheduleDate = [self dateForTableRow:KPScheduleButtonThisEvening];
    [self openAppForDate:scheduleDate];
}

- (IBAction)onNextWeek:(id)sender
{
    NSDate* scheduleDate = [self dateForTableRow:KPScheduleButtonNextWeek];
    [self openAppForDate:scheduleDate];
}

-(NSDate*)dateForTableRow:(KPScheduleButtons)button
{
    NSDate *date;
    switch (button) {
        case KPScheduleButtonLaterToday:{
            
            NSNumber *laterToday = (NSNumber*)[kSettings valueForSetting:SettingLaterToday];
            date = [[[NSDate date] dateByAddingTimeInterval:laterToday.integerValue] dateToNearest15Minutes];
            break;
        }
        case KPScheduleButtonThisEvening:{
            NSNumber *eveningStartTime = (NSNumber*)[kSettings valueForSetting:SettingEveningStartTime];
            NSInteger hours = eveningStartTime.integerValue/D_HOUR;
            NSInteger minutes = (eveningStartTime.integerValue % D_HOUR) / D_MINUTE;
            date = [NSDate dateThisOrTheNextDayWithHours:hours minutes:minutes];
            break;
        }
        case KPScheduleButtonTomorrow:{
            NSDate *startTime = [NSDate date];
            NSDate *now = [NSDate date];
            if([startTime isLaterThanDate:now])
                date = now;
            else
                date = [NSDate dateTomorrow];
            break;
        }
        case KPScheduleButtonIn2Days:{
            date = [NSDate dateWithDaysFromNow:2];
            break;
        }
        case KPScheduleButtonThisWeekend:{
            NSNumber *thisWeekend = (NSNumber*)[kSettings valueForSetting:SettingWeekendStart];
            NSNumber *weekendStartTime = (NSNumber*)[kSettings valueForSetting:SettingWeekendStartTime];
            NSInteger hours = weekendStartTime.integerValue/D_HOUR;
            NSInteger minutes = (weekendStartTime.integerValue % D_HOUR) / D_MINUTE;
            date = [NSDate dateThisOrNextWeekWithDay:thisWeekend.integerValue hours:hours minutes:minutes];
            break;
        }
        case KPScheduleButtonNextWeek:{
            NSNumber *nextWeek = (NSNumber*)[kSettings valueForSetting:SettingWeekStart];
            NSNumber *weekStartTime = (NSNumber*)[kSettings valueForSetting:SettingWeekStartTime];
            NSInteger hours = weekStartTime.integerValue/D_HOUR;
            NSInteger minutes = (weekStartTime.integerValue % D_HOUR) / D_MINUTE;
            date = [NSDate dateThisOrNextWeekWithDay:nextWeek.integerValue hours:hours minutes:minutes];
            break;
        }
        case KPScheduleButtonUnscheduled:
        case KPScheduleButtonCancel:
            date = (NSDate *)[NSNull null];
            break;
    }
    return date;
}

@end
