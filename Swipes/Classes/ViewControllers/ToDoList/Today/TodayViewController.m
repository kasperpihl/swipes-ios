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


@end
@implementation TodayViewController
#pragma mark - Dragable delegate
-(void)itemHandler:(ItemHandler *)handler changedItemNumber:(NSInteger)itemNumber{
    [super itemHandler:handler changedItemNumber:itemNumber];
    [self changeToColored:(itemNumber == 0)];
    [self.tableView setReorderingEnabled:(itemNumber > 1)];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:itemNumber];
}
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSDate *endDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule < %@)",@"scheduled", endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    return results;
}
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
	ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self readyCell:cell];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    [cell showTimeline:NO];
	return cell;
}
- (void)dragTableViewController:(KPReorderTableView *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
    [self parent].lock = YES;
    self.dragRow = dragRow;
    [self.itemHandler setDraggingIndexPath:dragRow];
    [self deselectAllRows:self];
}
-(void)dragTableViewController:(KPReorderTableView *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
    
    [self.itemHandler moveItem:self.dragRow toIndexPath:destinationIndexPath];
    self.tableView.allowsMultipleSelection = YES;
    [self parent].lock = NO;
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
-(void)setIsShowingItem:(BOOL)isShowingItem{
    [super setIsShowingItem:isShowingItem];
    [self.tableView setReorderingEnabled:!isShowingItem];
}
#pragma mark - UIViewControllerClasses
- (void)viewDidLoad
{
    self.state = @"today";
    [super viewDidLoad];
    
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
