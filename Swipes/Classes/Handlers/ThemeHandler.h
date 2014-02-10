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
typedef enum {
    ThemeDark = 0,
    ThemeLight = 1
} Theme;

typedef enum {
    BackgroundColor,
    TextColor,
    SubTextColor,
    
    TasksColor,
    LaterColor,
    DoneColor,
    
    StrongTasksColor,
    StrongLaterColor,
    StrongDoneColor,
    
} ThemerItem;

@interface ThemeHandler : NSObject
@property (nonatomic) Theme currentTheme;
+(ThemeHandler*)sharedInstance;
-(UIColor*)colorForItem:(ThemerItem)item;
-(UIFont *)fontForItem:(ThemerItem)item;
-(void)changeTheme;
@end
