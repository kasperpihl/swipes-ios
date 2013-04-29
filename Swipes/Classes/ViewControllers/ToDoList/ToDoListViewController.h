//
//  ToDoListTableViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "KPToDo.h"
#import "ToDoCell.h"
#import "NSDate-Utilities.h"
#import "KPSegmentedViewController.h"
@interface ToDoListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *sortedItems;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
-(KPSegmentedViewController *)parent;
-(ToDoCell*)readyCell:(ToDoCell*)cell;
-(void)update;
-(void)updateWithoutLoading;
-(void)loadItems;
-(void)sortItems;
-(void)deselectAllRows:(id)sender;
-(void)deleteSelectedItems:(id)sender;
-(void)prepareTableView:(UITableView*)tableView;
-(NSArray*)selectedItems;
-(KPToDo*)itemForIndexPath:(NSIndexPath*)indexPath;
-(void)addItem:(KPToDo*)toDo withTitle:(NSString*)title;
-(void)addItems:(NSMutableArray*)items withTitle:(NSString*)title;
@end
