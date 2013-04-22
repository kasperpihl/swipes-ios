//
//  DoneViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "DoneViewController.h"

@interface DoneViewController ()

@end

@implementation DoneViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.state = @"done";
    }
    return self;
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

-(UITableViewCell *)cell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setFirstStateIconName:nil//@"cross.png"
                     firstColor:nil//[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
            secondStateIconName: nil
                    secondColor: nil
                  thirdIconName: @"clock.png"
                     thirdColor:[UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
                 fourthIconName:@"list.png"
                    fourthColor:[UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0]];
    
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionLeft;
    return cell;
}
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    NSString *newState;
    
    switch (state) {
        case MCSwipeTableViewCellState3:
            newState = @"today";
            break;
        case MCSwipeTableViewCellState4:
            newState = @"backlog";
            break;
        case MCSwipeTableViewCellState1:
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

@end
