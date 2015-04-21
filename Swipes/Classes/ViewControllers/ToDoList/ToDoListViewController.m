//
//  ToDoListTableViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UtilityClass.h"
#import "KPToDo.h"
#import "SchedulePopup.h"
#import "ToDoViewController.h"
#import "SectionHeaderView.h"
#import "KPBlurry.h"
#import "AnalyticsHandler.h"
#import "StyleHandler.h"
#import "KPTagList.h"
#import "UIView+Utilities.h"
#import "HintHandler.h"
#import "RootViewController.h"
#import "SlowHighlightIcon.h"
#import "ToDoListViewController.h"
#import "AudioHandler.h"

#define BACKGROUND_IMAGE_VIEW_TAG 504
#define BACKGROUND_LABEL_VIEW_TAG 502
#define SEARCH_BAR_TAG 503
#define FAKE_HEADER_VIEW_TAG 505
#define MENU_TEXT_TAG 506
#define COLORED_MENU_TEXT_TAG 507


#define SECTION_HEADER_HEIGHT LINE_SIZE
#define SECTION_EXTRA_DELTA_Y -3
#define SECTION_HEADER_X 15
#define CONTENT_INSET_BOTTOM 5// 100
@interface ToDoListViewController ()<MCSwipeTableViewCellDelegate,ToDoVCDelegate, ToDoCellDelegate>

@property (nonatomic,strong) MCSwipeTableViewCell *swipingCell;

@property (nonatomic, strong) ToDoViewController *showingViewController;
@property (nonatomic) CGPoint savedContentOffset;
@property (nonatomic) CellType cellType;
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic, weak) UIView *menuText;
@property (nonatomic, weak) UIView *fakeHeaderView;
@property (nonatomic) BOOL isColored;
@property (nonatomic) BOOL isHandlingTrigger;
@property (nonatomic) BOOL savedOffset;
@property (nonatomic) BOOL badState;
@property (nonatomic) BOOL hasStartedEditing;
@property (nonatomic) BOOL needUpdate;
@property double lastCompletionTime;
@property NSInteger numberOfCompletions;

@property (nonatomic,strong) NSMutableDictionary *stateDictionary;
@end

@implementation ToDoListViewController

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
        _showingViewController.view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - SECTION_HEADER_HEIGHT);
    }
    return _showingViewController;
}
-(void)setSelectionMode:(BOOL)selectionMode{
    if(!selectionMode)
        [self deselectAllRows:self];
    _selectionMode = selectionMode;
}

#pragma mark - ItemHandlerDelegate

- (void)itemHandler:(ItemHandler *)handler changedItemNumber:(NSInteger)itemNumber oldNumber:(NSInteger)oldNumber {
    //[self didUpdateCells];
    [self showBackgroundItems:(itemNumber == 0)];
}

- (void)showBackgroundItems:(BOOL)show {
    self.menuText.hidden = !show;
    self.backgroundIcon.hidden = !show;
}

- (void)didUpdateItemHandler:(ItemHandler *)handler {
    [self willUpdateCells];
    NSArray *selectedItems = [self selectedItems];
    [self.selectedRows removeAllObjects];
    [self.tableView reloadData];
    for(KPToDo *item in selectedItems){
        NSIndexPath *indexPath = [handler indexPathForItem:item];
        if(indexPath){
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectedRows addObject:indexPath];
        }
    }
    [self updateTableFooter];
    [self didUpdateCells];
}

