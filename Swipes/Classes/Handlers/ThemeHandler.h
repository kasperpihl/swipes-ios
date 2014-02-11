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
#define tcolor(ThemerItem) [THEMER colorForItem:ThemerItem forceTheme:ThemeNone]
#define tcolorF(ThemerItem) [THEMER colorForItem:ThemerItem force:YES]
#define timageString(ImageString,DarkEnding,LightEnding) [THEMER imageString:ImageString darkEnding:DarkEnding lightEnding:LightEnding]
typedef enum {
    ThemeNone = 0,
    ThemeDark = 1,
    ThemeLight = 2
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
-(UIColor*)colorForItem:(ThemerItem)item forceTheme:(Theme)theme;
-(UIFont *)fontForItem:(ThemerItem)item;
-(void)changeTheme;
-(UIImage*)imageStringForBase:(NSString*)imageBase darkEnding:(NSString*)darkEnding lightEnding:(NSString*)lightEnding;
@end
