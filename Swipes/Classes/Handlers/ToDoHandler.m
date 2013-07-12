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
    for(KPToDo *toDo in toDos){
        [toDo deleteToDoSave:NO];
    }
    if(save) [self save];
    [ANALYTICS incrementKey:NUMBER_OF_DELETED_TASKS_KEY withAmount:toDos.count];
}
-(KPToDo*)addItem:(NSString *)item{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.schedule = [NSDate date];
    newToDo.state = @"scheduled";
    NSNumber *count = [KPToDo MR_numberOfEntities];
    newToDo.order = count;
    [self save];
    [ANALYTICS incrementKey:NUMBER_OF_ADDED_TASKS_KEY withAmount:1];
    return newToDo;
}
-(void)changeToDos:(NSArray*)toDos title:(NSString *)title save:(BOOL)save{
    for(KPToDo *toDo in toDos){
        toDo.title = title;
    }
    if(save) [self save];
}
-(void)save{
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}
-(void)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date{
    for(KPToDo *toDo in toDoArray){
        [toDo scheduleForDate:date];
    }
    [self save];
    [ANALYTICS incrementKey:NUMBER_OF_SCHEDULES_KEY withAmount:toDoArray.count];
    if(!date) [ANALYTICS incrementKey:NUMBER_OF_UNSPECIFIED_TASKS_KEY withAmount:toDoArray.count];
    
}
-(void)completeToDos:(NSArray*)toDoArray{
    for(KPToDo *toDo in toDoArray){
        [toDo complete];
    }
    [self save];
    [ANALYTICS incrementKey:NUMBER_OF_COMPLETED_KEY withAmount:toDoArray.count];
}
-(MCSwipeTableViewCellActivatedDirection)directionForCellType:(CellType)type{
    MCSwipeTableViewCellActivatedDirection direction = MCSwipeTableViewCellActivatedDirectionBoth;
    if(type == CellTypeDone) direction = MCSwipeTableViewCellActivatedDirectionLeft;
    return direction;
}
-(CellType)cellTypeForCell:(CellType)type state:(MCSwipeTableViewCellState)state{
    if(state == MCSwipeTableViewCellStateNone) return CellTypeNone;
    NSInteger result = type + state;
    if(type == CellTypeSchedule && (result == type-1)) result = CellTypeSchedule;
    CellType returnValue;
    switch (result) {
        case CellTypeSchedule:
        case CellTypeToday:
        case CellTypeDone:
            returnValue = result;
            break;
        default:
            returnValue = CellTypeNone;
            break;
    }
    return returnValue;
}
-(UIColor *)colorForCellType:(CellType)type{
    UIColor *returnColor;
    switch (type) {
        case CellTypeSchedule:
            returnColor = SCHEDULE_COLOR;
            break;
        case CellTypeToday:
            returnColor = TODAY_COLOR;
            break;
        case CellTypeDone:
            returnColor = DONE_COLOR;
            break;
        default:
            break;
    }
    return returnColor;
}
-(NSString *)iconNameForCellType:(CellType)type{
    NSString *iconName;
    switch (type) {
        case CellTypeSchedule:
            iconName = @"schedule_icon";
            break;
        case CellTypeToday:
            iconName = @"today_icon";
            break;
        case CellTypeDone:
            iconName = @"done_icon";
            break;
        default:
            break;
    }
    return iconName;
}
-(NSString *)coloredIconNameForCellType:(CellType)type{
    NSString *iconName;
    switch (type) {
        case CellTypeSchedule:
            iconName = @"edit_schedule_icon";
            break;
        case CellTypeToday:
            iconName = @"edit_today_icon";
            break;
        case CellTypeDone:
            iconName = @"edit_done_icon";
            break;
        default:
            break;
    }
    return iconName;
}
-(NSString *)stateForCellType:(CellType)type{
    NSString *state;
    switch (type) {
        case CellTypeSchedule:
            state = @"schedule";
            break;
        case CellTypeToday:
            state = @"today";
            break;
        case CellTypeDone:
            state = @"done";
            break;
        default:
            break;
    }
    return state;
}
@end
