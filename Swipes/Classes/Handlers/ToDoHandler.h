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
-(KPToDo*)addItem:(NSString*)item save:(BOOL)save;

-(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date;
-(NSArray*)completeToDos:(NSArray*)toDoArray;
-(void)changeToDos:(NSArray*)toDos title:(NSString *)title save:(BOOL)save;
-(void)deleteToDos:(NSArray*)toDos save:(BOOL)save;
@end