-(void)updateTableFooter{
    if(!kFilter.isActive){
        [self.tableView setTableFooterView:[UIView new]];
    }
    else{
        UIView *filterBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 500)];
        filterBottomView.userInteractionEnabled = YES;
        filterBottomView.backgroundColor = alpha(tcolor(BackgroundColor),0.7);
        
        UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.tableView.frame.size.width-30, 500)];
        filterLabel.backgroundColor = CLEAR;
        NSString *category = LOCALIZE_STRING(@"current");
        if([self.state isEqualToString:@"done"])
            category = LOCALIZE_STRING(@"completed");
        else if([self.state isEqualToString:@"schedule"])
            category = LOCALIZE_STRING(@"scheduled");
        
        filterLabel.attributedText = [kFilter readableFilterWithResults:self.itemHandler.itemCounterWithFilter forCategory:category];
        //[filterLabel setTextColor:tcolor(TextColor)];
        //filterLabel.font = KP_REGULAR(16);
        //filterLabel.textAlignment = NSTextAlignmentCenter;
        filterLabel.numberOfLines = 0;
        filterLabel.alpha = 0.7;
        [filterLabel sizeToFit];
        CGRectSetCenterX(filterLabel, filterBottomView.frame.size.width/2);
        //CGRectSetHeight(filterLabel, filterLabel.frame.size.height);
        [filterBottomView addSubview:filterLabel];
        
        UIButton *clearButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
        clearButton.backgroundColor = CLEAR;
        NSString *str = LOCALIZE_STRING(@"clear workspace");
        clearButton.titleLabel.font = KP_REGULAR(14);
        [clearButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [clearButton addTarget:kFilter action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *defAttributes = @{NSForegroundColorAttributeName: tcolor(TextColor),NSFontAttributeName: KP_REGULAR(16)};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString addAttributes:defAttributes range:NSMakeRange(0, attributedString.length)];
        [attributedString2 addAttributes:defAttributes range:NSMakeRange(0, attributedString2.length)];
        // Add attribute NSUnderlineStyleAttributeName
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
        

        [clearButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        [clearButton setAttributedTitle:attributedString2 forState:UIControlStateHighlighted];
        CGRectSetY(clearButton, CGRectGetMaxY(filterLabel.frame));
        CGRectSetCenterX(clearButton, filterBottomView.frame.size.width/2);
        [filterBottomView addSubview:clearButton];
        
        CGRectSetHeight(filterBottomView, CGRectGetMaxY(clearButton.frame)+5);
        
        [self.tableView setTableFooterView:filterBottomView];
        
    }
    
}

- (KPSegmentedViewController *)parent {
    KPSegmentedViewController *parent = (KPSegmentedViewController*)[self parentViewController];
    return parent;
}

- (NSMutableDictionary *)stateDictionary {
    if (!_stateDictionary)
        _stateDictionary = [NSMutableDictionary dictionary];
    return _stateDictionary;
}

- (CellType)determineCellTypeFromState:(NSString*)state {
    CellType cellType;
    if ([state isEqualToString:@"today"])
        cellType = CellTypeToday;
    else if ([state isEqualToString:@"schedule"])
        cellType = CellTypeSchedule;
    else
        cellType = CellTypeDone;
    return cellType;
}

- (void)setState:(NSString *)state {
    _state = state;
    self.cellType = [self determineCellTypeFromState:state];
}

- (void)update {
    if(!self.swipingCell){
        [self.itemHandler reloadData];
    }
    else self.needUpdate = YES;
}


- (void)willUpdateCells {
    
}

- (void)didUpdateCells {
    [self handleShowingToolbar];
}

- (NSMutableArray *)selectedRows {
    if(!_selectedRows)
        _selectedRows = [NSMutableArray array];
    return _selectedRows;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.itemHandler.isSorted && self.itemHandler.itemCounterWithFilter == 0)
        return 0;
    return kDefaultLineSize;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [[self.itemHandler titleForSection:section] uppercaseString];
    UIFont *font = SECTION_HEADER_FONT;
    SectionHeaderView *sectionHeader = [[SectionHeaderView alloc] initWithColor:[StyleHandler colorForCellType:self.cellType]
                                                                           font:font title:title width:tableView.frame.size.width];
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
    return [ToDoCell heightWithText:toDo.title hasSubtask:([toDo getSubtasks].count > 0)]; // CELL_HEIGHT;
}

