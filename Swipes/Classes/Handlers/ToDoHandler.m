//
//  ToDoHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoHandler.h"

@implementation ToDoHandler
static ToDoHandler *sharedObject;
+(ToDoHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[ToDoHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)save{
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}
-(void)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date{
    for(KPToDo *toDo in toDoArray){
        [toDo scheduleForDate:date];
    }
    [self save];
}
-(void)completeToDos:(NSArray*)toDoArray{
    for(KPToDo *toDo in toDoArray){
        [toDo complete];
    }
    [self save];
}
-(void)setForTodayToDos:(NSArray *)toDoArray{
    for(KPToDo *toDo in toDoArray){
        [toDo setForToday];
    }
    [self save];
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
            returnColor = SWIPES_BLUE;
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
            iconName = @"clock";
            break;
        case CellTypeToday:
            iconName = @"list";
            break;
        case CellTypeDone:
            iconName = @"check";
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
