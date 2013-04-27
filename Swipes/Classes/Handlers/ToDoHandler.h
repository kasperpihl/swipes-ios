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
-(MCSwipeTableViewCellActivatedDirection)directionForCellType:(CellType)type;
-(CellType)cellTypeForCell:(CellType)type state:(MCSwipeTableViewCellState)state;
-(NSString*)stateForCellType:(CellType)type;
-(UIColor*)colorForCellType:(CellType)type;
-(NSString*)iconNameForCellType:(CellType)type;
-(void)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date;
-(void)completeToDos:(NSArray*)toDoArray;
-(void)setForTodayToDos:(NSArray*)toDoArray;
@end
