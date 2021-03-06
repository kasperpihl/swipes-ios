//
//  SubtaskController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 29/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "StyleHandler.h"
#import "SubtaskController.h"
#import "SlowHighlightIcon.h"
#import "UIColor+Utilities.h"
#import "AudioHandler.h"

#define kCloseButtonHeight 50

@interface SubtaskController () <UITableViewDataSource,UITableViewDelegate,ATSDragToReorderTableViewControllerDelegate, MCSwipeTableViewCellDelegate,SubtaskCellDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>

@property (nonatomic) NSIndexPath *draggingRow;
@property (nonatomic) SubtaskCell *editingCell;
@property (nonatomic) SubtaskCell *addCell;
@property (nonatomic) BOOL allTasksCompleted;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UIButton *closeLabelButton;


@property double lastCompletionTime;
@property NSInteger numberOfCompletions;
@end

@implementation SubtaskController
-(void)setExpanded:(BOOL)expanded{
    [self setExpanded:expanded animated:NO];
}
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated{
    _expanded = expanded;
    if([self.delegate respondsToSelector:@selector(subtaskController:changedExpanded:)])
        [self.delegate subtaskController:self changedExpanded:expanded];
    if(!expanded){
        [self resign];
    }
    if(!animated){
        //[self fullReload];
    }else{
        [self loadSubtasks];
        [self updateTableFooter];
        [self.tableView reloadData];
        [self setHeightAndNotify:YES animated:YES];
        
    }
    [self updateExpandButton:expanded animated:animated];
}

-(void)updateExpandButton:(BOOL)expanded animated:(BOOL)animated{
    unsigned long numberOfSubtasks = (unsigned long)[self.model getSubtasks].count;
    // TODO this "s" is not good for i18n
    [self.closeLabelButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"See%@ %lu action%@", nil),(numberOfSubtasks == 1 ) ? @"": NSLocalizedString(@" all", nil), numberOfSubtasks,(numberOfSubtasks == 1) ? @"" :NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
    [self.closeLabelButton sizeToFit];
    self.closeLabelButton.alpha = expanded ? 1 : 0;
    CGFloat extraHack = 15;
    CGFloat hackY = 1;
    CGFloat totalWidth = self.closeLabelButton.frame.size.width;
        CGRectSetX(self.closeLabelButton, 320/2 - totalWidth/2 + extraHack );
        CGRectSetCenterY( self.closeLabelButton, self.closeButton.center.y + hackY );
    voidBlock showBlock = ^{
        self.closeLabelButton.alpha = expanded ? 0 : 1;
        self.closeButton.transform = expanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        CGRectSetX(self.closeButton, (expanded ? 320/2-self.closeButton.frame.size.width/2 : ( extraHack + 320/2-totalWidth/2-self.closeButton.frame.size.width) ) );
    };
    if(animated){
        [UIView animateWithDuration:0.5 animations:showBlock completion:^(BOOL finished) {
            
        }];
    }
    else{
        showBlock();
    }
}

-(void)setModel:(KPToDo *)model{
    //NSLog(@"set model");
    _model = model;
    [self.editingCell.titleField resignFirstResponder];
    [self.addCell.titleField resignFirstResponder];
    self.expanded = NO;
    //[self loadSubtasks];
    //[self reloadAndNotify:NO];
}

-(void)fullReload{
    [self loadSubtasks];
    [self updateTableFooter];
    [self updateExpandButton:_expanded animated:NO];
    [self reloadAndNotify:YES];
}

-(void)loadSubtasks{
    NSSet *subtasks = [self.model getSubtasks];
    BOOL hasUncompletedTasks = YES;
    NSArray *sortedObjects = [KPToDo sortOrderForItems:[subtasks allObjects] newItemsOnTop:NO save:YES context:nil];
    if(!self.expanded){
        sortedObjects = [sortedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"completionDate = nil"]];
        if(!sortedObjects.count){
            hasUncompletedTasks = NO;
        }
        
    }
    //NSLog(@"length %i",subtasks.count);
    
    
    if(!self.expanded && sortedObjects.count > 0){
        if(hasUncompletedTasks)
            sortedObjects = [sortedObjects subarrayWithRange:NSMakeRange(0, 1)];
        else
            sortedObjects = @[[sortedObjects lastObject]];
    }
    
    self.subtasks = sortedObjects;
}


