//
//  TodayViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "TodayViewController.h"

@interface TodayViewController ()

@end

@implementation TodayViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.state = @"today";
    }
    return self;
}
-(UITableViewCell *)cell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setFirstStateIconName:@"check.png"
                     firstColor:[UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:@"clock.png"
                     thirdColor:[UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
                 fourthIconName:nil
                    fourthColor:nil];
    
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    return cell;
}
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    NSString *newState;
    
    switch (state) {
        case MCSwipeTableViewCellState1:
            newState = @"done";
            break;
        case MCSwipeTableViewCellState3:
            newState = @"backlog";
            break;
        case MCSwipeTableViewCellState4:
            newState = @"deleted";
            break;
        case MCSwipeTableViewCellState2:
        case MCSwipeTableViewCellStateNone:
            NSLog(@"none triggered");
            break;
    }
    NSLog(@"swiping new:%@",newState);
    [toDo changeState:newState];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    [self loadItems];
    [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
