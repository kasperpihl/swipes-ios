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
#import "SWAScheduleCell.h"
#import "ScheduleInterfaceController.h"

static NSString * const kCellIdentifier = @"SWAScheduleCell";
static NSInteger const kTotalRows = 8;

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

@interface ScheduleInterfaceController ()

@property (nonatomic, strong) KPToDo* todo;
@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;

@end

@implementation ScheduleInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _todo = context;
    [self reloadData];
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self reloadData];
}

- (NSString *)stringForTableRow:(KPScheduleButtons)state
{
    NSString *returnString;
    switch (state) {
        case KPScheduleButtonLaterToday:
            returnString = LOCALIZE_STRING(@"Later Today");
            break;
        case KPScheduleButtonThisEvening:
            returnString = LOCALIZE_STRING(@"This Evening");
            break;
        case KPScheduleButtonTomorrow:
            returnString = LOCALIZE_STRING(@"Tomorrow");
            break;
        case KPScheduleButtonIn2Days:
            returnString = LOCALIZE_STRING(@"In 2 Days");
            break;
        case KPScheduleButtonThisWeekend:
            returnString = LOCALIZE_STRING(@"This Weekend");
            break;
        case KPScheduleButtonNextWeek:
            returnString = LOCALIZE_STRING(@"Next Week");
            break;
        case KPScheduleButtonUnscheduled:
            returnString = LOCALIZE_STRING(@"Unspecified");
            break;
        case KPScheduleButtonCancel:
            returnString = LOCALIZE_STRING(@"Cancel");
            break;
    }
    return returnString;
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

- (void)reloadData
{
    [self.table setNumberOfRows:kTotalRows withRowType:kCellIdentifier];
    for (NSInteger i = 0; i < kTotalRows; i++) {
        SWAScheduleCell* cell = [self.table rowControllerAtIndex:i];
        [cell.label setText:[self stringForTableRow:i]];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    [super table:table didSelectRowAtIndex:rowIndex];
    if (rowIndex == KPScheduleButtonCancel) {
        [self popController];
    }
    else {
        NSDate* scheduleDate = [self dateForTableRow:rowIndex];
        [WKInterfaceController openParentApplication:@{kKeyCmdSchedule: _todo.tempId, kKeyCmdDate: scheduleDate} reply:^(NSDictionary *replyInfo, NSError *error) {
            if (error) {
                [self popController];
            }
            else {
                [self popToRootController];
            }
        }];
    }
}

@end
