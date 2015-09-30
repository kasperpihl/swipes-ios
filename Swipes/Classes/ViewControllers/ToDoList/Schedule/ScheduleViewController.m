//
//  ScheduleViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SlackWebAPIClient.h"
#import "ScheduleViewController.h"

@interface ScheduleViewController ()
@end

@implementation ScheduleViewController
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSDate *startDate = [NSDate date];
    NSString* userId = SLACKWEBAPI.userId;
    NSPredicate *schedulePredicate = [NSPredicate predicateWithFormat:@"schedule > %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES AND (toUserId = %@ OR ANY assignees.userId == %@)", startDate, userId, userId];
    NSPredicate *unspecifiedPredicate = [NSPredicate predicateWithFormat:@"schedule = nil AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES AND (toUserId = %@ OR ANY assignees.userId == %@)", userId, userId];
    NSArray *scheduleArray = [KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:schedulePredicate];
    NSArray *unspecifiedArray = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:unspecifiedPredicate];
    NSArray *totalArray = [scheduleArray arrayByAddingObjectsFromArray:unspecifiedArray];
    return totalArray;
}
-(NSString *)itemHandler:(ItemHandler *)handler titleForItem:(KPToDo *)item{
    return [item readableTitleForStatus];
}
- (void)viewDidLoad
{
    self.state = @"schedule";
    [super viewDidLoad];
    self.tableView.reorderingEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
