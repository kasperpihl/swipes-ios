//
//  ThemeHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 16/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define retColor(DarkColor,LightColor) retColorF(DarkColor,LightColor,ThemeNone)
#define retColorF(DarkColor,LightColor,Theme) (((Theme ? Theme : THEMER.currentTheme) == ThemeDark) ? DarkColor : LightColor)
#define THEMER [ThemeHandler sharedInstance]
#define tfont(ThemerItem) [THEMER fontForItem:ThemerItem]
#define tcolor(ThemerItem) tcolorF(ThemerItem,ThemeNone)
#define tcolorF(ThemerItem,Theme) [THEMER colorForItem:ThemerItem forceTheme:Theme]
#define timageString(ImageBase,DarkEnding,LightEnding) timageStringF(ImageBase,DarkEnding,LightEnding,ThemeNone)
#define timageStringBW(ImageBase) timageStringF(ImageBase,@"_white",@"_black",ThemeNone)
#define timageStringF(ImageBase,DarkEnding,LightEnding,Theme) [THEMER imageStringForBase:ImageBase darkEnding:DarkEnding lightEnding:LightEnding forceTheme:Theme]
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
-(Theme)oppositTheme;
-(NSString*)imageStringForBase:(NSString*)imageBase darkEnding:(NSString*)darkEnding lightEnding:(NSString*)lightEnding forceTheme:(Theme)theme;
@end
