//
//  BacklogViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 18/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "BacklogViewController.h"
#import "ToDoCell.h"

@interface BacklogViewController () <MCSwipeTableViewCellDelegate>
@end

@implementation BacklogViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(void)update{
    self.items = [self loadItems];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updatedBacklog", update);
    self.tableView.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.items.count;
}
-(UITableViewCell *)cell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setFirstStateIconName:@"clock.png"
                     firstColor:[UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
            secondStateIconName: @"check.png"
                    secondColor: [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
                  thirdIconName: @"cross.png"
                     thirdColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                 fourthIconName:nil//@"list.png"
                    fourthColor:nil];//[UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0]];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
    return cell;
}


- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
    NSLog(@"dragged ended");
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
