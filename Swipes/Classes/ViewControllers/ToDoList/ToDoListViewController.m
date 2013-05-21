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
#import "KPSearchBar.h"
#import <QuartzCore/QuartzCore.h>
#define TABLEVIEW_TAG 500
#define BACKGROUND_IMAGE_VIEW_TAG 504
#define BACKGROUND_LABEL_VIEW_TAG 502
#define SEARCH_BAR_TAG 503

#define SECTION_HEADER_HEIGHT 30
#define FAKE_HEADER_VIEW_TAG 505
#define MENU_TEXT_TAG 506
#define COLORED_MENU_TEXT_TAG 507
#define SECTION_HEADER_X 15
#define CONTENT_INSET_BOTTOM 5// 100
@interface ToDoListViewController ()<MCSwipeTableViewCellDelegate,KPSearchBarDelegate,KPSearchBarDelegate>

@property (nonatomic,strong) MCSwipeTableViewCell *swipingCell;
@property (nonatomic) CellType cellType;
@property (nonatomic,strong) KPSearchBar *searchBar;
@property (nonatomic) NSMutableArray *selectedRows;
@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic,weak) IBOutlet UIView *menuText;
@property (nonatomic,weak) IBOutlet UIView *coloredMenuText;
@property (nonatomic,weak) UIView *fakeHeaderView;
@property (nonatomic) BOOL isColored;

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
#pragma mark ItemHandlerDelegate
-(void)didUpdateItemHandler:(ItemHandler *)handler{
    [self.tableView reloadData];
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
-(void)updateWithoutLoading{
    [self update];
    for(NSIndexPath *indexPath in self.selectedRows){
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}
-(void)update{
    [self.itemHandler reloadData];
    [self didUpdateCells];
    
}
-(void)didUpdateCells{
    if([self.state isEqualToString:@"today"]){
        /*if(self.itemCounter == 0) [self changeToColored:YES];
        else [self changeToColored:NO];*/
    }
}
-(NSMutableArray *)selectedRows{
    if(!_selectedRows) _selectedRows = [NSMutableArray array];
    return _selectedRows;
}

#pragma mark - KPSearchBarDelegate
-(void)searchBar:(KPSearchBar *)searchBar pressedFilterButton:(UIButton *)filterButton{
    searchBar.currentMode = KPSearchBarModeTags;
}
-(void)searchBar:(KPSearchBar *)searchBar deselectedTag:(NSString *)tag{
    [self.itemHandler deselectTag:tag];
}
-(void)searchBar:(KPSearchBar *)searchBar selectedTag:(NSString *)tag{
    [self.itemHandler selectTag:tag];
}
-(void)clearedAllFiltersForSearchBar:(KPSearchBar *)searchBar{
    self.searchBar.currentMode = KPSearchBarModeNone;
    [self.itemHandler clearAll];
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.itemHandler.isSorted) return SECTION_HEADER_HEIGHT;
    else return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.itemHandler.isSorted){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        headerView.backgroundColor = SECTION_HEADER_BACKGROUND;
        NSString *title = [self.itemHandler titleForSection:section];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SECTION_HEADER_X, 0, tableView.bounds.size.width-SECTION_HEADER_X, SECTION_HEADER_HEIGHT)];
        titleLabel.backgroundColor = CLEAR;
        titleLabel.textColor = SECTION_HEADER_COLOR;
        titleLabel.text = [title capitalizedString];
        [headerView addSubview:titleLabel];
        return headerView;
    }
    else return nil;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*if(self.selectedRow == indexPath.row+1) return 120;
    else*/ return CELL_HEIGHT;
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
    cell.cellType = self.cellType;
    [cell showTimeline:YES];
    [cell setDotColor:[TODOHANDLER colorForCellType:self.cellType]];
    KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
    [cell changeToDo:toDo withSelectedTags:self.itemHandler.selectedTags];
    
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
        ToDoCell* cell = (ToDoCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.tag = 1336;
    }
}
#pragma mark - UI Specific
-(NSArray *)selectedItems{
    NSMutableArray *array = [NSMutableArray array];
    for(NSIndexPath *indexPath in self.selectedRows){
        KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
        [array addObject:toDo];
    }
    return array;
}


