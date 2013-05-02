//
//  DoneViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "DoneViewController.h"
@interface DoneViewController ()
@property (nonatomic) BOOL hasAskedForMore;
@end

@implementation DoneViewController
-(void)loadItems{
    NSDate *startDate = [[NSDate date] dateAtStartOfDay];
    if(self.hasAskedForMore) startDate = [NSDate dateWithDaysBeforeNow:365];
    NSDate *endDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@) AND (completionDate >= %@) AND (completionDate < %@)",@"done", startDate, endDate];
    self.items = [[KPToDo MR_findAllSortedBy:@"completionDate" ascending:NO withPredicate:predicate] mutableCopy];
}
-(void)sortItems{
    self.sortedItems = [NSMutableArray array];
    self.titleArray = [NSMutableArray array];
    for(KPToDo *toDo in self.items){
        NSDate *toDoDate = toDo.completionDate;
        if(toDoDate.isToday) [self addItem:toDo withTitle:@"Today"];
        else if(toDoDate.isYesterday) [self addItem:toDo withTitle:@"Yesterday"];
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            // this is imporant - we set our input date format to match our input string
            // if format doesn't match you'll get nil from your string, so be careful
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            // voila!
            NSString *strDate = [dateFormatter stringFromDate:toDoDate];
            [self addItem:toDo withTitle:strDate];
        }
        
    }
}
#pragma mark - ViewController stuff
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.state = @"done";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
