//
//  ToDoListTableViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "KPToDo.h"
#import "ToDoCell.h"
#import "NSDate-Utilities.h"
#import "KPSegmentedViewController.h"
#import "ItemHandler.h"

@interface ToDoListViewController : UIViewController <UITableViewDelegate,ItemHandlerDelegate>
@property (nonatomic, strong) UILabel *backgroundIcon;
@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, strong) ItemHandler *itemHandler;
@property (nonatomic, assign) BOOL selectionMode;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) UITableView *tableView;
-(KPSegmentedViewController *)parent;
-(ToDoCell*)readyCell:(ToDoCell*)cell;
-(void)deselectAllRows:(id)sender;
-(void)selectAllRows;
-(void)deleteSelectedItems:(id)sender;
-(void)prepareTableView:(UITableView*)tableView;
-(NSArray*)selectedItems;
-(void)update;
-(void)didUpdateCells;
- (void)editToDo:(KPToDo *)todo;
@end
