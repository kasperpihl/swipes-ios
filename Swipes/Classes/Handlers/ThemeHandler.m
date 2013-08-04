//
//  ThemeHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 16/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
/* Main colors */
#define retColor(DarkColor,LightColor) ((THEMER.currentTheme == ThemeDark) ? DarkColor : LightColor)
#define inv(color) [ThemeHandler inverseColor:color]

#define TASKS_COLOR                     color(255,227,64,1)
#define DONE_COLOR                      color(63,186,141,1)
#define LATER_COLOR                     color(254,115,103,1)

#define STRONG_TASKS_COLOR              color(228,192,21,1)
#define STRONG_DONE_COLOR                color(45,141,115,1)
#define STRONG_LATER_COLOR              color(254,69,52,1)

/* Backgrounds */
#define MENU_BACKGROUND                 retColor(color(44,50,59,1),         inv(color(44,50,59,1)))
#define MENU_SELECTED_BACKGROUND        retColor(color(80,90,104,1),        inv(color(80,90,104,1)))
#define SEARCH_DRAWER_BACKGROUND        retColor(color(69,77,89,1),         inv(color(69,77,89,1)))
#define TASK_TABLE_BACKGROUND           retColor(color(106,117,131,1),      inv(color(106,117,131,1)))
#define TASK_TABLE_GRADIENT_BACKGROUND  retColor(color(132,143,156,1),      inv(color(132,143,156,1)))
/* Texts */
#define SEARCH_DRAWER_COLOR             retColor(color(189,194,201,1),      inv(color(189,194,201,1)))
#define TASK_CELL_TAG_COLOR             retColor(color(160,169,179,1),      inv(color(160,169,179,1)))
#define TEXT_FIELD_COLOR                retColor(color(176,179,184,1),      inv(color(176,179,184,1)))
typedef enum {
    BCTasksColor,
    BCLaterColor,
    BCDoneColor,
    BCStrongTasksColor,
    BCStrongLaterColor,
    BCStrongDoneColor,
    BCMenuBackground,
    BCMenuSelectedBackground,
    BCSearchDrawerBackground,
    BCTaskTableBackground,
    BCTaskTableGradientBackground,
    BCSearchDrawerColor,
    BCTaskCellTagColor,
    BCTextFieldColor,
    BCWhiteColor
} BaseColors;

#define bcolor(basecolor) [self colorForBase:basecolor]
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
-(UIColor *)colorForBase:(BaseColors)baseColor{
    switch (baseColor) {
        case BCTasksColor:
            return TASKS_COLOR;
        case BCLaterColor:
            return LATER_COLOR;
        case BCDoneColor:
            return DONE_COLOR;
        case BCStrongTasksColor:
            return STRONG_TASKS_COLOR;
        case BCStrongDoneColor:
            return STRONG_DONE_COLOR;
        case BCStrongLaterColor:
            return STRONG_LATER_COLOR;
        case BCMenuBackground:
            return MENU_BACKGROUND;
        case BCMenuSelectedBackground:
            return MENU_SELECTED_BACKGROUND;
        case BCSearchDrawerBackground:
            return SEARCH_DRAWER_BACKGROUND;
        case BCTaskTableBackground:
            return TASK_TABLE_BACKGROUND;
        case BCTaskTableGradientBackground:
            return TASK_TABLE_GRADIENT_BACKGROUND;
        case BCSearchDrawerColor:
            return SEARCH_DRAWER_COLOR;
        case BCTaskCellTagColor:
            return TASK_CELL_TAG_COLOR;
        case BCTextFieldColor:
            return TEXT_FIELD_COLOR;
        case BCWhiteColor:
            return [UIColor whiteColor];
    }
    return nil;
}
-(UIColor*)colorForBackground:(Background)background{
    BaseColors color;
    switch (background) {
        case MenuBackground:
        case ToolbarBackground:
        case AlertBackground:
        case LoginBackground:
            color = BCMenuBackground;
            break;
            
        case TagBackground:
        case MenuSelectedBackground:
        case TaskCellBackground:
        case EditTaskBackground:
        case LoginButtonBackground:
            color = BCMenuSelectedBackground;
            break;
            
        case PopupBackground:
            return alpha(bcolor(BCTaskTableBackground), 0.5);
            break;
            
        case SearchDrawerBackground:
        case EditTaskTitleBackground:
        case TaskTableBackground:
        case TaskCellSelectedBackground:
            color = BCSearchDrawerBackground;
            break;
        
        case TagSelectedBackground:
            color = BCDoneColor;
            break;
        case TaskTableGradientBackground:
            color = BCTaskTableGradientBackground;
            break;
        case TimePickerWheelBackground:
            color = BCTaskCellTagColor;
            break;
    }
    return bcolor(color);
}
-(UIColor*)colorForItem:(ThemerItem)item{
    BaseColors color;
    switch (item) {
        case SeperatorColor:
            color = BCTaskTableGradientBackground;
            break;
        case TasksColor:
            color = BCTasksColor;
            break;
            
        case DoneColor:
            color = BCDoneColor;
            break;
        
        case StrongDoneColor:
            color = BCStrongDoneColor;
            break;
            
        case LaterColor:
            color = BCLaterColor;
            break;
        
        case StrongLaterColor:
            color = BCStrongLaterColor;
            break;
            
        case StrongTasksColor:
            color = BCStrongTasksColor;
            break;
            
        case TaskCellTimelineColor:
            color = BCSearchDrawerBackground;
            break;
            
        case TextFieldColor:
            color = BCTextFieldColor;
            break;
            
        case SearchDrawerColor:
        case TaskTableEmptyText:
        case TaskCellTagColor:
            color = BCSearchDrawerColor;
            break;
        
        case TagColor:
        case TaskCellTitle:
            color = BCWhiteColor;
            break;
        
    }
    return bcolor(color);
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