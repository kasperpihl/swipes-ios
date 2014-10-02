//
//  ThemeHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 16/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
/* Main colors */

#define inv(color) [ThemeHandler inverseColor:color]

#define TASKS_COLOR                    color(255,200,94,1) //color(244,203,28,1) //color(237,194,0,1)
#define DONE_COLOR                     color(134,211,110,1) // color(69,217,132,1)  //color(63,186,141,1) //
#define LATER_COLOR                     color(255,86,55,1) //color(252,97,75,1) // color(234,97,80,1)

#define STRONG_TASKS_COLOR              color(255,195,88,1)
#define STRONG_DONE_COLOR               color(58,195,160,1)
#define STRONG_LATER_COLOR              color(255,96,69,1)

#define TEXT_COLOR(Theme)               retColorF(color(248,248,249,1), color(27,30,35,1), Theme)
#define SUB_TEXT_COLOR                  retColor(color(189,191,193,1),               color(95,97,99,1))
#define BACKGROUND(Theme)               retColorF(color(27,30,35,1),     color(248,248,249,1),Theme) //retColorF(color(36,40,46,1),     gray(255,1),Theme)
//color(226,231,233,1)

#import "ThemeHandler.h"
@interface ThemeHandler ()
//@property (nonatomic) ASCScreenBrightnessDetector *brightnessDetector;
@end

@implementation ThemeHandler
static ThemeHandler *sharedObject;
+(ThemeHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[ThemeHandler allocWithZone:NULL] init];
        sharedObject.currentTheme = [USER_DEFAULTS integerForKey:@"theme"];
    }
    return sharedObject;
}

-(Theme)oppositTheme{
    return (self.currentTheme == ThemeDark) ? ThemeLight : ThemeDark;
}

-(void)setCurrentTheme:(Theme)currentTheme{
    if(currentTheme != ThemeLight && currentTheme != ThemeDark) currentTheme = ThemeLight;
    _currentTheme = currentTheme;
    [USER_DEFAULTS setInteger:currentTheme forKey:@"theme"];
    [USER_DEFAULTS synchronize];
    
    if(OSVER >= 7){
        [[UITextField appearance] setTintColor:tcolor(TextColor)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changed theme" object:nil];
}
-(void)changeTheme{
    Theme newTheme = (self.currentTheme == ThemeDark) ? ThemeLight : ThemeDark;
    self.currentTheme = newTheme;
}
-(UIColor*)colorForItem:(ThemerItem)item forceTheme:(Theme)theme{
    switch (item) {
        case BackgroundColor:
            return BACKGROUND(theme);
        case TextColor:
            return TEXT_COLOR(theme);
        case SubTextColor:
            return SUB_TEXT_COLOR;
            
        case TasksColor:
            return TASKS_COLOR;
        case LaterColor:
            return LATER_COLOR;
        case DoneColor:
            return DONE_COLOR;
        
        case StrongTasksColor:
            return STRONG_TASKS_COLOR;
        case StrongLaterColor:
            return STRONG_LATER_COLOR;
        case StrongDoneColor:
            return STRONG_DONE_COLOR;
        
    }
    return nil;
}
-(NSString *)imageStringForBase:(NSString *)imageBase darkEnding:(NSString *)darkEnding lightEnding:(NSString *)lightEnding forceTheme:(Theme)theme{
    NSString *imageEnding = (self.currentTheme == ThemeDark) ? darkEnding : lightEnding;
    NSString *imageString = [imageBase stringByAppendingFormat:@"%@",imageEnding];
    return imageString;
}
-(UIFont *)fontForItem:(ThemerItem)item{
    return nil;
}
+(UIColor *)inverseColor:(UIColor*)color {
    
    CGColorRef oldCGColor = color.CGColor;
    
    NSInteger numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    // can not invert - the only component is the alpha
    // e.g. self == [UIColor groupTableViewBackgroundColor]
    if (numberOfComponents == 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    NSInteger i = numberOfComponents - 1;
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
