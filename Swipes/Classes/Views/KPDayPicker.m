//
//  KPDayPicker.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefSelectedColor tcolor(DoneColor)
#define kDefBackgroundColor tbackground(SearchDrawerBackground)
#define kDefFont KP_SEMIBOLD(13)
#define kDefTextColor [UIColor whiteColor]
#define kSepWidth 1
#define kSepMargin 0.0

#import "KPDayPicker.h"
#import "UIColor+Utilities.h"
#import "UIButton+PassTouch.h"
@interface KPDayPicker ()
@property (nonatomic) IBOutletCollection(UILabel) NSArray *dayButtons;
@property (nonatomic) UIButton *selectedButton;
@end
@implementation KPDayPicker
-(void)setSelectedButton:(UIButton *)selectedButton{
    if(_selectedButton != selectedButton){
        [_selectedButton setSelected:NO];
        [selectedButton setSelected:YES];
        [_selectedButton setNeedsLayout];
        [selectedButton setNeedsLayout];
        _selectedButton = selectedButton;
        self.selectedDay = selectedButton.tag;
    }
}
-(UIButton*)buttonForTouches:(NSSet*)touches{
    if (touches.count != 1) {
        return nil;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSInteger buttonIndex = (NSInteger)floorf(location.x/(self.frame.size.width/7));
    if(buttonIndex < 0) buttonIndex = 0;
    if(buttonIndex > 6) buttonIndex = 6;
    return [self.dayButtons objectAtIndex:buttonIndex];
}
-(void)handleTouches:(NSSet*)touches{
    UIButton *selectButton = [self buttonForTouches:touches];
    if(selectButton){
        self.selectedButton = selectButton;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleTouches:touches];
    [self.delegate dayPicker:self selectedWeekday:self.selectedButton.tag];
}
-(id)initWithHeight:(CGFloat)height selectedDay:(NSInteger)selectedDay{
    self = [super initWithFrame:CGRectMake(0, 0, 320, height)];
    if(self){
        self.userInteractionEnabled = YES;
        self.textColor = kDefTextColor;
        self.backgroundColor = kDefBackgroundColor;
        CGFloat buttonWidth = 45;//self.frame.size.width/7;
        NSMutableArray *buttonArray = [NSMutableArray array];
        CGFloat sepHeight = self.frame.size.height-(self.frame.size.height*kSepMargin);
        for(NSInteger i = 0 ; i < 7 ; i++){
            CGFloat buttonX = i*buttonWidth + i*kSepWidth;
            if(i == 6) buttonWidth = 44;
            UIButton *dayButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX,0,buttonWidth,self.frame.size.height)];
            [self addSubview:dayButton];
            if(i < 6){
                UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(buttonX+buttonWidth, (self.frame.size.height-sepHeight)/2, kSepWidth, sepHeight)];
                [seperator setBackgroundColor:self.textColor];
                [self addSubview:seperator];
            }
            [buttonArray addObject:dayButton];
        }
        self.dayButtons = [buttonArray copy];
        if(selectedDay < 0) selectedDay = 0;
        if(selectedDay > 6) selectedDay = 6;
        self.font = kDefFont;
        
        self.selectedColor = kDefSelectedColor;
    }
    return self;
}
-(void)layoutSubviews{
    NSInteger firstDay = [[NSCalendar currentCalendar] firstWeekday]-1;
    NSDateFormatter *weekdayFormater = [[NSDateFormatter alloc] init];
    weekdayFormater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSLog(@"firstDay:%i",firstDay);
    firstDay = 0;
    
    NSArray *weekdays = [weekdayFormater shortWeekdaySymbols];
    NSLog(@"weekdays:%@",weekdays);
    for(NSInteger i = 0 ; i < 7 ; i++){
        NSInteger day = (i + firstDay) % 7;
        NSLog(@"day:%i",day);
        UIButton *dayButton = [self.dayButtons objectAtIndex:i];
        [dayButton setBackgroundImage:[self.selectedColor image] forState:UIControlStateSelected];
        [dayButton setBackgroundImage:[self.selectedColor image] forState:UIControlStateSelected|UIControlStateHighlighted];
        dayButton.tag = day;
        [dayButton setTitle:[[weekdays objectAtIndex:day] uppercaseString] forState:UIControlStateNormal];
        [dayButton setTitleColor:self.textColor forState:UIControlStateNormal];
        [dayButton.titleLabel setFont:self.font];
        if(day == self.selectedDay) self.selectedButton = dayButton;
        
    }
}
@end