#pragma mark - ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    //if(self.tableView.frame.size.height - 150 >= self.tableView.contentSize.height) return;
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
        else if(scrollSpeedNotAbs < -0.5 /* && (currentOffset.y+self.tableView.frame.size.height) < self.tableView.contentSize.height*/){
            if((self.tableView.frame.size.height > self.tableView.contentSize.height && currentOffset.y < 0) || (currentOffset.y+self.tableView.frame.size.height) < self.tableView.contentSize.height+CONTENT_INSET_BOTTOM) [[self parent] show:YES controlsAnimated:YES];
        }
        
        self.lastOffset = currentOffset;
        self.lastOffsetCapture = currentTime;
    }
    if (scrollView == self.tableView) { // Don't do anything if the search table view get's scrolled
        self.fakeHeaderView.hidden = !(scrollView.contentOffset.y > self.tableView.tableHeaderView.frame.size.height);
         
        if (scrollView.contentOffset.y < self.searchBar.frame.size.height) {
           
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds) - MAX(scrollView.contentOffset.y, 0), 0, COLOR_SEPERATOR_HEIGHT, 0);
        } else {
            
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, COLOR_SEPERATOR_HEIGHT, 0);
        }
        //searchBarFrame.origin.y = MIN(scrollView.contentOffset.y, 0)-COLOR_SEPERATOR_HEIGHT;
        //NSLog(@"%@,scrollView:%f",self.searchBar,searchBarFrame.origin.y);
        if(scrollView.contentOffset.y <= 0){
            CGRectSetSize(self.searchBar.frame, self.searchBar.frame.size.width, self.tableView.tableHeaderView.frame.size.height-scrollView.contentOffset.y+COLOR_SEPERATOR_HEIGHT);
            CGRect searchBarFrame = self.searchBar.frame;
            searchBarFrame.origin.y = scrollView.contentOffset.y-COLOR_SEPERATOR_HEIGHT;
            self.searchBar.frame = searchBarFrame;
        }
    }
}
#pragma mark - SwipeTableCell
-(void)swipeTableViewCell:(ToDoCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode{
    [[self parent] show:NO controlsAnimated:YES];
    [cell showTimeline:NO];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.swipingCell = cell;
    if(![self.selectedRows containsObject:indexPath]) [self.selectedRows addObject:indexPath];
    if(self.selectedRows.count > 0){
        NSArray *visibleCells = [self.tableView visibleCells];
        for(ToDoCell *localCell in visibleCells){
            if(localCell.isSelected){
                
                [localCell setSelected:NO];
                [localCell showTimeline:NO];
            }
        }
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
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *toDosArray = [NSMutableArray array];
    for(NSIndexPath *indexPath in self.selectedRows){
        KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
        [toDosArray addObject:toDo];
        [indexSet addIndex:indexPath.row];
    }
    CellType targetCellType = [TODOHANDLER cellTypeForCell:cell.cellType state:state];
    switch (targetCellType) {
        case CellTypeSchedule:{
            [SchedulePopup showInView:self.parent.view withBlock:^(KPScheduleButtons button, NSDate *date) {
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
            [TODOHANDLER scheduleToDos:toDosArray forDate:[NSDate date]];
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
-(void)swipeTableViewCell:(ToDoCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state{
    CellType targetType = self.cellType;
    if(state != MCSwipeTableViewCellStateNone){
        targetType = [TODOHANDLER cellTypeForCell:self.cellType state:state];
    }
    
    UIColor *dotColor = [TODOHANDLER colorForCellType:targetType];
    [cell setDotColor:dotColor];
}
/*  */
-(void)deleteSelectedItems:(id)sender{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in selectedIndexPaths){
        KPToDo *toDo = [self.itemHandler itemForIndexPath:indexPath];
        [toDo MR_deleteInContext:[NSManagedObjectContext MR_defaultContext]];
        [indexSet addIndex:indexPath.row];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    [self removeItemsForIndexSet:indexSet];
}
-(void)removeItemsForIndexSet:(NSIndexSet*)indexSet{
    NSIndexSet *deletedSections = [self.itemHandler removeItemsForIndexSet:indexSet];
    if(deletedSections){
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
        if(deletedSections.count > 0) [self.tableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else{
        [self.tableView deleteRowsAtIndexPaths:self.selectedRows withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.selectedRows removeAllObjects];
    [self didUpdateCells];
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
    for(ToDoCell *localCell in visibleCells){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:localCell];
        if([self.selectedRows containsObject:indexPath]){
            [localCell showTimeline:YES];
            [localCell setDotColor:[TODOHANDLER colorForCellType:self.cellType]];
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
    [tableView setTableFooterView:[UIView new]];
    tableView.frame = CGRectMake(0, COLOR_SEPERATOR_HEIGHT, tableView.frame.size.width, tableView.frame.size.height-COLOR_SEPERATOR_HEIGHT);
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    //tableView.contentInset = UIEdgeInsetsMake(0, 0, CONTENT_INSET_BOTTOM, 0);
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self.itemHandler;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.layer.masksToBounds = NO;
    UIView *headerView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, SEARCH_BAR_DEFAULT_HEIGHT-COLOR_SEPERATOR_HEIGHT)];
    headerView.hidden = YES;
    tableView.tableHeaderView = headerView;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
    footerView.backgroundColor = CELL_TIMELINE_COLOR;
    //tableView.tableFooterView = footerView;
    
    KPSearchBar *searchBar = [[KPSearchBar alloc] initWithFrame:CGRectMake(0,-COLOR_SEPERATOR_HEIGHT, 320, SEARCH_BAR_DEFAULT_HEIGHT)];
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
    NSString *imageString = colored ? @"today_color_background" : @"today_white_background";
    UIImage *fadeToImage = [UIImage imageNamed:imageString];
    if(colored){
        self.coloredMenuText.alpha = 0;
        self.coloredMenuText.hidden = NO;
        self.menuText.hidden = YES;
        [UIView transitionWithView:self.backgroundImage
                          duration:0.8f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.backgroundImage.image = fadeToImage;
                        } completion:^(BOOL finished) {
                        }];
        [UIView animateWithDuration:1.5 animations:^{
            self.coloredMenuText.alpha = 1;
        } completion:^(BOOL finished) {
            self.menuText.hidden = YES;
        }];
    }
    else{
        self.backgroundImage.image = fadeToImage;
        self.menuText.hidden = NO;
        self.menuText.alpha = 1;
        self.coloredMenuText.hidden = YES;
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = TABLE_BACKGROUND;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
    headerView.backgroundColor = SEGMENT_SELECTED;
    headerView.tag = FAKE_HEADER_VIEW_TAG;
    [self.view addSubview:headerView];
    self.fakeHeaderView = [self.view viewWithTag:FAKE_HEADER_VIEW_TAG];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white_background",self.state]]];
    imageView.frame = CGRectSetPos(imageView.frame, (self.view.bounds.size.width-imageView.frame.size.width)/2, 80);
    imageView.tag = BACKGROUND_IMAGE_VIEW_TAG;
    [self.view addSubview:imageView];
    self.backgroundImage = (UIImageView*)[self.view viewWithTag:BACKGROUND_IMAGE_VIEW_TAG];
    
    UILabel *menuText = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y+imageView.frame.size.height, self.view.frame.size.width, TABLE_MENU_TEXT_HEIGHT)];
    menuText.backgroundColor = CLEAR;
    menuText.font = TABLE_MENU_FONT;
    menuText.text = [self.state capitalizedString];
    menuText.textAlignment = UITextAlignmentCenter;
    menuText.textColor = TABLE_MENU_TEXT;
    menuText.tag = MENU_TEXT_TAG;
    [self.view addSubview:menuText];
    self.menuText = [self.view viewWithTag:MENU_TEXT_TAG];
    
    UILabel *coloredMenuText = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y+imageView.frame.size.height, self.view.frame.size.width, TABLE_MENU_TEXT_HEIGHT)];
    coloredMenuText.backgroundColor = CLEAR;
    coloredMenuText.tag = COLORED_MENU_TEXT_TAG;
    coloredMenuText.font = TABLE_MENU_FONT;
    coloredMenuText.text = [self.state capitalizedString];
    coloredMenuText.textAlignment = UITextAlignmentCenter;
    coloredMenuText.hidden = YES;
    coloredMenuText.text = @"Well Swiped!";
    coloredMenuText.textColor = TABLE_MENU_COLORED_TEXT;
    [self.view addSubview:coloredMenuText];
    self.coloredMenuText = [self.view viewWithTag:COLORED_MENU_TEXT_TAG];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.tag = TABLEVIEW_TAG;
    [self prepareTableView:tableView];
    [self.view addSubview:tableView];
    self.tableView = (UITableView*)[self.view viewWithTag:TABLEVIEW_TAG];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self update];
    [self.view bringSubviewToFront:[self.view viewWithTag:FAKE_HEADER_VIEW_TAG]];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
