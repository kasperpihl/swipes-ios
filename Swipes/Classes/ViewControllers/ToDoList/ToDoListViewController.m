//
//  ToDoListTableViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoListViewController.h"

#import "UtilityClass.h"
#import "ToDoHandler.h"
#import "SchedulePopup.h"
#import "KPSearchBar.h"
#import <QuartzCore/QuartzCore.h>
#import "ToDoViewController.h"

#import "SectionHeaderView.h"
#import "KPBlurry.h"
#import "AnalyticsHandler.h"
#define TABLEVIEW_TAG 500
#define BACKGROUND_IMAGE_VIEW_TAG 504
#define BACKGROUND_LABEL_VIEW_TAG 502
#define SEARCH_BAR_TAG 503
#define FAKE_HEADER_VIEW_TAG 505
#define MENU_TEXT_TAG 506
#define COLORED_MENU_TEXT_TAG 507


#define SECTION_HEADER_HEIGHT 6
#define SECTION_EXTRA_DELTA_Y -3
#define SECTION_HEADER_X 15
#define CONTENT_INSET_BOTTOM 5// 100
@interface ToDoListViewController ()<MCSwipeTableViewCellDelegate,KPSearchBarDelegate,KPSearchBarDelegate,ToDoVCDelegate>

@property (nonatomic,strong) MCSwipeTableViewCell *swipingCell;

@property (nonatomic,strong) ToDoViewController *showingViewController;
@property (nonatomic) CGPoint savedContentOffset;
@property (nonatomic) CellType cellType;
@property (nonatomic,strong) KPSearchBar *searchBar;
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic,weak) IBOutlet UIView *menuText;
@property (nonatomic,weak) UIView *fakeHeaderView;
@property (nonatomic) BOOL isColored;
@property (nonatomic) BOOL isHandlingTrigger;
@property (nonatomic) BOOL isLonelyRider;

@property (nonatomic,strong) NSMutableDictionary *stateDictionary;
@end

@implementation ToDoListViewController
@synthesize showingViewController = _showingViewController;
-(ItemHandler *)itemHandler{
    if(!_itemHandler){
        _itemHandler = [[ItemHandler alloc] init];
        _itemHandler.delegate = self;
    }
    return _itemHandler;
}
-(ToDoViewController *)showingViewController{
    if(!_showingViewController){
        _showingViewController = [[ToDoViewController alloc] init];
        _showingViewController.delegate = self;
        _showingViewController.segmentedViewController = [self parent];
        _showingViewController.view.frame = CGRectMake(0, 0, 320, self.tableView.frame.size.height-SECTION_HEADER_HEIGHT);
    }
    return _showingViewController;
    
    
}
#pragma mark ItemHandlerDelegate
-(void)itemHandler:(ItemHandler *)handler changedItemNumber:(NSInteger)itemNumber{
    [self didUpdateCells];
}
-(void)setIsShowingItem:(BOOL)isShowingItem{
    
    self.tableView.scrollEnabled = !isShowingItem;
    if(isShowingItem){
        [[self parent] setLock:isShowingItem animated:NO];
        [self selectShowingItem];
    }
    else if (_isShowingItem != isShowingItem){
        [[self parent] setLock:NO];
        [self.showingViewController.view removeFromSuperview];
    }
    _isShowingItem = isShowingItem;
}
-(void)selectShowingItem{
    NSIndexPath *indexPath = [self.itemHandler indexPathForItem:self.parent.showingModel];
    if(!indexPath) return;
    [self deselectAllRows:self];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.selectedRows addObject:indexPath];
}
-(void)didUpdateItemHandler:(ItemHandler *)handler{
    if(self.parent.showingModel && [self.itemHandler.filteredItems containsObject:self.parent.showingModel]){
        [self deselectAllRows:self];
        self.isShowingItem = YES;
    }else self.isShowingItem = NO;
    if(self.parent.showingModel && !self.isShowingItem && [self.itemHandler.items containsObject:self.parent.showingModel]) self.parent.showingModel = nil;
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.isShowingItem){
            [self selectShowingItem];
            NSIndexPath *cellIndexPath = [self.itemHandler indexPathForItem:self.parent.showingModel];
            NSInteger numberOfCellsBefore = [self.itemHandler totalNumberOfItemsBeforeItem:self.parent.showingModel];
            NSInteger numberOfSections = cellIndexPath.section;
            CGFloat contentY = self.tableView.tableHeaderView.frame.size.height + numberOfCellsBefore * CELL_HEIGHT + numberOfSections * SECTION_HEADER_HEIGHT;
            [self.tableView setContentOffset:CGPointMake(0,contentY) animated:NO];
        }
    });
}
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
-(void)update{
    [self.itemHandler reloadData];
}
-(void)didUpdateCells{
    [self.searchBar reloadDataAndUpdate:YES];
    
}
-(NSMutableArray *)selectedRows{
    if(!_selectedRows) _selectedRows = [NSMutableArray array];
    return _selectedRows;
}

