//
//  ToDoListTableViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ATSDragToReorderTableViewController.h"
#import "KPToDo.h"
#import "ToDoCell.h"
@interface ToDoListTableViewController : ATSDragToReorderTableViewController
- (UITableViewCell *)cell:(ToDoCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSString *state;
-(void)update;
-(void)loadItems;
-(NSString*)stateForTriggerState:(MCSwipeTableViewCellState)state;
-(void)deselectAllRows:(id)sender;
-(void)deleteSelectedItems:(id)sender;
@end
