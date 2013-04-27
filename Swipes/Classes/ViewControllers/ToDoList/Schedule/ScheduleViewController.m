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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@) AND (schedule > %@)",@"schedule", startDate];
    self.items = [[KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:predicate] mutableCopy];
    [self sortItems];
}
-(void)sortItems{
    self.sortedItems = [NSMutableDictionary dictionary];
    for(KPToDo *toDo in self.items){
        NSDate *toDoDate = toDo.schedule;
        if(toDoDate.isTomorrow) [self addItem:toDo toTitle:@"Tomorrow"];
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSString *strDate = [dateFormatter stringFromDate:toDoDate];
            [self addItem:toDo toTitle:strDate];
        }
        
    }
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