#pragma mark - KPSearchBarDelegate
-(void)searchBar:(KPSearchBar *)searchBar searchedForString:(NSString *)searchString{
    [self.itemHandler searchForString:searchString];
    [self deselectAllRows:self];
}
-(void)searchBar:(KPSearchBar *)searchBar deselectedTag:(NSString *)tag{
    [self.itemHandler deselectTag:tag];
    [self deselectAllRows:self];
}
-(void)searchBar:(KPSearchBar *)searchBar selectedTag:(NSString *)tag{
    [self.itemHandler selectTag:tag];
    [self deselectAllRows:self];
}
-(void)clearedAllFiltersForSearchBar:(KPSearchBar *)searchBar{
    self.searchBar.currentMode = KPSearchBarModeNone;
    [self.itemHandler clearAll];
    [self deselectAllRows:self];
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(!self.itemHandler.isSorted && self.itemHandler.itemCounterWithFilter == 0) return 0;
    return SECTION_HEADER_HEIGHT;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIColor *backgroundColor = [TODOHANDLER colorForCellType:self.cellType];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_HEADER_HEIGHT)];
    UIFont *font = KP_SEMIBOLD(15);
    NSString *title = [[self.itemHandler titleForSection:section] capitalizedString];
    headerView.backgroundColor = backgroundColor;
    SectionHeaderView *extraView = [[SectionHeaderView alloc] initWithColor:[TODOHANDLER colorForCellType:self.cellType] font:font title:title];
    if(self.cellType == CellTypeToday) extraView.textColor = color(44,50, 59, 1);
    CGRectSetX(extraView, 320-extraView.frame.size.width);
    [headerView addSubview:extraView];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.parent.showingModel && [[self.itemHandler itemForIndexPath:indexPath] isEqual:self.parent.showingModel]){
        return self.tableView.frame.size.height-SECTION_HEADER_HEIGHT;
    }
    else{
        return CELL_HEIGHT;
    }
}
-(ToDoCell*)readyCell:(ToDoCell*)cell{
    [cell setMode:MCSwipeTableViewCellModeExit];
    cell.delegate = self;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@cell",self.state];
    ToDoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell = [self readyCell:cell];
    }
	return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self cell:(ToDoCell*)cell forRowAtIndexPath:indexPath];
    KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
    cell.cellType = [toDo cellTypeForTodo];
    [cell showTimeline:YES];
    [cell setDotColor:self.cellType];
    [cell changeToDo:toDo withSelectedTags:self.itemHandler.selectedTags];
    if([toDo isEqual:self.parent.showingModel]){
        self.showingViewController.model = toDo;
        [self.showingViewController injectInCell:cell];
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.selectedRows removeObject:indexPath];
    if(self.selectedRows.count == 0) [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self.selectedRows containsObject:indexPath]) [self.selectedRows addObject:indexPath];
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
        if(!indexPath) return;
        if(self.parent.showingModel && [[self.itemHandler itemForIndexPath:indexPath] isEqual:self.parent.showingModel]) [self didPressCloseToDoViewController:self.showingViewController];
        else [self editIndexPath:indexPath];
    }
}
-(void)editIndexPath:(NSIndexPath *)indexPath{
    
    KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
    self.parent.showingModel = toDo;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self deselectAllRows:self];
    self.isShowingItem = YES;
    
    ToDoCell *cell = (ToDoCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y-SECTION_HEADER_HEIGHT) animated:YES];
    self.savedContentOffset = self.tableView.contentOffset;
    
}
-(void)pressedEdit{
    NSIndexPath *indexPath;
    if(self.selectedRows.count > 0) indexPath = [self.selectedRows lastObject];
    if(indexPath) [self editIndexPath:indexPath];
}
-(void)didPressCloseToDoViewController:(ToDoViewController *)viewController{
    
    NSIndexPath *indexPath = [self.itemHandler indexPathForItem:self.parent.showingModel];
    self.parent.showingModel = nil;
    [self deselectAllRows:self];
    self.isShowingItem = NO;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if(!CGPointEqualToPoint(self.savedContentOffset,CGPointZero)){
        [self.tableView setContentOffset:self.savedContentOffset animated:YES];
        self.savedContentOffset = CGPointZero;
    }
    [[self parent] show:YES controlsAnimated:YES];
}
-(void)scheduleToDoViewController:(ToDoViewController *)viewController{
    SchedulePopup *popup = [SchedulePopup popupWithFrame:self.parent.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate) {
        [BLURRY dismissAnimated:YES];
        if(button != KPScheduleButtonCancel){
            if(!self.parent.showingModel) return;
            [TODOHANDLER scheduleToDos:@[self.parent.showingModel] forDate:chosenDate];
            if(self.cellType == CellTypeSchedule){
                NSLog(@"cell type was schedule");
                [self.showingViewController update];
                [self update];
            }
            else{
                [self.parent changeToIndex:0];
            }
        }
    }];
    BLURRY.blurLevel = 1.0f;
    [BLURRY showView:popup inViewController:self.parent];
}
#pragma mark - UI Specific
-(NSArray *)selectedItems{
    if(self.isShowingItem) return @[self.parent.showingModel];
    NSMutableArray *array = [NSMutableArray array];
    for(NSIndexPath *indexPath in self.selectedRows){
        KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
        [array addObject:toDo];
    }
    return array;
}


