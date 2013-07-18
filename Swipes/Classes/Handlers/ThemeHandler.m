//
//  ThemeHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 16/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ThemeHandler.h"
@implementation ThemeHandler
static ThemeHandler *sharedObject;
+(ThemeHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[ThemeHandler allocWithZone:NULL] init];
        sharedObject.currentTheme = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme"];
    }
    return sharedObject;
}
-(void)changeTheme{
    Theme newTheme = (self.currentTheme == ThemeDark) ? ThemeLight : ThemeDark;
    [[NSUserDefaults standardUserDefaults] setInteger:newTheme forKey:@"theme"];
    self.currentTheme = newTheme;
}
-(UIColor*)colorForBackground:(Background)background{
    switch (background) {
        case MenuBackground:
            return MENU_BACKGROUND;
        case MenuSelectedBackground:
            return MENU_SELECTED_BACKGROUND;
        case TaskCellBackground:
            return TASK_CELL_BACKGROUND;
        case TaskTableSectionHeaderBackground:
            return TASK_TABLE_SECTION_BACKGROUND;
        case TagSelectedBackground:
            return [self colorForItem:MenuItemTasks];
        case TaskTableBackground:
            return [self colorForBackground:TaskTableSectionHeaderBackground];
        case TagBackground:
            return [self colorForBackground:MenuSelectedBackground];
        case TagBarBackground:
            return [self colorForBackground:MenuBackground];
        case AlertBackground:
            return [self colorForBackground:MenuBackground];
        case LoginBackground:
            return [self colorForBackground:MenuBackground];
        case LoginButtonBackground:
            return [self colorForBackground:TaskCellBackground];
        case EditTaskBackground:
            return [self colorForBackground:TaskCellBackground];
        case EditTaskTitleBackground:
            return [self colorForBackground:MenuSelectedBackground];
        default:
            break;
    }
    return nil;
}
-(UIColor*)colorForItem:(ThemerItem)item{
    switch (item) {
        case MenuItemTasks:
            return TASKS_COLOR;
        case MenuItemDone:
            return DONE_COLOR;
        case MenuItemLater:
            return LATER_COLOR;
        case TaskCellTimelineColor:
            return [self colorForBackground:MenuSelectedBackground];
        case ColoredSeperator:
            return [self colorForItem:MenuItemTasks];
        case ColoredButton:
            return [self colorForItem:MenuItemTasks];
        case TaskTableEmptyText:
            return [self colorForBackground:TaskCellBackground];
        case TaskTableEmptyTodayText:
            return [self colorForItem:MenuItemTasks];
        default:
            break;
    }
    return nil;
}

-(UIFont *)fontForItem:(ThemerItem)item{
    return nil;
}
+(UIColor *)inverseColor:(UIColor*)color {
    
    CGColorRef oldCGColor = color.CGColor;
    
    int numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    // can not invert - the only component is the alpha
    // e.g. self == [UIColor groupTableViewBackgroundColor]
    if (numberOfComponents == 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    int i = numberOfComponents - 1;
    newComponentColors[i] = oldComponentColors[i]; // alpha
    while (--i >= 0) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    return newColor;
}
@end
