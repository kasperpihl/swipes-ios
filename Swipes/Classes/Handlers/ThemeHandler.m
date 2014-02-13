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

#define TASKS_COLOR                     retColor(color(228,202,92,1),   color(244,203,28,1))
#define DONE_COLOR                      color(69,217,132,1)  //color(63,186,141,1) //
#define LATER_COLOR                     color(254,115,103,1) // color(234,97,80,1)

#define STRONG_TASKS_COLOR              color(228,192,21,1)
#define STRONG_DONE_COLOR               color(58,195,160,1)
#define STRONG_LATER_COLOR              color(255,96,69,1)

#define TEXT_COLOR                      retColor(color(255,255,255,1),      gray(0,1))
#define SUB_TEXT_COLOR                  retColor(gray(170,1),               inv(gray(170,1)))
#define BACKGROUND                      retColor(color(36,40,46,1),         gray(255,1))

#import "ThemeHandler.h"
#import "RootViewController.h"
#import <ASCScreenBrightnessDetector/ASCScreenBrightnessDetector.h>
@interface ThemeHandler () <ASCScreenBrightnessDetectorDelegate>
@property (nonatomic) ASCScreenBrightnessDetector *brightnessDetector;
@end

@implementation ThemeHandler
static ThemeHandler *sharedObject;
+(ThemeHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[ThemeHandler allocWithZone:NULL] init];
        sharedObject.currentTheme = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme"];
        [sharedObject brightnessDetector];
    }
    return sharedObject;
}
-(ASCScreenBrightnessDetector *)brightnessDetector{
    if(!_brightnessDetector){
        _brightnessDetector = [ASCScreenBrightnessDetector new];
        _brightnessDetector.delegate = self;
        _brightnessDetector.threshold = 0.3;
    }
    return _brightnessDetector;
}

- (void)screenBrightnessStyleDidChange:(ASCScreenBrightnessStyle)style
{
    /*NSLog(@"The new style is: %u", style);
    if((self.currentTheme == ThemeDark && style == ASCScreenBrightnessStyleLight) || (self.currentTheme == ThemeLight && style == ASCScreenBrightnessStyleDark)){
        [UIView animateWithDuration:0.3 animations:^{
            [self changeTheme];
            [ROOT_CONTROLLER resetRoot];
        }];
    }*/
}
-(void)setCurrentTheme:(Theme)currentTheme{
    NSLog(@"theme:%i",currentTheme);
    if(currentTheme != ThemeLight && currentTheme != ThemeDark) currentTheme = ThemeDark;
    _currentTheme = currentTheme;
    [[NSUserDefaults standardUserDefaults] setInteger:currentTheme forKey:@"theme"];
}
-(void)changeTheme{
    Theme newTheme = (self.currentTheme == ThemeDark) ? ThemeLight : ThemeDark;
    [[NSUserDefaults standardUserDefaults] setInteger:newTheme forKey:@"theme"];
    self.currentTheme = newTheme;
}
-(UIColor*)colorForItem:(ThemerItem)item forceTheme:(Theme)theme{
    switch (item) {
        case BackgroundColor:
            return BACKGROUND;
        case TextColor:
            return TEXT_COLOR;
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
    NSString *imageString = [imageBase stringByAppendingFormat:@"_%@",imageEnding];
    return imageString;
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
