//
//  ToDoHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import <Foundation/Foundation.h>
#define TODOHANDLER [ToDoHandler sharedInstance]
#import "KPToDo.h"
@interface ToDoHandler : NSObject
+(ToDoHandler*)sharedInstance;
-(KPToDo*)addItem:(NSString*)item;
-(MCSwipeTableViewCellActivatedDirection)directionForCellType:(CellType)type;
-(CellType)cellTypeForCell:(CellType)type state:(MCSwipeTableViewCellState)state;
-(NSString*)stateForCellType:(CellType)type;
-(UIColor*)colorForCellType:(CellType)type;
-(UIColor*)strongColorForCellType:(CellType)type;
-(NSString*)iconNameForCellType:(CellType)type;
-(void)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date;
-(void)completeToDos:(NSArray*)toDoArray;
-(void)changeToDos:(NSArray*)toDos title:(NSString *)title save:(BOOL)save;
-(void)deleteToDos:(NSArray*)toDos save:(BOOL)save;
@end
