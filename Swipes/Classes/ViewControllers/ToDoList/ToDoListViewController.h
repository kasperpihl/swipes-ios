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
@property (nonatomic,weak) IBOutlet UILabel *backgroundIcon;
@property (nonatomic,weak) IBOutlet UILabel *backgroundLabel;
@property (nonatomic,strong) ItemHandler *itemHandler;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
-(KPSegmentedViewController *)parent;
-(ToDoCell*)readyCell:(ToDoCell*)cell;
-(void)deselectAllRows:(id)sender;
-(void)deleteSelectedItems:(id)sender;
-(void)prepareTableView:(UITableView*)tableView;
-(NSArray*)selectedItems;
-(void)update;
-(void)didUpdateCells;
-(void)pressedEdit;
- (void)editToDo:(KPToDo *)todo;
@end
