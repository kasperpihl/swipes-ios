//
//  SWAUtility.m
//  Swipes
//
//  Created by demosten on 3/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import WatchKit;
#import "SWAIncludes.h"
#import "SWADefinitions.h"
#import "NSDate-Utilities.h"
#import "SWAUtility.h"

NSString* const EVERNOTE_SERVICE = @"evernote";
NSString* const GMAIL_SERVICE = @"gmail";

@implementation SWAUtility

+ (NSString*)timeStringForDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [[dateFormatter stringFromDate:date] lowercaseString];
    
}

+ (NSString *)readableTime:(NSDate *)time
{
    if (!time)
        return nil;

    NSString *timeString = [SWAUtility timeStringForDate:time];
    
    NSDate *beginningOfDate = [time dateAtStartOfDay];
    NSInteger numberOfDaysAfterTodays = [beginningOfDate distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]];
    NSString *dateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"en_US", nil)];
    [dateFormatter setLocale:usLocale];
    BOOL shouldFormat = NO;
    if(numberOfDaysAfterTodays == 0){
        dateString = NSLocalizedString(@"Today", nil);
        if ([time isLaterThanDate:[NSDate date]])
            dateString = NSLocalizedString(@"Today", nil);
    }
    else if(numberOfDaysAfterTodays == -1){
        dateString = NSLocalizedString(@"Tomorrow", nil);
    }
    else if(numberOfDaysAfterTodays == 1){
        dateString = NSLocalizedString(@"Yesterday", nil);
    }
    else if(numberOfDaysAfterTodays < 7 && numberOfDaysAfterTodays > -7){
        [dateFormatter setDateFormat:@"EEEE"];
        shouldFormat = YES;
    }
    else{
        if([time isSameYearAsDate:[NSDate date]])
            dateFormatter.dateFormat = @"LLL d";
        else
            dateFormatter.dateFormat = @"LLL d  '´'yy";
        shouldFormat = YES;
    }
    if(shouldFormat){
        dateString = [dateFormatter stringFromDate:time];
        dateString = [dateString capitalizedString];
    }
    
    return [NSString stringWithFormat:@"%@, %@",dateString,timeString];
}

+ (void)sendErrorToHost:(NSError *)error
{
    NSDictionary* data = @{kKeyCmdError: error.description};
    [WKInterfaceController openParentApplication:data reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            DLog(@"Error sendErrorToHost %@", error);
        }
    }];
}

+ (NSArray *)nonCompletedSubtasks:(NSSet *)subtasks
{
    if (!subtasks || (0 == subtasks.count))
        return @[];
    
    NSPredicate *uncompletedPredicate = [NSPredicate predicateWithFormat:@"completionDate == nil"];
    NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    return [[subtasks filteredSetUsingPredicate:uncompletedPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
}

@end
