//
//  ToDoListTableViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoListTableViewController.h"
#import "KPSegmentedViewController.h"
#import "UtilityClass.h"
@interface ToDoListTableViewController ()<MCSwipeTableViewCellDelegate,ATSDragToReorderTableViewControllerDelegate>
@property (nonatomic,strong) KPToDo *draggingObject;
@property (nonatomic,strong) MCSwipeTableViewCell *swipingCell;
@property (nonatomic,strong) NSIndexPath *dragRow;
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic) BOOL isScrollingFast;
@end

@implementation ToDoListTableViewController
-(KPSegmentedViewController *)parent{
    KPSegmentedViewController *parent = (KPSegmentedViewController*)[self parentViewController];
    return parent;
}
-(void)loadItems{
    self.items = [[KPToDo MR_findByAttribute:@"state" withValue:self.state andOrderBy:@"order" ascending:NO] mutableCopy];
}
-(void)update{
    [self loadItems];
    [self.tableView reloadData];
}
-(NSMutableArray *)selectedRows{
    if(!_selectedRows) _selectedRows = [NSMutableArray array];
    return _selectedRows;
}
-(NSMutableArray *)items{
    if(!_items){
        _items = [NSMutableArray array];
    }
    return _items;
}
- (UITableViewCell *)cell:(ToDoCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath{ return cell; }
-(NSString*)stateForTriggerState:(MCSwipeTableViewCellState)state{ return nil; }

-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode{
    [[self parent] show:NO controlsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.swipingCell = cell;
    if(![self.selectedRows containsObject:indexPath]) [self.selectedRows addObject:indexPath];
    if(self.selectedRows.count > 0){
        NSArray *visibleCells = [self.tableView visibleCells];
        for(MCSwipeTableViewCell *localCell in visibleCells){
            if(localCell.isSelected){
                [localCell setSelected:NO];
            }
        }
    }
}
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didHandleGestureRecognizer:(UIPanGestureRecognizer *)gesture withTranslation:(CGPoint)translation{
    NSArray *visibleCells = [self.tableView visibleCells];
    for(MCSwipeTableViewCell *localCell in visibleCells){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if(localCell != cell && [self.selectedRows containsObject:indexPath]){
            [localCell publicHandlePanGestureRecognizer:gesture withTranslation:translation];
        }
    }
}
-(void)deselectAllRows:(id)sender{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.selectedRows removeAllObjects];
}
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    if(cell != self.swipingCell) return;
    if(state != MCSwipeTableViewCellStateNone){
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for(NSIndexPath *indexPath in self.selectedRows){
            KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
            NSString *newState = [self stateForTriggerState:state];
            [toDo changeState:newState];
            [indexSet addIndex:indexPath.row];
        }
        [self.items removeObjectsAtIndexes:indexSet];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
        [self.selectedRows removeAllObjects];
        [[self parent] setCurrentState:KPControlCurrentStateAdd];
    }
    else{
        NSArray *visibleCells = [self.tableView visibleCells];
        NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        if(self.selectedRows.count > 1){
            //if(!swipingCellWasSelected)
            for(MCSwipeTableViewCell *localCell in visibleCells){
                NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
                if([self.selectedRows containsObject:indexPath]){
                    [localCell setSelected:YES];
                    if(![selectedIndexPaths containsObject:indexPath]) [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
        else{
            NSIndexPath *indexPathForCell = [self.tableView indexPathForCell:cell];
            if([selectedIndexPaths containsObject:indexPathForCell]) [cell setSelected:YES];
            else{ [self.selectedRows removeAllObjects]; }
        }
        
    }
    [[self parent] show:YES controlsAnimated:YES];
    self.swipingCell = nil;
}
#pragma mark - Dragable Controller
- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
    self.isScrollingFast = YES;
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
-(void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
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
    self.isScrollingFast = NO;
}


#pragma mark - TableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return self.items.count; }
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*if(self.selectedRow == indexPath.row+1) return 120;
    else*/ return 60;
}

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self readyCell:cell];
	return [self cell:cell forRowAtIndexPath:indexPath];
}
-(ToDoCell*)readyCell:(ToDoCell*)cell{
    [cell setMode:MCSwipeTableViewCellModeExit];
    cell.delegate = self;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SwipeCell";
    ToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [self readyCell:cell];
    }    
	return cell;
}
-(void)deleteSelectedItems:(id)sender{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
        [toDo MR_deleteInContext:[NSManagedObjectContext MR_defaultContext]];
        [indexSet addIndex:indexPath.row];
    }
    [self.items removeObjectsAtIndexes:indexSet];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.selectedRows removeAllObjects];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self cell:(ToDoCell*)cell forRowAtIndexPath:indexPath];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did deselect");
    [self.selectedRows removeObject:indexPath];
    if(self.selectedRows.count == 0) [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MCSwipeTableViewCell *cell = (MCSwipeTableViewCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    if(![self.selectedRows containsObject:indexPath]) [self.selectedRows addObject:indexPath];
    [self parent].currentState = KPControlCurrentStateEdit;
    //[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    /*self.selectedRow = indexPath.row+1;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];*/
    
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)doubleTap:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:p];
        ToDoCell* cell = (ToDoCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.tag = 1336;
        NSLog(@"doubletap");
        // Do your stuff
    }
}
#pragma mark - UI Specific
- (void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updated", update);
    self.dragDelegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0];
    [self.tableView setTableFooterView:[UIView new]];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
}
-(void)setIsScrollingFast:(BOOL)isScrollingFast{
    if(_isScrollingFast != isScrollingFast){
        _isScrollingFast = isScrollingFast;
        [[self parent] show:!isScrollingFast controlsAnimated:YES];
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
        if (scrollSpeedNotAbs > 0.5 && currentOffset.y > 0) {
            self.isScrollingFast = YES;
        }
        else if(distance < -10.0 && (currentOffset.y+self.tableView.frame.size.height) < self.tableView.contentSize.height){
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
-(void)dealloc{
    clearNotify();
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.selectedRows removeAllObjects];
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
