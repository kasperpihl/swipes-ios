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
@interface SubtaskController () <UITableViewDataSource,UITableViewDelegate,ATSDragToReorderTableViewControllerDelegate, MCSwipeTableViewCellDelegate,SubtaskCellDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>

@property (nonatomic) NSIndexPath *draggingRow;
@property (nonatomic) NSArray *subtasks;
@end

@implementation SubtaskController


-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
    }
    [self loadSubtasks];
    [self reload];
}


-(void)loadSubtasks{
    /*BOOL isCompletedMenu = ([[self.segmentedControl selectedIndexes] firstIndex] == 1);
    NSString *predString = isCompletedMenu ? @"completionDate != nil" : @"completionDate = nil";
    NSSet *filteredSet = [self.model.subtasks filteredSetUsingPredicate:[NSPredicate predicateWithFormat:predString]];
    */
    NSString *sortKey = @"order";
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    
    NSArray *sortedObjects = [self.model.subtasks sortedArrayUsingDescriptors:@[descriptor]];
    sortedObjects = [KPToDo sortOrderForItems:sortedObjects save:YES];
    self.subtasks = sortedObjects;
    /*
     Filter down to completed or undone
     If undone - sort for order and make new numbers if needed
     reload tableview
     
     */
}

- (void)reload{
    [self.tableView reloadData];
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.subtasks.count-1 inSection:0];
    CGRect lastRowRect= [self.tableView rectForRowAtIndexPath:lastIndexPath];
    CGFloat contentHeight = lastRowRect.origin.y + lastRowRect.size.height;
    CGRectSetHeight(self.tableView,contentHeight + self.tableView.tableFooterView.frame.size.height);
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
        UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kSubtaskHeight)];
        tableFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        SubtaskCell *addCell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubtaskTitleHeader"];
        CGRectSetHeight(addCell, kSubtaskHeight);
        addCell.subtaskDelegate = self;
        [addCell setAddMode:YES];
        [tableFooter addSubview:addCell];
        self.tableView.tableFooterView = tableFooter;
    }
    return self;
}

#pragma mark SubtaskCellDelegate
- (void)addedSubtask: ( NSString* )subtask{
    [self.model addSubtask:subtask save:YES];
    //[self loadData];
    //self.titles = [@[subtask] arrayByAddingObjectsFromArray:self.titles];
    //[self animateInAddTask];
}

- (void)subtaskCell: ( SubtaskCell* )cell editedSubtask: ( NSString* )subtask{
    
    NSString *editedText = [subtask stringByTrimmingCharactersInSet:
                            [NSCharacterSet newlineCharacterSet]];
    if ( editedText.length > 0 )
        [cell.model setTitle:subtask];
    
    [KPToDo saveToSync];
}



#pragma mark UITableViewDataSource
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{

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
    }
	return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(SubtaskCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    KPToDo *subtask = (KPToDo*)[self.subtasks objectAtIndex:indexPath.row];
    BOOL isDone = subtask.completionDate ? YES : NO;
    
    [cell setTitle:subtask.title];
    cell.model = subtask;
    if(!isDone){
        [cell setFirstColor:isDone ? [UIColor redColor] : [StyleHandler colorForCellType:CellTypeDone]];
        [cell setFirstIconName:isDone ? iconString(@"actionDelete") : [StyleHandler iconNameForCellType:CellTypeDone]];
    }
    
    //[cell setThirdIconName:iconString(@"actionDelete")];
    cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionRight;
    cell.shouldRegret = YES;
    cell.mode = MCSwipeTableViewCellModeSwitch;
    cell.bounceAmplitude = 0;
    [cell setAddMode:NO];
    /*if(indexPath.row == 0) [cell setAddMode:YES animated:NO];
     else*/
}


#pragma mark ATSDragableTableViewDelegate
- (void)dragTableViewController: ( KPReorderTableView *) dragTableViewController didBeginDraggingAtRow: ( NSIndexPath *) dragRow{
    
    self.draggingRow = dragRow;
    
}
- (void)dragTableViewController:( KPReorderTableView* ) dragTableViewController didEndDraggingToRow: ( NSIndexPath* ) destinationIndexPath{
    
    if(destinationIndexPath.row == self.draggingRow.row){
        self.draggingRow = nil;
        return;
    }
    /*NSMutableArray *titles = [self.subtasks mutableCopy];
     NSString *title = [self.subtasks objectAtIndex:self.draggingRow.row];
     [titles removeObjectAtIndex:self.draggingRow.row];
     NSInteger newIndex = (destinationIndexPath.row > self.draggingRow.row) ? destinationIndexPath.row : destinationIndexPath.row;
     [titles insertObject:title atIndex:newIndex];
     self. = [titles copy];*/
    //[self reload];
}
@end
