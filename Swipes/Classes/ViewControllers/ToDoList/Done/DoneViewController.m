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
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSPredicate *predicate;
    NSDate *startDate = [[NSDate date] dateAtStartOfDay];
    if(!self.hasAskedForMore) predicate = [NSPredicate predicateWithFormat:@"(state == %@) AND (completionDate >= %@)",@"done", startDate];
    else predicate = [NSPredicate predicateWithFormat:@"(state == %@)",@"done"];
    return [KPToDo MR_findAllSortedBy:@"completionDate" ascending:NO withPredicate:predicate];
}
-(NSString *)itemHandler:(ItemHandler *)handler titleForItem:(KPToDo *)item{
    NSString *title;
    NSDate *toDoDate = item.completionDate;
    if(toDoDate.isToday) title = @"Today";
    else if(toDoDate.isYesterday) title = @"Yesterday";
    else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // this is imporant - we set our input date format to match our input string
        // if format doesn't match you'll get nil from your string, so be careful
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        // voila!
        NSString *strDate = [dateFormatter stringFromDate:toDoDate];
        title = strDate;
    }
    return title;
}

#pragma mark - ViewController stuff
- (void)viewDidLoad
{
    self.hasAskedForMore = YES;
    self.state = @"done";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
