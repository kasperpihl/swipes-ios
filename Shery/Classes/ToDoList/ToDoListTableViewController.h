//
//  ToDoListTableViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ATSDragToReorderTableViewController.h"
#import "KPToDo.h"
@class ToDoCell;
@interface ToDoListTableViewController : ATSDragToReorderTableViewController
- (UITableViewCell *)cell:(ToDoCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic,strong) NSArray *items;
-(NSArray*)loadItems;
@end
