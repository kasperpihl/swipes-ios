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
-(CellType)cellTypeForCell:(CellType)type state:(MCSwipeTableViewCellState)state{
    NSInteger result = type + state;
    CellType returnValue;
    switch (result) {
        case CellTypeSchedule:
        case CellTypeToday:
        case CellTypeDone:
            if(result != type){ returnValue = result; }
            else{
                returnValue = CellTypeNone;
            }
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
