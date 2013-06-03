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
@interface ToDoHandler ()
@property (nonatomic) NSMutableArray *handleNotifications;
@end
@implementation ToDoHandler
-(NSMutableArray *)handleNotifications{
    if(!_handleNotifications) _handleNotifications = [NSMutableArray array];
    return _handleNotifications;
}
-(void)handleNotificationsForDate:(NSDate *)date{
    NSDate *startDate = [date dateAtStartOfDay];
    if(![self.handleNotifications containsObject:startDate]) [self.handleNotifications addObject:startDate];
}
static ToDoHandler *sharedObject;
+(ToDoHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[ToDoHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)addItem:(NSString *)item{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.schedule = [NSDate date];
    newToDo.state = @"scheduled";
    NSNumber *count = [KPToDo MR_numberOfEntities];
    newToDo.order = count;
    [self save];
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
-(void)scheduleNotifications{
    for(NSDate *date in self.handleNotifications){
        NSDate *nextDate = [[date dateByAddingDays:1] dateAtStartOfDay];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@) AND (schedule >= %@) AND (schedule < %@)",@"scheduled", date, nextDate];
        NSInteger counter = [KPToDo MR_countOfEntitiesWithPredicate:predicate];
        [NOTIHANDLER scheduleNumberOfTasks:counter forDate:date];
    }
    self.handleNotifications = nil;
}
-(void)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date{
    for(KPToDo *toDo in toDoArray){
        if(toDo.schedule){
            [self handleNotificationsForDate:toDo.schedule];
        }
        [toDo scheduleForDate:date];
    }
    if(date){
        [self handleNotificationsForDate:date];
    }
    [self save];
    [self scheduleNotifications];
}
-(void)completeToDos:(NSArray*)toDoArray{
    for(KPToDo *toDo in toDoArray){
        if(toDo.schedule) [self handleNotificationsForDate:toDo.schedule];
        [toDo complete];
    }
    [self save];
    [self scheduleNotifications];
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
            iconName = @"schedule";
            break;
        case CellTypeToday:
            iconName = @"today";
            break;
        case CellTypeDone:
            iconName = @"done";
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
