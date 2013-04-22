//
//  BacklogViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 18/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "BacklogViewController.h"

@interface BacklogViewController () <MCSwipeTableViewCellDelegate>
@end

@implementation BacklogViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.state = @"backlog";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updatedBacklog", update);
}
-(void)dealloc{
    clearNotify();
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UITableViewCell *)cell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setFirstStateIconName:@"list.png"
                     firstColor:[UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0]
            secondStateIconName: @"check.png"
                    secondColor: [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
                  thirdIconName: nil//@"cross.png"
                     thirdColor:nil//[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                 fourthIconName:nil//@"list.png"
                    fourthColor:nil];//[UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0]];
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionRight;
    return cell;
}
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    NSString *newState;
    
    switch (state) {
        case MCSwipeTableViewCellState1:
            newState = @"today";
            break;
        case MCSwipeTableViewCellState2:
            newState = @"done";
            break;
        case MCSwipeTableViewCellState3:
            newState = @"deleted";
            break;
        case MCSwipeTableViewCellState4:
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


@end
