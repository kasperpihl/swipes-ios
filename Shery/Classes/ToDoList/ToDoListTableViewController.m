//
//  ToDoListTableViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "KPSegmentedViewController.h"
@interface ToDoListTableViewController ()<MCSwipeTableViewCellDelegate,ATSDragToReorderTableViewControllerDelegate>
@property (nonatomic,strong) KPToDo *draggingObject;
@property (nonatomic,strong) NSIndexPath *dragRow;
@property (nonatomic) NSInteger selectedRow;

@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic) BOOL isScrollingFast;
@end

@implementation ToDoListTableViewController
-(void)loadItems{
    self.items = [[KPToDo MR_findByAttribute:@"state" withValue:self.state andOrderBy:@"order" ascending:NO] mutableCopy];
}
-(void)update{
    [self loadItems];
    [self.tableView reloadData];
}
-(NSMutableArray *)items{
    if(!_items){
        _items = [NSMutableArray array];
    }
    return _items;
}
- (UITableViewCell *)cell:(ToDoCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath{ return cell; }
#pragma mark - Dragable Controller
- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
    self.isScrollingFast = YES;
    self.dragRow = dragRow;
    self.draggingObject = [self.items objectAtIndex:dragRow.row];
}
-(void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
    
    NSInteger targetRow;
    self.tableView.allowsMultipleSelection = YES;
    if(destinationIndexPath.row > self.dragRow.row) targetRow = destinationIndexPath.row-1;
    else if(destinationIndexPath.row < self.dragRow.row) targetRow = destinationIndexPath.row+1;
    else targetRow = destinationIndexPath.row;
    KPToDo *replacingToDoObject = [self.items objectAtIndex:targetRow];
    if(targetRow != destinationIndexPath.row){
        [self.draggingObject changeToOrder:replacingToDoObject.orderValue];
        [self update];
    }
    self.draggingObject = nil;
    self.isScrollingFast = NO;
}
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.delegate = self;
    [cell setMode:MCSwipeTableViewCellModeExit];
	return [self cell:cell forRowAtIndexPath:indexPath];
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    KPToDo *itemToMove = [self.items objectAtIndex:sourceIndexPath.row];
	[self.items removeObjectAtIndex:sourceIndexPath.row];
	[self.items insertObject:itemToMove atIndex:destinationIndexPath.row];
}
#pragma mark - TableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return self.items.count; }
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectedRow == indexPath.row+1) return 120;
    else return 60;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selectedRow = indexPath.row+1;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];*/
    
}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UI Specific
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dragDelegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0];
    [self.tableView setTableFooterView:[UIView new]];
}
-(void)setIsScrollingFast:(BOOL)isScrollingFast{
    if(_isScrollingFast != isScrollingFast){
        _isScrollingFast = isScrollingFast;
        KPSegmentedViewController *viewController = (KPSegmentedViewController*)[self parentViewController];
        [viewController show:!isScrollingFast controlsAnimated:YES];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.tableView.frame.size.height >= self.tableView.contentSize.height) return;
    CGPoint currentOffset = self.tableView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - self.lastOffset.y;
        
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        //NSLog(@"distance:%f",currentOffset.y);
        if (scrollSpeedNotAbs > 0.5 && currentOffset.y > 0) {
            self.isScrollingFast = YES;
        }
        else if(scrollSpeedNotAbs < -0.5 && (currentOffset.y+self.tableView.frame.size.height) < self.tableView.contentSize.height){
            if(!self.draggingObject) self.isScrollingFast = NO;
        }
        
        self.lastOffset = currentOffset;
        self.lastOffsetCapture = currentTime;
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self update];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isScrollingFast = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
