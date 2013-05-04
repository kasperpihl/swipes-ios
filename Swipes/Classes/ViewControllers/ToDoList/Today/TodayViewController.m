//
//  TodayViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TABLEVIEW_TAG 501
#import "TodayViewController.h"
#import "KPReorderTableView.h"

@interface TodayViewController ()<ATSDragToReorderTableViewControllerDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>
@property (nonatomic,weak) IBOutlet KPReorderTableView *tableView;
@property (nonatomic,strong) NSIndexPath *dragRow;
@property (nonatomic,strong) KPToDo *draggingObject;
@end

@implementation TodayViewController
#pragma mark - Dragable delegate
-(void)loadItemsAndUpdate:(BOOL)update{
    NSDate *endDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule < %@)",@"scheduled", endDate];
    self.items = [[KPToDo MR_findAllSortedBy:@"schedule" ascending:YES withPredicate:predicate] mutableCopy];

    if(update) [self update];
}
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
	ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self readyCell:cell];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	return cell;
}
- (void)dragTableViewController:(KPReorderTableView *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
    [[self parent] show:NO controlsAnimated:YES];
    self.dragRow = dragRow;
    self.draggingObject = [self.items objectAtIndex:dragRow.row];
    [self deselectAllRows:self];
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    KPToDo *itemToMove = [self.items objectAtIndex:sourceIndexPath.row];
	[self.items removeObjectAtIndex:sourceIndexPath.row];
	[self.items insertObject:itemToMove atIndex:destinationIndexPath.row];
    // TODO: Fix this items
}
-(void)dragTableViewController:(KPReorderTableView *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
    NSInteger targetRow;
    self.tableView.allowsMultipleSelection = YES;
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
    if(destinationIndexPath.row > self.dragRow.row) targetRow = destinationIndexPath.row-1;
    else if(destinationIndexPath.row < self.dragRow.row) targetRow = destinationIndexPath.row+1;
    else targetRow = destinationIndexPath.row;
    KPToDo *replacingToDoObject = [self.items objectAtIndex:targetRow];
    if(targetRow != destinationIndexPath.row){
        [self.draggingObject changeToOrder:replacingToDoObject.orderValue];
        [self update];
    }
    self.draggingObject = nil;
}
#pragma mark - UIViewControllerClasses
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.state = @"today";
    [self.tableView removeFromSuperview];
    KPReorderTableView *tableView = [[KPReorderTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self prepareTableView:tableView];
    tableView.tag = TABLEVIEW_TAG;
    [self.view addSubview:tableView];
    self.tableView = (KPReorderTableView*)[self.view viewWithTag:TABLEVIEW_TAG];
    self.tableView.dragDelegate = self;
    self.tableView.indicatorDelegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
