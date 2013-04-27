//
//  ToDoListTableViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoListViewController.h"

#import "UtilityClass.h"
#import "ToDoHandler.h"
#import "SchedulePopup.h"

#define TABLEVIEW_TAG 500
@interface ToDoListViewController ()<MCSwipeTableViewCellDelegate>

@property (nonatomic,strong) MCSwipeTableViewCell *swipingCell;

@property (nonatomic) CellType cellType;
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;

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
-(void)sortItems{
    
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

-(void)addItem:(KPToDo*)toDo toTitle:(NSString*)title{
    NSMutableArray *arrayOfItems = [self.sortedItems objectForKey:title];
    if(!arrayOfItems){
        [self.sortedItems setObject:[NSMutableArray array] forKey:title];
        arrayOfItems = [self.sortedItems objectForKey:title];
    }
    [arrayOfItems addObject:toDo];
}

#pragma mark - Dragable Controller

#pragma mark - TableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.sortedItems){
        NSString *sectionIndex = [[self.sortedItems allKeys] objectAtIndex:section];
        NSArray *itemsForSection = [self.sortedItems objectForKey:sectionIndex];
        return itemsForSection.count;
    }
    return self.items.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.sortedItems) return [[self.sortedItems allKeys] objectAtIndex:section];
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.sortedItems) return [self.sortedItems count];
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*if(self.selectedRow == indexPath.row+1) return 120;
    else*/ return 85;
}
-(ToDoCell*)readyCell:(ToDoCell*)cell{
    [cell setMode:MCSwipeTableViewCellModeExit];
    cell.delegate = self;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        KPToDo *toDo = [self itemForIndexPath:indexPath];
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
    cell.cellType = self.cellType;
    KPToDo *toDo = [self itemForIndexPath:indexPath];
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
    }
}
#pragma mark - UI Specific



#pragma mark - ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.tableView.frame.size.height - 150 >= self.tableView.contentSize.height) return;
    CGPoint currentOffset = self.tableView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - self.lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        if (scrollSpeedNotAbs > 0.5 && currentOffset.y > 0) {
            [[self parent] show:NO controlsAnimated:YES];
        }
        else if(distance < -10.0 && (currentOffset.y+self.tableView.frame.size.height) < self.tableView.contentSize.height){
            [[self parent] show:YES controlsAnimated:YES];
        }
        
        self.lastOffset = currentOffset;
        self.lastOffsetCapture = currentTime;
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
-(void)swipeTableViewCell:(ToDoCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    if(cell != self.swipingCell) return;
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *toDosArray = [NSMutableArray array];
    for(NSIndexPath *indexPath in self.selectedRows){
        KPToDo *toDo = [self itemForIndexPath:indexPath];
        [toDosArray addObject:toDo];
        [indexSet addIndex:indexPath.row];
    }
    CellType targetCellType = [TODOHANDLER cellTypeForCell:cell.cellType state:state];
    switch (targetCellType) {
        case CellTypeSchedule:{
            [SchedulePopup showInView:self.navigationController.view withBlock:^(KPScheduleButtons button, NSDate *date) {
                if(button == KPScheduleButtonCancel){
                    [self returnSelectedRowsAndBounce:YES];
                }
                else{
                    [TODOHANDLER scheduleToDos:toDosArray forDate:date];
                    [self moveIndexSet:indexSet toCellType:targetCellType];
                }
            }];
            return;
        }
        case CellTypeToday:
            [TODOHANDLER setForTodayToDos:toDosArray];
            break;
        case CellTypeDone:
            [TODOHANDLER completeToDos:toDosArray];
            break;
        case CellTypeNone:
            [self returnSelectedRowsAndBounce:NO];
            return;
    }
    [self moveIndexSet:indexSet toCellType:targetCellType];
    
    
    
}
/*
 
*/
-(void)removeItemsForIndexSet:(NSIndexSet*)indexSet{
    if(self.sortedItems){
        NSArray *oldKeys = [self.sortedItems allKeys];
        [self loadItems];
        NSArray *newKeys = [self.sortedItems allKeys];
        NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
        for(int i = 0 ; i < oldKeys.count ; i++){
            NSString *oldKey = [oldKeys objectAtIndex:i];
            if(![newKeys containsObject:oldKey]) [deletedSections addIndex:i];
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
        if(deletedSections.count > 0) [self.tableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else{
        [self.items removeObjectsAtIndexes:indexSet];
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.selectedRows removeAllObjects];
    
}
-(KPToDo *)itemForIndexPath:(NSIndexPath *)indexPath{
    if(self.sortedItems){
        NSString *sectionIndex = [[self.sortedItems allKeys] objectAtIndex:indexPath.section];
        KPToDo *toDo = [[self.sortedItems objectForKey:sectionIndex] objectAtIndex:indexPath.row];
        return toDo;
    }
    return [self.items objectAtIndex:indexPath.row];
}
-(void)moveIndexSet:(NSIndexSet*)indexSet toCellType:(CellType)cellType{
    if(self.cellType != cellType){
        [self removeItemsForIndexSet:indexSet];
    }
    else{
        [self returnSelectedRowsAndBounce:YES];
        [self deselectAllRows:self];
    }
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
    [[self parent] highlightButton:(KPSegmentButtons)cellType-1];
    [[self parent] show:YES controlsAnimated:YES];
    self.swipingCell = nil;
}
-(void)deselectAllRows:(id)sender{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.selectedRows removeAllObjects];
}
-(void)returnSelectedRowsAndBounce:(BOOL)bounce{
    NSArray *visibleCells = [self.tableView visibleCells];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    BOOL shouldBeSelected = (selectedIndexPaths.count > 0);
    for(MCSwipeTableViewCell *localCell in visibleCells){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if([self.selectedRows containsObject:indexPath]){
            if(bounce) [localCell bounceToOrigin];
            if(shouldBeSelected)[localCell setSelected:YES];
            if(![selectedIndexPaths containsObject:indexPath] && shouldBeSelected) [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    if(!shouldBeSelected) [self.selectedRows removeAllObjects];
    self.swipingCell = nil;
    [[self parent] show:YES controlsAnimated:YES];
}

-(void)prepareTableView:(UITableView *)tableView{
    tableView.allowsMultipleSelection = YES;
    tableView.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0];
    [tableView setTableFooterView:[UIView new]];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [tableView addGestureRecognizer:doubleTap];
    
}
#pragma mark - UIViewController stuff
- (void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updated", update);
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.tag = TABLEVIEW_TAG;
    [self prepareTableView:tableView];
    [self.view addSubview:tableView];
    self.tableView = (UITableView*)[self.view viewWithTag:TABLEVIEW_TAG];
    
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
