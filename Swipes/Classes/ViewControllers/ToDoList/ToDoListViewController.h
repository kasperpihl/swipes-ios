//
//  ToDoListTableViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPReorderTableView.h"
#import "KPToDo.h"
#import "ToDoCell.h"
@interface ToDoListViewController : UIViewController
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,weak) IBOutlet KPReorderTableView *tableView;
@property (nonatomic,strong) NSString *state;
-(void)update;
-(void)loadItems;
-(void)deselectAllRows:(id)sender;
-(void)deleteSelectedItems:(id)sender;
@end
