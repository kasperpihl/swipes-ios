//
//  ScheduleViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ScheduleViewController.h"

@interface ScheduleViewController ()
@end

@implementation ScheduleViewController
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSDate *startDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSPredicate *schedulePredicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule > %@)",@"scheduled", startDate];
    NSPredicate *unspecifiedPredicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule = nil)",@"scheduled"];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
