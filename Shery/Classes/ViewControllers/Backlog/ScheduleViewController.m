//
//  BacklogViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 18/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ScheduleViewController.h"

@interface ScheduleViewController () <MCSwipeTableViewCellDelegate>
@end

@implementation ScheduleViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.state = @"schedule";
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

#pragma mark - Table view data source
-(NSString *)stateForTriggerState:(MCSwipeTableViewCellState)state{
    switch (state) {
        case MCSwipeTableViewCellState1:
            return @"today";
            break;
        case MCSwipeTableViewCellState2:
            return @"done";
            break;
        case MCSwipeTableViewCellState3:
        case MCSwipeTableViewCellState4:
        case MCSwipeTableViewCellStateNone:
            return nil;
            break;
    }
}
-(UITableViewCell *)cell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setFirstStateIconName:@"list.png"
                     firstColor:SWIPES_BLUE
            secondStateIconName: @"check.png"
                    secondColor: DONE_COLOR
                  thirdIconName: nil
                     thirdColor:nil
                 fourthIconName:nil
                    fourthColor:nil];
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionRight;
    return cell;
}

@end
