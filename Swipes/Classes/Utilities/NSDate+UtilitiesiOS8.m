//
//  NSDate+UtilitiesiOS8.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "NSDate+UtilitiesiOS8.h"
#define DATE_COMPONENTS (NSCalendarUnitEra | NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (UtilitiesiOS8)
+(NSDate *)dateThisOrTheNextDayWithHours:(NSInteger)hours minutes:(NSInteger)minutes{
    NSDate *today = [NSDate date];
    NSDate *returnDate = [[[today dateAtStartOfDay] dateByAddingHours:hours] dateByAddingMinutes:minutes];
    if([returnDate isInPast]){
        returnDate = [returnDate dateByAddingDays:1];
    }
    return returnDate;
}
+ (NSDate *) dateThisOrNextWeekWithDay:(NSInteger)day hours:(NSInteger)hours minutes:(NSInteger)minutes{
    NSDate *today = [NSDate date];
    
    NSDateComponents *nowComponents = [CURRENT_CALENDAR components: NSCalendarUnitWeekOfYear| NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:today];
    
    [nowComponents setWeekday:day]; //Monday
    [nowComponents setHour:hours]; //8a.m.
    [nowComponents setMinute:minutes];
    [nowComponents setSecond:0];
    NSDate *beginningOfWeek = [CURRENT_CALENDAR dateFromComponents:nowComponents];
    
    
    if([beginningOfWeek isInPast]){
        beginningOfWeek = [beginningOfWeek dateByAddingTimeInterval:D_WEEK];
    }
    return beginningOfWeek;
    
}
#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL) isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}
-(BOOL)isSameDayAsDate:(NSDate*)aDate{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.day == components2.day) && (components1.month == components2.month) &&
            (components1.year == components2.year) && (components1.era == components2.era));
}
// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year) && (components1.era == components2.era));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}
#pragma mark Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark Adjusting Dates
- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}
-(NSDate *)dateByAddingYears:(NSInteger)dYears{
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear: dYears];
    return [CURRENT_CALENDAR dateByAddingComponents:offsetComponents toDate:self options:0];
}
-(NSDate *)dateByAddingMonths:(NSInteger)dMonths{
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:dMonths];
    
    NSDate *retDate = [CURRENT_CALENDAR dateByAddingComponents:offsetComponents toDate:self options:0];
    NSInteger numberOfDaysInMonth = [CURRENT_CALENDAR rangeOfUnit:NSCalendarUnitDay
                                                           inUnit:NSCalendarUnitMonth
                                                          forDate:retDate].length;
    NSLog(@"numberOfDays:%li",(long)numberOfDaysInMonth);
    if(retDate.day >= 28 && retDate.day < numberOfDaysInMonth){
        offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:numberOfDaysInMonth-retDate.day];
        retDate = [CURRENT_CALENDAR dateByAddingComponents:offsetComponents toDate:retDate options:0];
    }
    
    return retDate;
}
-(NSDate *)dateByAddingWeeks:(NSInteger) dWeeks{
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeekOfYear: dWeeks];
    return [CURRENT_CALENDAR dateByAddingComponents:offsetComponents toDate:self options:0];
}
-(NSDate *)dateAtNextWeekendDay{
    return [self dateAtNextWorkOrWeekendDay:YES];
}
-(NSDate *)dateAtNextWorkday{
    return [self dateAtNextWorkOrWeekendDay:NO];
}
-(NSDate *)dateAtNextWorkOrWeekendDay:(BOOL)isWeekendDay{
    BOOL nextDayIsWorkday;
    NSDate *nextDay = self;
    do{
        nextDay = [nextDay dateByAddingDays:1];
        nextDayIsWorkday = nextDay.isTypicallyWorkday;
    }
    while (nextDayIsWorkday == isWeekendDay);
    return nextDay;
}
-(NSDate *)dateAtHours:(NSInteger)hours minutes:(NSInteger)minutes{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = hours;
    components.minute = minutes;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}
-(NSDate *)dateAtWeekday:(NSInteger)weekday{
    NSDate *today = [NSDate date];
    
    NSDateComponents *nowComponents = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:today];
    
    [nowComponents setWeekday:weekday]; //Monday
    [nowComponents setSecond:0];
    
    NSDate *beginningOfWeek = [CURRENT_CALENDAR dateFromComponents:nowComponents];
    
    
    if([beginningOfWeek isInPast]){
        beginningOfWeek = [beginningOfWeek dateByAddingTimeInterval:D_WEEK];
        //[nowComponents setWeekOfYear: [nowComponents weekOfYear] + 1];
        //beginningOfWeek = [CURRENT_CALENDAR dateFromComponents:nowComponents];
    }
    return beginningOfWeek;
}
- (NSDate *) dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}


#pragma mark Rounding times
- (NSDate *)dateToNearest15Minutes {
    return [self dateToNearestMinutes:15];
}
- (NSDate *)dateToNearestMinutes:(NSInteger)minutes {
    unsigned unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal;
    // Extract components.
    NSDateComponents *time = [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
    NSInteger thisMin = [time minute];
    NSDate *newDate;
    NSInteger remain = thisMin % minutes;
    // if less then 3 then round down
    NSInteger dividor = ceil(minutes/2);
    if (remain<dividor){
        // Subtract the remainder of time to the date to round it down evenly
        newDate = [self dateByAddingTimeInterval:-60*(remain)];
    }else{
        // Add the remainder of time to the date to round it up evenly
        newDate = [self dateByAddingTimeInterval:60*(minutes-remain)];
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:newDate];
    [comps setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}
-(NSDate *)dateToNearest5Minutes{
    return [self dateToNearestMinutes:5];
}
#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}


#pragma mark Decomposing Dates
-(NSInteger)dayOfYear{
    return [CURRENT_CALENDAR ordinalityOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitYear forDate:self];
}
- (NSInteger) nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}
- (NSInteger) hour
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.hour;
}
- (NSInteger) minute
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.minute;
}
- (NSInteger) seconds
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger) day
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger) month
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.month;
}

- (NSInteger) week
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekOfYear;
}

- (NSInteger) weekday
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger) year
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.year;
}
@end
