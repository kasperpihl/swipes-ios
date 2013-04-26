//
//  ToDoListTableViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoListViewController.h"
#import "KPSegmentedViewController.h"
#import "UtilityClass.h"
#import "ToDoHandler.h"
#import "SchedulePopup.h"
#define TABLEVIEW_TAG 500
@interface ToDoListViewController ()<MCSwipeTableViewCellDelegate,ATSDragToReorderTableViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>
@property (nonatomic,strong) KPToDo *draggingObject;
@property (nonatomic,strong) MCSwipeTableViewCell *swipingCell;
@property (nonatomic,strong) NSIndexPath *dragRow;
@property (nonatomic) CellType cellType;
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic) BOOL isScrollingFast;
@property (nonatomic,strong) NSMutableDictionary *stateDictionary;
@end

@implementation ToDoListViewController
-(KPSegmentedViewController *)parent{
    KPSegmentedViewController *parent = (KPSegmentedViewController*)[self parentViewController];
    return parent;
}
-(NSMutableDictionary *)stateDictionary{
    if(!_stateDictionary) _stateDictionary = [NSMutableDictionary dictionary];
    return _stateDictionary;
}
-(CellType)determineCellTypeFromState:(NSString*)state{
    CellType cellType;
    if([state isEqualToString:@"today"]) cellType = CellTypeToday;
    else if([state isEqualToString:@"schedule"]) cellType = CellTypeSchedule;
    else cellType = CellTypeDone;
    return cellType;
}
-(void)setState:(NSString *)state{
    _state = state;
    self.cellType = [self determineCellTypeFromState:state];
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

#pragma mark - Dragable Controller
- (void)dragTableViewController:(KPReorderTableView *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
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
    self.isScrollingFast = NO;
}


#pragma mark - TableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return self.items.count; }
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*if(self.selectedRow == indexPath.row+1) return 120;
    else*/ return 60;
}

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
	ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self readyCell:cell];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	return cell;
}
-(ToDoCell*)readyCell:(ToDoCell*)cell{
    [cell setMode:MCSwipeTableViewCellModeExit];
    cell.delegate = self;
    cell.cellType = self.cellType;
    cell.selectedBackgroundView.backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CellType firstCell = [TODOHANDLER cellTypeForCell:self.cellType state:MCSwipeTableViewCellState1];
    CellType secondCell = [TODOHANDLER cellTypeForCell:self.cellType state:MCSwipeTableViewCellState2];
    CellType thirdCell = [TODOHANDLER cellTypeForCell:self.cellType state:MCSwipeTableViewCellState3];
    CellType fourthCell = [TODOHANDLER cellTypeForCell:self.cellType state:MCSwipeTableViewCellState4];
    [cell setFirstColor:[TODOHANDLER colorForCellType:firstCell]];
    [cell setSecondColor:[TODOHANDLER colorForCellType:secondCell]];
    [cell setThirdColor:[TODOHANDLER colorForCellType:thirdCell]];
    [cell setFourthColor:[TODOHANDLER colorForCellType:fourthCell]];
    [cell setFirstIconName:[TODOHANDLER iconNameForCellType:firstCell]];
    [cell setSecondIconName:[TODOHANDLER iconNameForCellType:secondCell]];
    [cell setThirdIconName:[TODOHANDLER iconNameForCellType:thirdCell]];
    [cell setFourthIconName:[TODOHANDLER iconNameForCellType:fourthCell]];
    cell.activatedDirection = [TODOHANDLER directionForCellType:self.cellType];
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@cell",self.state];
    ToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
-(void)tableView:(UITableView *)tableView willDisplayCell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self cell:(ToDoCell*)cell forRowAtIndexPath:indexPath];
    KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = toDo.title;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.selectedRows removeObject:indexPath];
    if(self.selectedRows.count == 0) [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self.selectedRows containsObject:indexPath]) [self.selectedRows addObject:indexPath];
    //ToDoCell *cell = (ToDoCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [self parent].currentState = KPControlCurrentStateEdit;
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


-(void)deselectAllRows:(id)sender{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.selectedRows removeAllObjects];
}
#pragma mark - ScrollViewDelegate
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
-(void)setIsScrollingFast:(BOOL)isScrollingFast{
    if(_isScrollingFast != isScrollingFast){
        _isScrollingFast = isScrollingFast;
        [[self parent] show:!isScrollingFast controlsAnimated:YES];
    }
}
#pragma mark - SwipeTableCell
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
    if(cell != self.swipingCell) return;
    NSArray *visibleCells = [self.tableView visibleCells];
    for(MCSwipeTableViewCell *localCell in visibleCells){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if(localCell != cell && [self.selectedRows containsObject:indexPath]){
            [localCell publicHandlePanGestureRecognizer:gesture withTranslation:translation];
        }
    }
}
-(void)bounceSelectedToOrigin{
    NSArray *visibleCells = [self.tableView visibleCells];
    for(MCSwipeTableViewCell *localCell in visibleCells){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if([self.selectedRows containsObject:indexPath]){
            [localCell bounceToOrigin];
        }
    }
}
-(void)moveSelectedCellsToCellType:(CellType)cellType{
    NSString *newState = [TODOHANDLER stateForCellType:cellType];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for(NSIndexPath *indexPath in self.selectedRows){
        KPToDo *toDo = [self.items objectAtIndex:indexPath.row];
        [toDo changeState:newState];
        [indexSet addIndex:indexPath.row];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    if(self.cellType != cellType){
        [self.items removeObjectsAtIndexes:indexSet];
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
        [self.selectedRows removeAllObjects];
    }
    else{
        [self bounceSelectedToOrigin];
        [self deselectAllRows:self];
    
    }
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
    [[self parent] highlightButton:(KPSegmentButtons)cellType-1];
}
-(void)swipeTableViewCell:(ToDoCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    NSLog(@"cell:%@ self.cell:%@",cell,self.swipingCell);
    if(cell != self.swipingCell) return;
    if(state != MCSwipeTableViewCellStateNone){
        CellType targetCellType = [TODOHANDLER cellTypeForCell:cell.cellType state:state];
        if(targetCellType == CellTypeSchedule){
            [SchedulePopup showInView:self.navigationController.view withBlock:^(KPScheduleButtons button, NSDate *date) {
                if(button == KPScheduleButtonCancel){
                    [self bounceSelectedToOrigin];
                    
                }
                else [self moveSelectedCellsToCellType:targetCellType];
            }];
            return;
        }
        else [self moveSelectedCellsToCellType:targetCellType];
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
#pragma mark - UIViewController stuff
- (void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updated", update);
    KPReorderTableView *tableView = [[KPReorderTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.indicatorDelegate = self;
    tableView.tag = TABLEVIEW_TAG;
    [self.view addSubview:tableView];
    self.tableView = (KPReorderTableView*)[self.view viewWithTag:TABLEVIEW_TAG];
    self.tableView.dragDelegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0];
    [self.tableView setTableFooterView:[UIView new]];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
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
