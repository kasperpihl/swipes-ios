//
//  ToDoListTableViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "ToDoCell.h"

@interface ToDoListTableViewController ()<MCSwipeTableViewCellDelegate>

@end

@implementation ToDoListTableViewController
-(NSArray*)loadItems{
    return [KPToDo MR_findAllSortedBy:@"order" ascending:NO];
}
-(NSArray *)items{
    if(!_items){
        _items = [NSArray array];
    }
    return _items;
}
- (UITableViewCell *)cell:(ToDoCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell;
}
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"move row at indexpath");
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SwipeCell";
    ToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    [cell setMode:MCSwipeTableViewCellModeExit];
	return [self cell:cell forRowAtIndexPath:indexPath];
}
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.delegate = self;
    [cell setMode:MCSwipeTableViewCellModeExit];
	return [self cell:cell forRowAtIndexPath:indexPath];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.indicatorDelegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
