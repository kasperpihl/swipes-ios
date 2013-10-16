//
//  ToDoHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoHandler.h"
#import "NotificationHandler.h"
#import "NSDate-Utilities.h"
#import "AnalyticsHandler.h"
#import "ThemeHandler.h"
#import "KPParseCoreData.h"
@interface ToDoHandler ()
@end    
@implementation ToDoHandler
static ToDoHandler *sharedObject;
+(ToDoHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[ToDoHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)deleteToDos:(NSArray*)toDos save:(BOOL)save{
    BOOL shouldUpdateNotifications = NO;
    for(KPToDo *toDo in toDos){
        if(!toDo.completionDate) shouldUpdateNotifications = YES;
        [toDo deleteToDoSave:NO];
    }
    if(save) [self save];
    [ANALYTICS incrementKey:NUMBER_OF_DELETED_TASKS_KEY withAmount:toDos.count];
    if(shouldUpdateNotifications) [NOTIHANDLER updateLocalNotifications];
}
-(KPToDo*)addItem:(NSString *)item save:(BOOL)save{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.schedule = [NSDate date];
    NSNumber *count = [KPToDo MR_numberOfEntities];
    newToDo.order = count;
    if(save) [self save];
    NSString *taskLength = @"50+";
    if(item.length <= 10) taskLength = @"1-10";
    else if(item.length <= 20) taskLength = @"11-20";
    else if(item.length <= 30) taskLength = @"21-30";
    else if(item.length <= 40) taskLength = @"31-40";
    else if(item.length <= 50) taskLength = @"41-50";
    [ANALYTICS tagEvent:@"Added Task" options:@{@"Length":taskLength}];
    [ANALYTICS incrementKey:NUMBER_OF_ADDED_TASKS_KEY withAmount:1];
    [NOTIHANDLER updateLocalNotifications];
    return newToDo;
}
-(void)changeToDos:(NSArray*)toDos title:(NSString *)title save:(BOOL)save{
    for(KPToDo *toDo in toDos){
        toDo.title = title;
    }
    if(save) [self save];
}
-(void)save{
    [KPCORE saveInContext:nil];
}
-(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo scheduleForDate:date];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    [self save];
    [ANALYTICS incrementKey:NUMBER_OF_SCHEDULES_KEY withAmount:toDoArray.count];
    if(!date) [ANALYTICS incrementKey:NUMBER_OF_UNSPECIFIED_TASKS_KEY withAmount:toDoArray.count];
    [NOTIHANDLER updateLocalNotifications];
    return [movedToDos copy];
}
-(NSArray*)completeToDos:(NSArray*)toDoArray{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo complete];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    [self save];
    NSNumber *numberOfCompletedTasks = [NSNumber numberWithInteger:toDoArray.count];
    [ANALYTICS tagEvent:@"Completed Tasks" options:@{@"Number of Tasks":numberOfCompletedTasks}];
    [NOTIHANDLER updateLocalNotifications];
    [ANALYTICS incrementKey:NUMBER_OF_COMPLETED_KEY withAmount:toDoArray.count];
    return [movedToDos copy];
}




@end