- (ToDoCell*)readyCell:(ToDoCell*)cell {
    [cell setMode:MCSwipeTableViewCellModeExit];
    cell.delegate = self;
    cell.actionDelegate = self;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(ToDoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
    cell.cellType = [toDo cellTypeForTodo];
    if(self.cellType == CellTypeDone && !toDo.completionDate){
        self.badState = YES;
    }
    [cell setDotColor:self.cellType];
    
    [cell changeToDo:toDo withSelectedTags:kFilter.selectedTags];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.selectionMode){
        [self.selectedRows removeObject:indexPath];
        [self handleShowingToolbar];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.selectionMode){
        [self editIndexPath:indexPath];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else{
        if (![self.selectedRows containsObject:indexPath])
            [self.selectedRows addObject:indexPath];
        [self handleShowingToolbar];
    }
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)pressedActionStepsButtonCell:(ToDoCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if( !indexPath )
        return;
    self.showingViewController.expandOnShow = YES;
    [self editIndexPath:indexPath];
}

-(void)editIndexPath:(NSIndexPath *)indexPath
{
    [self editToDo:[self.itemHandler itemForIndexPath:indexPath]];
}

- (void)editToDo:(KPToDo *)todo
{
    if(self.hasStartedEditing)
        return;

    if ([ROOT_CONTROLLER.viewControllers containsObject:self.showingViewController]) {
        [UtilityClass sendError:[NSError errorWithDomain:@"Pushing the same view controller instance more than once" code:101 userInfo:nil] type:@"Todo List"];
        return;
    }
    
    self.hasStartedEditing = YES;
    self.savedContentOffset = self.tableView.contentOffset;
    self.showingViewController.model = todo;
    [ROOT_CONTROLLER pushViewController:self.showingViewController animated:YES];
    [ANALYTICS pushView:@"Edit Task"];
}

- (void)didPressCloseToDoViewController:(ToDoViewController *)viewController {
    [ROOT_CONTROLLER popViewControllerAnimated:YES];
    self.hasStartedEditing = NO;
    [ANALYTICS popView];
}

-(void)scheduleToDoViewController:(ToDoViewController *)viewController {
    
}

#pragma mark - UI Specific

- (NSArray *)selectedItems {
    NSMutableArray *array = [NSMutableArray array];
    for(NSIndexPath *indexPath in self.selectedRows){
        KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
        if(toDo) [array addObject:toDo];
    }
    return array;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) { // Don't do anything if the search table view get's scrolled
        if (scrollView.contentOffset.y < self.tableView.tableHeaderView.frame.size.height) {
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.tableView.tableHeaderView.bounds) - MAX(scrollView.contentOffset.y, 0), 0, 0, 0);
        }
        else {
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        if (scrollView.contentOffset.y < 0) {
            /*CGRectSetHeight(self.searchBar, self.tableView.tableHeaderView.frame.size.height-scrollView.contentOffset.y);
            CGRect searchBarFrame = self.searchBar.frame;
            searchBarFrame.origin.y = scrollView.contentOffset.y;
            self.searchBar.frame = searchBarFrame;*/
        }
    }
}

#pragma mark - SwipeTableCell

- (void)swipeTableViewCell:(ToDoCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.swipingCell = cell;
    if(self.parent.currentTopMenu == TopMenuSearch){
        [self.parent setCurrentTopMenu:TopMenuDefault animated:YES];
    }
    if(self.selectedRows.count > 0){
        if(indexPath && ![self.selectedRows containsObject:indexPath]){
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectedRows addObject:indexPath];
        }
    }
}

- (BOOL)swipeTableViewCell:(MCSwipeTableViewCell *)cell shouldHandleGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    if (self.swipingCell && cell != self.swipingCell)
        return NO;
    else
        return YES;
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didHandleGestureRecognizer:(UIPanGestureRecognizer *)gesture withTranslation:(CGPoint)translation {
    if (cell != self.swipingCell)
        return;
    NSArray *visibleCells = [self.tableView visibleCells];
    for (MCSwipeTableViewCell *localCell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if (localCell != cell && [self.selectedRows containsObject:indexPath]) {
            [localCell publicHandlePanGestureRecognizer:gesture withTranslation:translation];
        }
    }
}

