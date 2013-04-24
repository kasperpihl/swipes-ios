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
            return @"deleted";
            break;
        case MCSwipeTableViewCellState4:
        case MCSwipeTableViewCellStateNone:
            return nil;
            break;
    }
}
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

@end