-(void)updateTableFooter{
    NSArray *subtasks = [[self.model getSubtasks] allObjects];
    NSInteger numberOfSubtasks = subtasks.count;
    BOOL hasCloseButton = (numberOfSubtasks > 1);
    if(numberOfSubtasks == 1){
        KPToDo *onlySubtask = [subtasks lastObject];
        if(onlySubtask.completionDate)
            hasCloseButton = YES;
    }
    CGFloat footerHeight = hasCloseButton ? kSubtaskHeight+kCloseButtonHeight : kSubtaskHeight;
    CGRectSetHeight(self.tableView.tableFooterView,footerHeight);
    //self.closeButton.transform = CGAffineTransformMakeRotation(self.expanded ? M_PI : 0);
}

- ( void )pressedCloseSubtasks{
    if(self.editingCell && self.editingCell.addModeForCell){
        /*if(self.editingCell.titleField.text.length == 0)
            [self setExpanded:NO animated:YES];
        else*/
        [self resign];
        
    }
    else
        [self setExpanded:!self.expanded animated:YES];
}

- (void)reloadAndNotify:(BOOL)notify{
    [self.tableView reloadData];
    [self setHeightAndNotify:notify animated:NO];
}
-(void)setHeightAndNotify:(BOOL)notify animated:(BOOL)animated{
    CGFloat contentHeight = 0;
    if(self.subtasks.count > 0){
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.subtasks.count-1 inSection:0];
        CGRect lastRowRect= [self.tableView rectForRowAtIndexPath:lastIndexPath];
        contentHeight = lastRowRect.origin.y + lastRowRect.size.height;
    }
    
    if(animated){
        [UIView beginAnimations:@"expand" context:nil];
        [UIView setAnimationDuration:0.25f];
    }
    
    CGRectSetHeight(self.tableView,contentHeight + self.tableView.tableFooterView.frame.size.height);
    if(notify && [self.delegate respondsToSelector:@selector(subtaskController:changedToSize:)])
        [self.delegate subtaskController:self changedToSize:CGSizeMake(self.tableView.frame.size.width, contentHeight + self.tableView.tableFooterView.frame.size.height)];
    if(animated){
        [UIView commitAnimations];
    }
}

-(id)init{
    self = [super init];
    if(self){
        self.tableView = [[KPReorderTableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = tcolor(BackgroundColor);
        self.tableView.layer.masksToBounds = YES;
        self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        self.tableView.dragDelegate = self;
        self.tableView.scrollEnabled = NO;
        self.tableView.scrollsToTop = NO;
        self.tableView.indicatorDelegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kSubtaskHeight)];
        tableFooter.backgroundColor = tcolor(BackgroundColor);
        tableFooter.layer.masksToBounds = YES;
        tableFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        SubtaskCell *addCell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubtaskTitleHeader"];
        CGRectSetWidth(addCell, CGRectGetWidth(tableFooter.frame));
        addCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        addCell.activatedDirection = MCSwipeTableViewCellActivatedDirectionNone;
        addCell.subtaskDelegate = self;
        [addCell setAddModeForCell:YES];
        CGRectSetHeight(addCell, kSubtaskHeight);
        [tableFooter addSubview:addCell];
        self.addCell = addCell;
        
        self.closeLabelButton = [[UIButton alloc] init];
        self.closeLabelButton.titleLabel.numberOfLines = 1;
        self.closeLabelButton.titleLabel.font = KP_REGULAR(15);
        self.closeLabelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.closeLabelButton.backgroundColor = CLEAR;
        [self.closeLabelButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [self.closeLabelButton addTarget:self action:@selector(pressedCloseSubtasks) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:self.closeLabelButton];
        
        UIButton *closeButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2-kCloseButtonHeight/2, kSubtaskHeight, kCloseButtonHeight, kCloseButtonHeight)];
        closeButton.titleLabel.font = iconFont(28);
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin);
        //closeButton.backgroundColor = tcolor(LaterColor);
        closeButton.transform = CGAffineTransformMakeRotation(M_PI);
        [closeButton setTitle:iconString(@"editActionRoundedArrow") forState:UIControlStateNormal];
        //[closeButton setTitle:@"roundBackFull" forState:UIControlStateHighlighted];
        [closeButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(pressedCloseSubtasks) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:closeButton];
        self.closeButton = closeButton;
        
        
        
        self.tableView.tableFooterView = tableFooter;
        [self updateTableFooter];
    }
    return self;
}