#pragma mark - ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint currentOffset = self.tableView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - self.lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        if (scrollSpeedNotAbs > 0.5 && currentOffset.y > 0) {
            if(self.searchBar.currentMode == KPSearchBarModeSearch) [self.searchBar resignSearchField];
            [[self parent] show:NO controlsAnimated:YES];
        }
        else if(scrollSpeedNotAbs < -0.5){
            if((self.tableView.frame.size.height > self.tableView.contentSize.height && currentOffset.y < 0) || (currentOffset.y+self.tableView.frame.size.height) < self.tableView.contentSize.height+CONTENT_INSET_BOTTOM) [[self parent] show:YES controlsAnimated:YES];
        }
        self.lastOffset = currentOffset;
        self.lastOffsetCapture = currentTime;
    }
    if (scrollView == self.tableView) { // Don't do anything if the search table view get's scrolled
        if (scrollView.contentOffset.y < self.searchBar.frame.size.height) {
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds) - MAX(scrollView.contentOffset.y, 0), 0, 0, 0);
        } else {
            
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        if(scrollView.contentOffset.y <= 0){
            CGRectSetHeight(self.searchBar, self.tableView.tableHeaderView.frame.size.height-scrollView.contentOffset.y);
            CGRect searchBarFrame = self.searchBar.frame;
            searchBarFrame.origin.y = scrollView.contentOffset.y;
            self.searchBar.frame = searchBarFrame;
        }
    }
}

