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
    TasksColor,
    LaterColor,
    DoneColor,
    StrongTasksColor,
    StrongLaterColor,
    StrongDoneColor,
    
    SeperatorColor,
    
    SearchDrawerColor,
    TextFieldColor,
    TaskTableEmptyText,
    TaskCellTimelineColor,
    TaskCellTitle,
    TaskCellTagColor,
    TagColor
    
} ThemerItem;

typedef enum {
    MenuBackground,
    MenuSelectedBackground,
    SearchDrawerBackground,
    TaskTableBackground,
    TaskTableGradientBackground,
    TaskCellBackground,
    TaskCellSelectedBackground,
    
    TagBackground,
    ToolbarBackground,
    TagSelectedBackground,
    EditTaskBackground,
    EditTaskTitleBackground,
    AlertBackground,
    LoginBackground,
    LoginButtonBackground,
    PopupBackground
} Background;

@interface ThemeHandler : NSObject
@property (nonatomic) Theme currentTheme;
+(ThemeHandler*)sharedInstance;
-(UIColor*)colorForBackground:(Background)background;
-(UIColor*)colorForItem:(ThemerItem)item;
-(UIFont *)fontForItem:(ThemerItem)item;
-(void)changeTheme;
@end
