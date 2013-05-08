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
-(void)loadItemsAndUpdate:(BOOL)update{
    NSDate *startDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule > %@) OR (state == %@ AND schedule = nil)",@"scheduled", startDate,@"scheduled"];
    self.items = [[KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:predicate] mutableCopy];
    if(update) [self update];
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
    if(unspecified.count > 0)[self addItems:unspecified withTitle:@"Unspecified"];
}
- (void)viewDidLoad
{
    self.state = @"schedule";
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule_white_background"]];
    imageView.frame = CGRectSetPos(imageView.frame, (self.view.bounds.size.width-imageView.frame.size.width)/2, 90);
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
