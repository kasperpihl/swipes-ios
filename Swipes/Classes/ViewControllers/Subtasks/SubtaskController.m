//
//  SubtaskController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 29/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SubtaskCell.h"
#import "StyleHandler.h"
#import "SubtaskController.h"
#import "UIColor+Utilities.h"
@interface SubtaskController () <UITableViewDataSource,UITableViewDelegate,ATSDragToReorderTableViewControllerDelegate, MCSwipeTableViewCellDelegate,SubtaskCellDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>

@property (nonatomic) NSIndexPath *draggingRow;
@property (nonatomic) NSArray *subtasks;
@property (nonatomic) SubtaskCell *editingCell;
@property (nonatomic) BOOL allTasksCompleted;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) BOOL expanded;
@end

@implementation SubtaskController
-(void)setExpanded:(BOOL)expanded{
    [self setExpanded:expanded animated:NO];
}
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated{
    _expanded = expanded;
}

-(void)setModel:(KPToDo *)model{
        _model = model;
        self.expanded = YES;
        
        //NSInteger numberOfUncompleted = [model.subtasks filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"completionDate = nil"]].count;
        if(model.subtasks.count > 3)
            self.expanded = NO;
        [self updateTableFooter];
    [self loadSubtasks];
    [self reloadAndNotify:NO];
    [self updateLine];
}
-(void)fullReload{
    [self loadSubtasks];
    [self reloadAndNotify:YES];
    [self updateLine];
}

-(void)loadSubtasks{
    NSSet *subtasks = self.model.subtasks;
    if(subtasks.count == 0)
        self.expanded = YES;
    BOOL hasUncompletedTasks = YES;
    if(!self.expanded){
        subtasks = [self.model.subtasks filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"completionDate = nil"]];
        if(!subtasks.count){
            //subtasks = self.model.subtasks;
            hasUncompletedTasks = NO;
        }
        
    }
    
    NSArray *sortedObjects = [KPToDo sortOrderForItems:[subtasks allObjects] newItemsOnTop:NO save:YES];
    if(!self.expanded && sortedObjects.count > 0){
        if(hasUncompletedTasks)
            sortedObjects = [sortedObjects subarrayWithRange:NSMakeRange(0, 1)];
        else
            sortedObjects = @[[sortedObjects lastObject]];
    }
    
    self.subtasks = sortedObjects;
}

-(void)updateLine{
    self.lineColor = alpha([StyleHandler colorForCellType:[self.model cellTypeForTodo]],0.35);
    for(SubtaskCell *cell in [self.tableView visibleCells]){
        //cell.seperator.backgroundColor = self.lineColor;
    }
}

-(void)pressedShowAll{
    if(!self.expanded){
        self.expanded = YES;
        [self fullReload];
        [self updateTableFooter];
    }
}

-(void)updateTableFooter{
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kSubtaskHeight)];
    tableFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(!self.expanded){
        UIButton *unpackButton = [[UIButton alloc] initWithFrame:tableFooter.bounds];
        [unpackButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        unpackButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        unpackButton.titleEdgeInsets = UIEdgeInsetsMake(0, CELL_LABEL_X, 0, 0);
        unpackButton.titleLabel.font = EDIT_TASK_TEXT_FONT;
        [unpackButton addTarget:self action:@selector(pressedShowAll) forControlEvents:UIControlEventTouchUpInside];
        [unpackButton setTitle:[NSString stringWithFormat:@"Show all %i steps",self.model.subtasks.count] forState:UIControlStateNormal];
        NSInteger dotViewSize = 8;
        UIColor *dotColor = tcolor(TextColor);
        CGPoint centerPoint = CGPointMake(CELL_LABEL_X/2, kSubtaskHeight/2);
        for(NSInteger i = 1 ; i >= 0  ; i--){
            
            UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dotViewSize, dotViewSize)];
            UIColor *thisColor = dotColor;
            /*for(NSInteger j = 0 ; j < i ; j++){
             NSLog(@"%i - %i",i,j);
             thisColor = [thisColor brightenedWithPercentage:-0.2];
             }*/
            dotView.backgroundColor = thisColor;
            CGFloat extraMultiplier = 2;
            dotView.center = CGPointMake(centerPoint.x + i * extraMultiplier, centerPoint.y + i * extraMultiplier);
            dotView.layer.masksToBounds = YES;
            [unpackButton addSubview:dotView];
        }
        [tableFooter addSubview:unpackButton];
    }
    else{
        SubtaskCell *addCell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubtaskTitleHeader"];
        addCell.activatedDirection = MCSwipeTableViewCellActivatedDirectionNone;
        
        addCell.subtaskDelegate = self;
        [addCell setAddModeForCell:YES];
        CGRectSetHeight(addCell, kSubtaskHeight);
        [tableFooter addSubview:addCell];
    }
    self.tableView.tableFooterView = tableFooter;
}

