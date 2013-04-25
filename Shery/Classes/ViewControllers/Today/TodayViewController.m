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
                     firstColor:DONE_COLOR
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:@"clock.png"
                     thirdColor:SCHEDULE_COLOR
                 fourthIconName:nil
                    fourthColor:nil];
    
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    return cell;
}
-(NSString *)stateForTriggerState:(MCSwipeTableViewCellState)state{
    switch (state) {
        case MCSwipeTableViewCellState1:
            return @"done";
            break;
        case MCSwipeTableViewCellState3:
            return @"schedule";
            break;
        case MCSwipeTableViewCellState4:
            return @"deleted";
            break;
        
        case MCSwipeTableViewCellState2:
        case MCSwipeTableViewCellStateNone:
            return nil;
            break;
    }
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