#pragma mark - SwipeTableCell
-(void)swipeTableViewCell:(ToDoCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode{
    [[self parent] show:NO controlsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.swipingCell = cell;
    if(self.selectedRows.count > 0){
        if(indexPath && ![self.selectedRows containsObject:indexPath]){
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectedRows addObject:indexPath];
        }
    }
    else{
        self.isLonelyRider = YES;
        [self.selectedRows addObject:indexPath];
    }
}
-(BOOL)swipeTableViewCell:(MCSwipeTableViewCell *)cell shouldHandleGestureRecognizer:(UIPanGestureRecognizer *)gesture{
    if(self.swipingCell && cell != self.swipingCell) return NO;
    else return YES;
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
    if(self.isHandlingTrigger) return;
    self.isHandlingTrigger = YES;
    NSArray *toDosArray = [self selectedItems];
    NSArray *movedItems;
    __block CellType targetCellType = [TODOHANDLER cellTypeForCell:cell.cellType state:state];
    switch (targetCellType) {
        case CellTypeSchedule:{
            //SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
            SchedulePopup *popup = [SchedulePopup popupWithFrame:self.parent.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate) {
                [BLURRY dismissAnimated:YES];
                if(button == KPScheduleButtonCancel){
                    [self returnSelectedRowsAndBounce:YES];
                }
                else{
                    if([chosenDate isEarlierThanDate:[NSDate date]]) targetCellType = CellTypeToday;
                    NSArray *movedItems = [TODOHANDLER scheduleToDos:toDosArray forDate:chosenDate];
                    [self moveItems:movedItems toCellType:targetCellType];
                }
                self.isHandlingTrigger = NO;
            }];
            BLURRY.blurLevel = 1.0f;
            [BLURRY showView:popup inViewController:self.parent];
            return;
        }
        case CellTypeToday:
            movedItems = [TODOHANDLER scheduleToDos:toDosArray forDate:[NSDate date]];
            break;
        case CellTypeDone:
            movedItems = [TODOHANDLER completeToDos:toDosArray];
            NSLog(@"total: %i movedItemsCount:%i",toDosArray.count,movedItems.count);
            break;
        case CellTypeNone:
            [self returnSelectedRowsAndBounce:NO];
            self.isHandlingTrigger = NO;
            return;
    }
    [self moveItems:movedItems toCellType:targetCellType];
    self.isHandlingTrigger = NO;
}
-(void)swipeTableViewCell:(ToDoCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state{
    CellType targetType = self.cellType;
    if(state != MCSwipeTableViewCellStateNone){
        targetType = [TODOHANDLER cellTypeForCell:self.cellType state:state];
    }
    [cell setDotColor:targetType];
}
/*  */
-(void)deleteSelectedItems:(id)sender{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSLog(@"indexPaths: %@",selectedIndexPaths);
    NSMutableArray *toDos = [NSMutableArray array];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        [toDos addObject:[self.itemHandler itemForIndexPath:indexPath]];
        [indexSet addIndex:indexPath.row];
    }
    [TODOHANDLER deleteToDos:toDos save:YES];
    [self removeItems:[self selectedItems]];
}
-(void)removeItems:(NSArray*)items{
    [self runBeforeMoving];
    //if(items.count == 0) return;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for(KPToDo *toDo in items){
        NSIndexPath *toDoIP = [self.itemHandler indexPathForItem:toDo];
        if(toDoIP) [indexPaths addObject:toDoIP];
    }
    NSIndexSet *deletedSections = [self.itemHandler removeItems:items];
    NSLog(@"selected: %i items: %i indexPaths: %i",self.selectedRows.count,items.count,indexPaths.count);
    if(self.selectedRows.count != indexPaths.count){
        if(self.isShowingItem) self.parent.showingModel = nil;
        [self update];
        [self cleanUpAfterMovingAnimated:YES];
    }
    else{
        [self.tableView beginUpdates];
        //[self.tableView reloadData];
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            [self cleanUpAfterMovingAnimated:YES];
        }];
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
        if(deletedSections && deletedSections.count > 0) [self.tableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [CATransaction commit];
    }
}
-(void)moveItems:(NSArray*)items toCellType:(CellType)cellType{
    [[self parent] highlightButton:(KPSegmentButtons)cellType-1];
    if(self.cellType != cellType){
        [self removeItems:items];
    }
    else{
        [self returnSelectedRowsAndBounce:YES];
        [self deselectAllRows:self];
        [self update];
    }
    
}
-(void)runBeforeMoving{
    if(self.showingViewController){
        //self.showingViewController.injectedIndexPath = nil;
    }
}
-(void)cleanUpAfterMovingAnimated:(BOOL)animated{
    [self.selectedRows removeAllObjects];
    self.isShowingItem = NO;
    self.isLonelyRider = NO;
    self.swipingCell = nil;
    [self didUpdateCells];
    [[self parent] show:YES controlsAnimated:YES];
}
-(void)updateSearchBar{
    
}
-(void)deselectAllRows:(id)sender{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.selectedRows removeAllObjects];
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
-(void)returnSelectedRowsAndBounce:(BOOL)bounce{
    NSArray *visibleCells = [self.tableView visibleCells];
    for(ToDoCell *localCell in visibleCells){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if([self.selectedRows containsObject:indexPath]){
            [localCell setDotColor:self.cellType];
            if(bounce) [localCell bounceToOrigin];
        }
    }
    if(self.isLonelyRider){
        [self.selectedRows removeAllObjects];
        self.isLonelyRider = NO;
    }
    self.swipingCell = nil;
    [[self parent] show:YES controlsAnimated:YES];
}
-(void)prepareTableView:(UITableView *)tableView{
    tableView.allowsMultipleSelection = YES;
    [tableView setTableFooterView:[UIView new]];
    
    tableView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    //tableView.contentInset = UIEdgeInsetsMake(0, 0, CONTENT_INSET_BOTTOM, 0);
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self.itemHandler;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.layer.masksToBounds = NO;
    UIView *headerView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, SEARCH_BAR_DEFAULT_HEIGHT)];
    headerView.hidden = YES;
    tableView.tableHeaderView = headerView;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    tableView.contentInset = UIEdgeInsetsMake(0, 0, GLOBAL_TOOLBAR_HEIGHT, 0);
    KPSearchBar *searchBar = [[KPSearchBar alloc] initWithFrame:CGRectMake(0,0, 320, SEARCH_BAR_DEFAULT_HEIGHT)];
    searchBar.searchBarDelegate = self;
    searchBar.searchBarDataSource = self.itemHandler;
    searchBar.tag = SEARCH_BAR_TAG;
    [tableView addSubview:searchBar];
    self.searchBar = (KPSearchBar*)[tableView viewWithTag:SEARCH_BAR_TAG];
    tableView.contentOffset = CGPointMake(0, CGRectGetHeight(tableView.tableHeaderView.bounds));
    
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [tableView addGestureRecognizer:doubleTap];
}
#pragma mark - UIViewController stuff
-(void)changeToColored:(BOOL)colored{
    if(self.isColored == colored) return;
    self.isColored = colored;
    if(colored){
        self.menuText.alpha = 0;
        self.menuText.hidden = NO;
        [UIView animateWithDuration:1.5 animations:^{
            self.menuText.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
    else{
        self.menuText.hidden = YES;
        self.menuText.alpha = 0;
    }
 
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = tbackground(TaskTableBackground);
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    UIImage *backgroundImage = [UtilityClass radialGradientImage:backgroundView.bounds.size start:tbackground(TaskTableGradientBackground) end:tbackground(TaskTableBackground) centre:CGPointMake(0.5f, 0.25f) radius:1.0f];
    
    
    backgroundView.image = backgroundImage;
    [self.view addSubview:backgroundView];
    // tbackground(TaskTableBackground);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white_background",self.state]]];
    
    imageView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4);
    //imageView.frame = CGRectSetPos(imageView.frame, (self.view.bounds.size.width-imageView.frame.size.width)/2, 80);
    imageView.tag = BACKGROUND_IMAGE_VIEW_TAG;
    [self.view addSubview:imageView];
    self.backgroundImage = (UIImageView*)[self.view viewWithTag:BACKGROUND_IMAGE_VIEW_TAG];
    
    UILabel *menuText = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.center.y+70, self.view.frame.size.width, TABLE_EMPTY_BG_TEXT_HEIGHT)];
    menuText.backgroundColor = CLEAR;
    menuText.font = TABLE_EMPTY_BG_FONT;
    NSString *text;
    switch (self.cellType) {
        case CellTypeDone:
            text = @"Done";
            break;
        case CellTypeSchedule:
            text = @"Later";
            break;
        default:
            text = @"Well Swiped!";
            break;
    }
    menuText.text = text;
    menuText.textAlignment = UITextAlignmentCenter;
    menuText.textColor = tcolor(TaskTableEmptyText);
    menuText.tag = MENU_TEXT_TAG;
    [self.view addSubview:menuText];
    self.menuText = [self.view viewWithTag:MENU_TEXT_TAG];
    

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.tag = TABLEVIEW_TAG;
    [self prepareTableView:tableView];
    [self.view addSubview:tableView];
    self.tableView = (UITableView*)[self.view viewWithTag:TABLEVIEW_TAG];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [self update];
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *activeView;
    switch (self.cellType) {
        case CellTypeDone:
            activeView = @"Done Tab";
            break;
        case CellTypeSchedule:
            activeView = @"Later Tab";
            break;
        default:
            activeView = @"Tasks Tab";
            break;
    }
    [ANALYTICS pushView:activeView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self cleanUpAfterMovingAnimated:NO];
    self.searchBar.currentMode = KPSearchBarModeNone;
    [self.itemHandler clearAll];
}
-(void)dealloc{
    self.searchBar = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