- (void)reloadAndNotify:(BOOL)notify{
    [self.tableView reloadData];
    [self setHeightAndNotify:notify];
}
-(void)setHeightAndNotify:(BOOL)notify{
    CGFloat contentHeight = 0;
    if(self.subtasks.count > 0){
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.subtasks.count-1 inSection:0];
        CGRect lastRowRect= [self.tableView rectForRowAtIndexPath:lastIndexPath];
        contentHeight = lastRowRect.origin.y + lastRowRect.size.height;
    }
    CGRectSetHeight(self.tableView,contentHeight + self.tableView.tableFooterView.frame.size.height);
    if(notify && [self.delegate respondsToSelector:@selector(subtaskController:changedToSize:)])
        [self.delegate subtaskController:self changedToSize:self.tableView.frame.size];
}


-(id)init{
    self = [super init];
    if(self){
        self.tableView = [[KPReorderTableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        self.tableView.dragDelegate = self;
        self.tableView.scrollEnabled = NO;
        self.tableView.scrollsToTop = NO;
        self.tableView.indicatorDelegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
    }
    return self;
}

#pragma mark SubtaskCellDelegate
- (void)addedSubtask: ( NSString* )subtask{
    [self.model addSubtask:subtask save:YES];
    [self fullReload];
    //[self loadData];
    //self.titles = [@[subtask] arrayByAddingObjectsFromArray:self.titles];
    //[self animateInAddTask];
}

- (void)subtaskCell: ( SubtaskCell* )cell editedSubtask: ( NSString* )subtask{
    
    NSString *editedText = [subtask stringByTrimmingCharactersInSet:
                            [NSCharacterSet newlineCharacterSet]];
    NSLog(@"edited subtask: %@",subtask);
    if ( editedText.length > 0 ){
        [cell.model setTitle:subtask];
        [KPToDo saveToSync];
    }
    else {
        [cell.titleField setText:cell.model.title];
    }
    
}
-(void)resign{
    [self.editingCell.titleField resignFirstResponder];
}
-(void)startedEditingSubtaskCell:(SubtaskCell *)cell{
    self.editingCell = cell;
    if([self.delegate respondsToSelector:@selector(subtaskController:editingCellWithFrame:)])
        [self.delegate subtaskController:self editingCellWithFrame:cell.frame];
}
-(void)startedAddingSubtaskInCell:(SubtaskCell *)cell{
    self.editingCell = cell;
    if([self.delegate respondsToSelector:@selector(subtaskController:editingCellWithFrame:)]){
        [self.delegate subtaskController:self editingCellWithFrame:self.tableView.tableFooterView.frame];
    }
}

#pragma mark MCSwipeTableViewCellDelegate
-(void)swipeTableViewCell:(SubtaskCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode{
    [UIView animateWithDuration:0.2 animations:^{
        cell.seperator.transform = CGAffineTransformMakeScale(1, 0.05);
        //cell.seperator.alpha = 0;
    }];
}
-(void)swipeTableViewCell:(SubtaskCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    [UIView animateWithDuration:0.2 animations:^{
        cell.seperator.transform = CGAffineTransformIdentity;
        //cell.seperator.alpha = 1;
    }];
    if(state == MCSwipeTableViewCellStateNone)
        return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if(indexPath){
        KPToDo *subtask = [self.subtasks objectAtIndex:indexPath.row];
        BOOL isDone = subtask.completionDate ? YES : NO;
        if(state == MCSwipeTableViewCellState1){
            [cell setStrikeThrough:YES];
            if(!isDone){
                [KPToDo completeToDos:@[subtask] save:YES];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                [KPToDo deleteToDos:@[subtask] save:YES];
                NSMutableArray *mutableSubtasks = [self.subtasks mutableCopy];
                [mutableSubtasks removeObjectAtIndex:indexPath.row];
                self.subtasks = [mutableSubtasks copy];
                [CATransaction begin];
                [CATransaction setCompletionBlock: ^{
                    [self setHeightAndNotify:YES];
                    [self updateTableFooter];
                }];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [CATransaction commit];
            }
            if(!self.expanded){
                [self fullReload];
            }
            if([self.delegate respondsToSelector:@selector(didChangeSubtaskController:)])
                [self.delegate didChangeSubtaskController:self];
        }
        else if(state == MCSwipeTableViewCellState3){
            [cell setStrikeThrough:NO];
            [KPToDo scheduleToDos:@[subtask] forDate:nil save:YES];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if([self.delegate respondsToSelector:@selector(didChangeSubtaskController:)])
                [self.delegate didChangeSubtaskController:self];
        }
    }
}
-(void)swipeTableViewCell:(SubtaskCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *subtask = [self.subtasks objectAtIndex:indexPath.row];
    BOOL isDone = subtask.completionDate ? YES : NO;
    if(state == MCSwipeTableViewCellModeNone){
        [cell setDotColor:isDone ? tcolor(DoneColor) : tcolor(TasksColor)];
        if(!isDone)
            [cell setStrikeThrough:NO];
    }
    if(state == MCSwipeTableViewCellState1){
        [cell setDotColor:isDone ? [UIColor redColor] : tcolor(DoneColor)];
        [cell setStrikeThrough:YES];
    }
    if(state == MCSwipeTableViewCellState3){
        [cell setStrikeThrough:NO];
    }
    
}


#pragma mark UITableViewDataSource
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    //self.draggingRow = destinationIndexPath;
    NSLog(@"move from %i to %i",sourceIndexPath.row,destinationIndexPath.row);
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //KPToDo *subtask = [self.subtasks objectAtIndex:indexPath.row];
    return kSubtaskHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subtasks.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"SubtaskCell";
    SubtaskCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
        cell.subtaskDelegate = self;
        cell.shouldRegret = YES;
        cell.mode = MCSwipeTableViewCellModeSwitch;
        //cell.bounceAmplitude = 0;
        [cell setAddModeForCell:NO];
    }
	return cell;
}


#pragma mark UITableViewDelegate
- (void)tableView: ( UITableView *)tableView willDisplayCell: (SubtaskCell *)cell forRowAtIndexPath: (NSIndexPath *)indexPath{
    KPToDo *subtask = (KPToDo*)[self.subtasks objectAtIndex:indexPath.row];
    BOOL isDone = subtask.completionDate ? YES : NO;
    
    [cell setTitle:subtask.title];
    cell.model = subtask;
    [cell setStrikeThrough:isDone];
    //cell.seperator.backgroundColor = self.lineColor;
    [cell setFirstColor:isDone ? [UIColor redColor] : [StyleHandler colorForCellType:CellTypeDone]];
    [cell setFirstIconName:isDone ? iconString(@"actionDeleteFull") : [StyleHandler iconNameForCellType:CellTypeDone]];
    [cell setThirdIconName:[StyleHandler iconNameForCellType:CellTypeToday]];
    [cell setThirdColor:[StyleHandler colorForCellType:CellTypeToday]];
    
    [cell setDotColor:isDone ? tcolor(DoneColor) : tcolor(TasksColor)];
    cell.activatedDirection = isDone ? MCSwipeTableViewCellActivatedDirectionBoth : MCSwipeTableViewCellActivatedDirectionRight;
    cell.modeForState1 = isDone ? MCSwipeTableViewCellModeExit : MCSwipeTableViewCellModeSwitch;
    
}
-(void)moveItem:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if(toIndexPath.row == fromIndexPath.row)
        return;
    KPToDo *movingToDoObject = [self.subtasks objectAtIndex:fromIndexPath.row];
    KPToDo *replacingToDoObject = [self.subtasks objectAtIndex:toIndexPath.row];
    NSArray *newItems = [movingToDoObject changeToOrder:replacingToDoObject.orderValue withItems:self.subtasks];
    self.subtasks = newItems;
    [self fullReload];
}


#pragma mark ATSDragableTableViewDelegate
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
    SubtaskCell *cell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	return cell;
}
- (void)dragTableViewController: ( KPReorderTableView *) dragTableViewController didBeginDraggingAtRow: ( NSIndexPath *) dragRow{
    
    self.draggingRow = dragRow;
    
}
- (void)dragTableViewController:( KPReorderTableView* ) dragTableViewController didEndDraggingToRow: ( NSIndexPath* ) destinationIndexPath{
    
    if(destinationIndexPath.row == self.draggingRow.row){
        self.draggingRow = nil;
        return;
    }
    [self moveItem:self.draggingRow toIndexPath:destinationIndexPath];
    /*NSMutableArray *titles = [self.subtasks mutableCopy];
     NSString *title = [self.subtasks objectAtIndex:self.draggingRow.row];
     [titles removeObjectAtIndex:self.draggingRow.row];
     NSInteger newIndex = (destinationIndexPath.row > self.draggingRow.row) ? destinationIndexPath.row : destinationIndexPath.row;
     [titles insertObject:title atIndex:newIndex];
     self. = [titles copy];*/
    //[self reload];
}
@end