#pragma mark SubtaskCellDelegate
- (void)addedSubtask: ( NSString* )subtask{
    [self.model addSubtask:subtask save:YES from:@"Input"];
    [self fullReload];
    [kAudio playSoundWithName:@"Succesful action.m4a"];
    //[self loadData];
    //self.titles = [@[subtask] arrayByAddingObjectsFromArray:self.titles];
    //[self animateInAddTask];
}

- (void)subtaskCell: ( SubtaskCell* )cell editedSubtask: ( NSString* )subtask{
    
    NSString *editedText = [subtask stringByTrimmingCharactersInSet:
                            [NSCharacterSet newlineCharacterSet]];
    if ( editedText.length > 0 ){
        if(cell && cell.model){
            [cell.model setTitle:subtask];
            [KPToDo saveToSync];
            cell.title = subtask;
        }
    }
    else {
        [cell.titleField setText:cell.model.title];
    }
    
}
-(void)resign{
    [self.editingCell.titleField resignFirstResponder];
    [self.addCell.titleField resignFirstResponder];
    self.editingCell = nil;
}
-(void)startedEditingSubtaskCell:(SubtaskCell *)cell{
    self.editingCell = cell;
    if([self.delegate respondsToSelector:@selector(subtaskController:editingCellWithFrame:)])
        [self.delegate subtaskController:self editingCellWithFrame:cell.frame];
}
-(void)startedAddingSubtaskInCell:(SubtaskCell *)cell{
    if(!self.expanded)
        [self setExpanded:YES animated:YES];
    self.editingCell = cell;
    if([self.delegate respondsToSelector:@selector(subtaskController:editingCellWithFrame:)]){
        [self.delegate subtaskController:self editingCellWithFrame:self.tableView.tableFooterView.frame];
    }
}
-(BOOL)shouldStartEditingSubtaskCell:(SubtaskCell *)cell{
    if(!self.expanded && !cell.addModeForCell && [self.model getSubtasks].count > 1){
        [self setExpanded:YES animated:YES];
        return NO;
    }
    return YES;
}
-(void)endedEditingCell:(SubtaskCell *)cell{
    self.editingCell = nil;
    if (self.expanded && cell.addModeForCell && self.subtasks.count <= 1)
        [self setExpanded:NO animated:YES];
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
                [kAudio playSoundWithName:[NSString stringWithFormat:@"Task composer%li.m4a",(long)self.numberOfCompletions]];
                [KPToDo completeToDos:@[subtask] save:YES context:nil from:@"Swipe"];
                if(self.expanded){
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                else{
                    [CATransaction begin];
                    [CATransaction setCompletionBlock: ^{
                    }];
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                    [CATransaction commit];
                }
            }
            else{
                [KPToDo deleteToDos:@[subtask] inContext:nil save:YES force:NO];
                NSMutableArray *mutableSubtasks = [self.subtasks mutableCopy];
                [mutableSubtasks removeObjectAtIndex:indexPath.row];
                self.subtasks = [mutableSubtasks copy];
                [CATransaction begin];
                [CATransaction setCompletionBlock: ^{
                    [self setHeightAndNotify:YES animated:NO];
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
            [KPToDo scheduleToDos:@[subtask] forDate:nil save:YES from:@"Swipe"];
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
    //NSLog(@"move from %i to %i",sourceIndexPath.row,destinationIndexPath.row);
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
