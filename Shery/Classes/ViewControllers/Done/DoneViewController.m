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
    [cell setFirstStateIconName:nil
                     firstColor:nil
            secondStateIconName: nil
                    secondColor: nil
                  thirdIconName:@"list.png"
                     thirdColor:SWIPES_BLUE
                 fourthIconName:@"clock.png"
                    fourthColor:SCHEDULE_COLOR];
    
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionLeft;
    return cell;
}
-(NSString *)stateForTriggerState:(MCSwipeTableViewCellState)state{
    switch (state) {
        case MCSwipeTableViewCellState3:
            return @"today";
            break;
        case MCSwipeTableViewCellState4:
            return @"schedule";
            break;
        case MCSwipeTableViewCellState1:
        case MCSwipeTableViewCellState2:
        case MCSwipeTableViewCellStateNone:
            return nil;
            break;
    }
}
@end
