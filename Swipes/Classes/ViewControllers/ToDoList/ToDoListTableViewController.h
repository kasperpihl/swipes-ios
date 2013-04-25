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
#define SWIPES_BLUE [UIColor colorWithRed:47.0 / 255.0 green:141.0 / 255.0 blue:211.0 / 255.0 alpha:1.0]
#define DONE_COLOR [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
#define SCHEDULE_COLOR [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
@interface ToDoListTableViewController : ATSDragToReorderTableViewController
- (UITableViewCell *)cell:(ToDoCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSString *state;
-(void)update;
-(void)loadItems;
-(void)deselectAllRows:(id)sender;
-(void)deleteSelectedItems:(id)sender;
@end
