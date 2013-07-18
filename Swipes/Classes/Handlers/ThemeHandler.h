//
//  ThemeHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 16/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define THEMER [ThemeHandler sharedInstance]
#define tfont(ThemerItem) [THEMER fontForItem:ThemerItem]
#define tcolor(ThemerItem) [THEMER colorForItem:ThemerItem]
#define tbackground(background) [THEMER colorForBackground:background]
typedef enum {
    ThemeDark = 1,
    ThemeLight = 2
} Theme;
typedef enum {
    MenuItemTasks,
    MenuItemLater,
    MenuItemDone,
    TaskTableEmptyText,
    TaskTableEmptyTodayText,
    TaskCellTimelineColor,
    ColoredSeperator,
    ColoredButton,
} ThemerItem;
typedef enum {
    MenuBackground,
    MenuSelectedBackground,
    TaskTableBackground,
    TaskTableSectionHeaderBackground,
    TaskCellBackground,
    TaskCellSelectedBackground,
    TagBackground,
    TagBarBackground,
    TagSelectedBackground,
    EditTaskBackground,
    EditTaskTitleBackground,
    AlertBackground,
    LoginBackground,
    LoginButtonBackground
} Background;

@interface ThemeHandler : NSObject
@property (nonatomic) Theme currentTheme;
+(ThemeHandler*)sharedInstance;
+(UIColor *)inverseColor:(UIColor*)color;
-(UIColor*)colorForBackground:(Background)background;
-(UIColor*)colorForItem:(ThemerItem)item;
-(UIFont *)fontForItem:(ThemerItem)item;
-(void)changeTheme;
@end