- (void)swipeTableViewCell:(ToDoCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode {
    if (cell != self.swipingCell)
        return;
    if (self.isHandlingTrigger)
        return;
    self.isHandlingTrigger = YES;
    NSArray *toDosArray = [self selectedItems];
    if(!toDosArray || toDosArray.count == 0){
        KPToDo *item = [self.itemHandler itemForIndexPath:[self.tableView indexPathForCell:self.swipingCell]];
        if(!item)
            return;
        toDosArray = @[item];
    }
    NSArray *movedItems;
    __block CellType targetCellType = [StyleHandler cellTypeForCell:cell.cellType state:state];
    switch (targetCellType) {
        case CellTypeSchedule:{
            //SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
            __block BOOL hasReturned = NO;
            [kAudio playSoundWithName:@"New state - scheduled.m4a"];
            SchedulePopup *popup = [SchedulePopup popupWithFrame:self.parent.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate, CLPlacemark *chosenLocation, GeoFenceType type) {
                hasReturned = YES;
                [BLURRY dismissAnimated:YES];
                NSInteger beforeCounter = self.itemHandler.itemCounter;
                if(button == KPScheduleButtonCancel){
                    [self returnSelectedRowsAndBounce:YES];
                }
                else if(button == KPScheduleButtonLocation) {
                    NSArray *movedItems = [KPToDo notifyToDos:toDosArray onLocation:chosenLocation type:type save:YES];
                    [self moveItems:movedItems toCellType:targetCellType];
                }
                else {
                    if([chosenDate isEarlierThanDate:[NSDate date]]) targetCellType = CellTypeToday;
                    NSArray *movedItems = [KPToDo scheduleToDos:toDosArray forDate:chosenDate save:YES];
                    [self moveItems:movedItems toCellType:targetCellType];
                }
                if(button != KPScheduleButtonCancel){
                    [kHints triggerHint:HintScheduled];
                    if(!([self.state isEqualToString:@"today"] && beforeCounter == toDosArray.count))
                        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
                }
                self.isHandlingTrigger = NO;
            }];
            popup.calendarDate = ((KPToDo*)[toDosArray firstObject]).schedule;
            popup.numberOfItems = toDosArray.count;
            BLURRY.dismissAction = ^{
                self.isHandlingTrigger = NO;
                if(!hasReturned)
                    [self returnSelectedRowsAndBounce:YES];
            };
            BLURRY.blurryTopColor = alpha(tcolorF(TextColor,ThemeDark),0.1);
            [BLURRY showView:popup inViewController:self.parent];
            return;
        }
        case CellTypeToday:
            [kAudio playSoundWithName:@"New state - current.m4a"];
            movedItems = [KPToDo scheduleToDos:toDosArray forDate:[NSDate date] save:YES];
            break;
        case CellTypeDone:{
            double currentTime = CACurrentMediaTime();
            if((currentTime - self.lastCompletionTime) < 3){
                self.numberOfCompletions++;
                if(self.numberOfCompletions == 7)
                    self.numberOfCompletions = 1;
            }
            else{
                self.numberOfCompletions = 1;
            }
            self.lastCompletionTime = currentTime;
            if(!([self.state isEqualToString:@"today"] && self.itemHandler.itemCounter == toDosArray.count))
                [kAudio playSoundWithName:[NSString stringWithFormat:@"Task composer%li.m4a",(long)self.numberOfCompletions]];
            movedItems = [KPToDo completeToDos:toDosArray save:YES context:nil analytics:YES];
           

            break;
        }
        case CellTypeNone:
            
            [self returnSelectedRowsAndBounce:NO];
            self.isHandlingTrigger = NO;
            if(self.needUpdate){
                self.needUpdate = NO;
                [self update];
            }
            return;
    }
    [self moveItems:movedItems toCellType:targetCellType];
    self.isHandlingTrigger = NO;
}

- (void)swipeTableViewCell:(ToDoCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state {
    CellType targetType = self.cellType;
    if(state != MCSwipeTableViewCellStateNone){
        targetType = [StyleHandler cellTypeForCell:self.cellType state:state];
    }
    [cell setDotColor:targetType];
    
}
/*  */
- (void)deleteSelectedItems:(id)sender {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *toDos = [NSMutableArray array];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        [toDos addObject:[self.itemHandler itemForIndexPath:indexPath]];
        [indexSet addIndex:indexPath.row];
    }
    [KPToDo deleteToDos:toDos save:YES force:NO];
    [self removeItems:[self selectedItems]];
}

- (void)removeItems:(NSArray*)items {
    //if(items.count == 0) return;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for(KPToDo *toDo in items){
        NSIndexPath *toDoIP = [self.itemHandler indexPathForItem:toDo];
        if(toDoIP) [indexPaths addObject:toDoIP];
    }
    NSIndexSet *deletedSections = [self.itemHandler removeItems:items];
    if(self.selectedRows.count == indexPaths.count || (self.selectedRows.count == 0 && indexPaths.count == 1)){
        [self.tableView beginUpdates];
        //[self.tableView reloadData];
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            [self cleanUpAfterMovingAnimated:YES];
        }];
        @try {
            [self willUpdateCells];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            if(deletedSections && deletedSections.count > 0) [self.tableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        @catch (NSException *exception) {
            [self update];
        }
        [CATransaction commit];
    }
    else{
        [self update];
        [self cleanUpAfterMovingAnimated:YES];
    }
}

- (void)moveItems:(NSArray*)items toCellType:(CellType)cellType {
    [[self parent] highlightButton:(KPSegmentButtons)cellType-1];
    if (self.cellType != cellType) {
        [self removeItems:items];
    }
    else {
        [self returnSelectedRowsAndBounce:YES];
        [self deselectAllRows:self];
        [self update];
    }
}
-(void)selectAllRows{
    for (int i = 0; i < [self.tableView numberOfSections]; i++) {
        for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
            NSUInteger ints[2] = {i,j};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //Here is your code
            
        }
    }
}
- (void)cleanUpAfterMovingAnimated:(BOOL)animated {
    [self.selectedRows removeAllObjects];
    self.swipingCell = nil;
    [self didUpdateCells];
}

