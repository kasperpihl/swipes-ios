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
    ThemeDark = 0,
    ThemeLight = 1
} Theme;

typedef enum {
    TextColor,
    TasksColor,
    LaterColor,
    DoneColor,
    StrongTasksColor,
    StrongLaterColor,
    StrongDoneColor,
    
    TextFieldColor,
    TaskCellTimelineColor,
    TaskCellTitle,
    TagColor
    
} ThemerItem;

typedef enum {
    BackgroundColor,
    MenuBackground,
    MenuSelectedBackground,
    SearchDrawerBackground,
    
    
    TagBackground,
    TagSelectedBackground,
    AlertBackground,
    LoginBackground,
    LoginButtonBackground
} Background;

@interface ThemeHandler : NSObject
@property (nonatomic) Theme currentTheme;
+(ThemeHandler*)sharedInstance;
-(UIColor*)colorForBackground:(Background)background;
-(UIColor*)colorForItem:(ThemerItem)item;
-(UIFont *)fontForItem:(ThemerItem)item;
-(void)changeTheme;
@end
