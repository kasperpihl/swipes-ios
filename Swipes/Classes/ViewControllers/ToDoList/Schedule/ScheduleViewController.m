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
-(void)loadItems{
    NSDate *startDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule > %@) OR (state == %@ AND schedule = nil)",@"schedule", startDate,@"schedule"];
    self.items = [[KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:predicate] mutableCopy];
    [self sortItems];
}
-(void)sortItems{
    self.sortedItems = [NSMutableArray array];
    self.titleArray = [NSMutableArray array];
    NSMutableArray *unspecified = [NSMutableArray array];
    for(KPToDo *toDo in self.items){
        NSDate *toDoDate = toDo.schedule;
        if(!toDoDate) [unspecified addObject:toDo];
        else if(toDoDate.isTomorrow) [self addItem:toDo withTitle:@"Tomorrow"];
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, dd-MM"];
            NSString *strDate = [dateFormatter stringFromDate:toDoDate];
            [self addItem:toDo withTitle:strDate];
        }
    }
    [self addItems:unspecified withTitle:@"Unspecified"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.state = @"schedule";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