- (void)deselectAllRows:(id)sender {
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.selectedRows removeAllObjects];
    [self handleShowingToolbar];
}

- (void)returnSelectedRowsAndBounce:(BOOL)bounce {
    NSArray *visibleCells = [self.tableView visibleCells];
    for (ToDoCell *localCell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if([self.selectedRows containsObject:indexPath] || localCell == self.swipingCell){
            [localCell setDotColor:self.cellType];
            if(bounce) [localCell bounceToOrigin];
        }
    }
    self.swipingCell = nil;
    [self handleShowingToolbar];
}

- (void)prepareTableView:(UITableView *)tableView {
    
    tableView.allowsMultipleSelection = YES;
    [tableView setTableFooterView:[UIView new]];
    
    tableView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
    //tableView.contentInset = UIEdgeInsetsMake(0, 0, CONTENT_INSET_BOTTOM, 0);
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self.itemHandler;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.layer.masksToBounds = NO;
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, GLOBAL_TOOLBAR_HEIGHT, 0);
    
    tableView.contentOffset = CGPointMake(0, CGRectGetHeight(tableView.tableHeaderView.bounds));
}

#pragma mark - UIViewController stuff

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = CLEAR;
    
    if (![self.state isEqualToString:@"today"]) {
        NSString *iconString = ([self.state isEqualToString:@"schedule"]) ? @"later" : @"done";
        UILabel *backgroundIcon = iconLabel(iconString, 61);
        backgroundIcon.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 4);
        [backgroundIcon setTextColor:[StyleHandler colorForCellType:self.cellType]];
        //imageView.frame = CGRectSetPos(imageView.frame, (self.view.bounds.size.width-imageView.frame.size.width)/2, 80);
        backgroundIcon.tag = BACKGROUND_IMAGE_VIEW_TAG;
        [self.view addSubview:backgroundIcon];
        self.backgroundIcon = (UILabel*)[self.view viewWithTag:BACKGROUND_IMAGE_VIEW_TAG];
        UILabel *menuText = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundIcon.center.y+50, self.view.frame.size.width, TABLE_EMPTY_BG_TEXT_HEIGHT)];
        menuText.backgroundColor = CLEAR;
        menuText.font = TABLE_EMPTY_BG_FONT;
        NSString *text;
        switch (self.cellType) {
            case CellTypeDone:
                text = [LOCALIZE_STRING(@"done") capitalizedString];
                break;
            case CellTypeSchedule:
                text = [LOCALIZE_STRING(@"schedule") capitalizedString];
                break;
            default:
                text = @"";
                break;
        }
        menuText.text = text;
        menuText.textAlignment = NSTextAlignmentCenter;
        menuText.textColor = [StyleHandler colorForCellType:self.cellType];
        menuText.tag = MENU_TEXT_TAG;
        [self.view addSubview:menuText];
        self.menuText = [self.view viewWithTag:MENU_TEXT_TAG];
    }
    
    self.tableView = [[KPReorderTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self prepareTableView:self.tableView];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self update];
    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);

    if(!CGPointEqualToPoint(self.savedContentOffset, CGPointZero)){
        [self.tableView setContentOffset:self.savedContentOffset];
        self.savedContentOffset = CGPointZero;
    }
    [super viewWillAppear:animated];
    self.hasStartedEditing = NO;
}

- (void)viewDidAppear:(BOOL)animated {
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
            activeView = @"Today Tab";
            break;
    }
    [ANALYTICS pushView:activeView];
    [self handleShowingToolbar];
   
    if(self.badState){
        [[NSManagedObjectContext MR_defaultContext] reset];
        [self update];
        self.badState = NO;
    }
    // show any todo that needs to be viewed from the widget
    
}

- (void)handleShowingToolbar
{
    if (self.selectedRows.count > 0) {
        [[self parent] setCurrentState:KPControlCurrentStateEdit];
    }
    else
        [[self parent] setCurrentState:KPControlCurrentStateAdd];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self cleanUpAfterMovingAnimated:NO];
}

- (void)dealloc {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.backgroundIcon.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 4);
    self.menuText.frame = CGRectMake(0, self.backgroundIcon.center.y + 50, self.view.frame.size.width, TABLE_EMPTY_BG_TEXT_HEIGHT);
    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);
}

@end
