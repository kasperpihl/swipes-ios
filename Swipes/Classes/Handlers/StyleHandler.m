//
//  StyleHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "StyleHandler.h"

@implementation StyleHandler
+(MCSwipeTableViewCellActivatedDirection)directionForCellType:(CellType)type{
    MCSwipeTableViewCellActivatedDirection direction = MCSwipeTableViewCellActivatedDirectionBoth;
    if(type == CellTypeDone) direction = MCSwipeTableViewCellActivatedDirectionLeft;
    return direction;
}
+(CellType)cellTypeForCell:(CellType)type state:(MCSwipeTableViewCellState)state{
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
+(UIColor *)colorForCellType:(CellType)type{
    UIColor *returnColor;
    switch (type) {
        case CellTypeSchedule:
            returnColor = tcolor(LaterColor);
            break;
        case CellTypeToday:
            returnColor = tcolor(TasksColor);
            break;
        case CellTypeDone:
            returnColor = tcolor(DoneColor);
            break;
        default:
            break;
    }
    return returnColor;
}
+(UIColor *)strongColorForCellType:(CellType)type{
    UIColor *returnColor;
    switch (type) {
        case CellTypeSchedule:
            returnColor = tcolor(StrongLaterColor);
            break;
        case CellTypeToday:
            returnColor = tcolor(StrongTasksColor);
            break;
        case CellTypeDone:
            returnColor = tcolor(StrongDoneColor);
            break;
        default:
            break;
    }
    return returnColor;
}
+(NSString *)iconNameForCellType:(CellType)type{
    NSString *iconName;
    switch (type) {
        case CellTypeSchedule:
            iconName = @"schedule-selected";
            break;
        case CellTypeToday:
            iconName = @"today-selected";
            break;
        case CellTypeDone:
            iconName = @"done-selected";
            break;
        default:
            break;
    }
    return iconName;
}
+(NSString *)stateForCellType:(CellType)type{
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
