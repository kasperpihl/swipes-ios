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
@property (nonatomic,strong) NSMutableDictionary *sortedItems;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isScrollingFast;
-(KPSegmentedViewController *)parent;
-(ToDoCell*)readyCell:(ToDoCell*)cell;
-(void)update;
-(void)loadItems;
-(void)sortItems;
-(void)deselectAllRows:(id)sender;
-(void)deleteSelectedItems:(id)sender;
-(void)prepareTableView:(UITableView*)tableView;
-(KPToDo*)itemForIndexPath:(NSIndexPath*)indexPath;
-(void)addItem:(KPToDo*)toDo toTitle:(NSString*)title;
@end
