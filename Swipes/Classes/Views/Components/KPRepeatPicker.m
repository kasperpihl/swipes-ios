//
//  KPDayPicker.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefSelectedColor tcolor(TasksColor)
#define kDefBackgroundColor CLEAR
#define kDefFont KP_REGULAR(13)
#define kDefTextColor tcolor(TextColor)
#define kDefSelTextColor tcolorF(TextColor,ThemeLight)
#define kSepWidth 1
#define kDefSeperatorColor color(161,163,165,1)
#define kSepMargin 0.0

#import "KPRepeatPicker.h"
#import "UIColor+Utilities.h"
#import "UIButton+PassTouch.h"
#import "NSDate-Utilities.h"
//#import "UIView+Utilities.h"
@interface KPRepeatPicker ()
@property (nonatomic) IBOutletCollection(UILabel) NSArray *optionsButtons;
@property (nonatomic) IBOutletCollection(UIView) NSArray *seperators;
@property (nonatomic) UIButton *selectedButton;
@property (nonatomic) NSInteger numberOfOptions;
@end
@implementation KPRepeatPicker
-(void)setSelectedButton:(UIButton *)selectedButton{
    if(_selectedButton != selectedButton){
        [_selectedButton setSelected:NO];
        [selectedButton setSelected:YES];
        [_selectedButton setNeedsLayout];
        [selectedButton setNeedsLayout];
        _selectedButton = selectedButton;
        self.currentOption = selectedButton.tag;
        [self setNeedsLayout];
        //self.selectedDay = selectedButton.tag;
    }
}
-(void)setSelectedDate:(NSDate *)selectedDate option:(RepeatOptions)option{
    self.currentOption = option;
    self.selectedDate = selectedDate;
    [self setNeedsLayout];
}
-(UIButton*)buttonForTouches:(NSSet*)touches{
    if (touches.count != 1) {
        return nil;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSInteger lastIndex = self.numberOfOptions - 1;
    NSInteger buttonIndex = (NSInteger)floorf(location.x/(self.frame.size.width/self.numberOfOptions));
    if (buttonIndex < 0)
        buttonIndex = 0;
    if (buttonIndex > lastIndex)
        buttonIndex = lastIndex;
    return [self.optionsButtons objectAtIndex:buttonIndex];
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
    [self.delegate repeatPicker:self selectedOption:self.selectedButton.tag];
}
-(id)initWithWidth:(CGFloat)width height:(CGFloat)height selectedDate:(NSDate *)date option:(RepeatOptions)option{
    self = [super initWithFrame:CGRectMake(0, 0, width, height)];
    if(self){
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.numberOfOptions = RepeatOptionsTotal;
        self.userInteractionEnabled = YES;
        self.textColor = kDefTextColor;
        self.backgroundColor = kDefBackgroundColor;
        CGFloat buttonWidth = floorf(self.frame.size.width/self.numberOfOptions);
        NSMutableArray *buttonArray = [NSMutableArray array];
        NSMutableArray *seperatorArray = [NSMutableArray array];
        CGFloat sepHeight = self.frame.size.height-(self.frame.size.height*kSepMargin);
        for(NSInteger i = 0 ; i < self.numberOfOptions ; i++){
            CGFloat buttonX = i*buttonWidth + i*kSepWidth;
            UIButton *dayButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, 0 , buttonWidth,self.frame.size.height)];
            dayButton.titleLabel.numberOfLines = 0;
            //dayButton.titleLabel.frame = dayButton.bounds;
            //dayButton.titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
            //dayButton.transform = CGAffineTransformMakeRotation(-M_PI/2);
            dayButton.frame = CGRectMake(buttonX, 0, buttonWidth,self.frame.size.height);
            dayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:dayButton];
            if(i < 6){
                UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(buttonX+buttonWidth, (self.frame.size.height-sepHeight)/2, kSepWidth, sepHeight)];
                [seperator setBackgroundColor:kDefSeperatorColor];
                [self addSubview:seperator];
                [seperatorArray addObject:seperator];
            }
            [buttonArray addObject:dayButton];
        }
        self.optionsButtons = [buttonArray copy];
        self.seperators = [seperatorArray copy];
        self.font = kDefFont;
        self.selectedDate = date;
        self.currentOption = option;
        self.selectedColor = kDefSelectedColor;
//        [self layoutSubviews];
    }
    return self;
}
-(NSString*)stringForOption:(RepeatOptions)option{
    NSString *buttonString;
    switch (option) {
        case RepeatNever:
            buttonString = NSLocalizedString(@"never", nil);
            break;
        case RepeatEveryDay:
            buttonString = NSLocalizedString(@"day", nil);
            break;
        case RepeatEveryMonFriOrSatSun:
            if([self.selectedDate isTypicallyWorkday]) buttonString = NSLocalizedString(@"mon-fri", nil);
            else buttonString = NSLocalizedString(@"sat+sun", nil);
        break;
        case RepeatEveryWeek:
            buttonString = NSLocalizedString(@"week", nil);
            break;
        case RepeatEveryMonth:
            buttonString = NSLocalizedString(@"month", nil);
            break;
        case RepeatEveryYear:
            buttonString = NSLocalizedString(@"year", nil);
            break;
        default:
            break;
    }
    return buttonString;
}
-(void)layoutSubviews{
    CGFloat buttonWidth = floorf(self.frame.size.width/self.numberOfOptions);
    CGFloat sepHeight = self.frame.size.height-(self.frame.size.height*kSepMargin);
    for(NSInteger i = 0 ; i < self.numberOfOptions ; i++){
        UIButton *dayButton = [self.optionsButtons objectAtIndex:i];
        
        CGFloat buttonX = i*buttonWidth + i*kSepWidth;
        dayButton.frame = CGRectMake(buttonX, 0 , buttonWidth,self.frame.size.height);
        if (i < 6){
            UIView *seperator = self.seperators[i];
            seperator.frame = CGRectMake(buttonX + buttonWidth, (self.frame.size.height-sepHeight) / 2, kSepWidth, sepHeight);
        }
        
        [dayButton setBackgroundImage:[self.selectedColor image] forState:UIControlStateSelected];
        [dayButton setBackgroundImage:[self.selectedColor image] forState:UIControlStateSelected|UIControlStateHighlighted];
        dayButton.tag = i;
        [dayButton setTitle:[self stringForOption:i] forState:UIControlStateNormal];
        [dayButton setTitleColor:self.textColor forState:UIControlStateNormal];
        [dayButton setTitleColor:kDefSelTextColor forState:UIControlStateSelected];
        [dayButton setTitleColor:kDefSelTextColor forState:UIControlStateHighlighted];
        [dayButton setTitleColor:kDefSelTextColor forState:UIControlStateHighlighted|UIControlStateSelected];
        [dayButton.titleLabel setFont:self.font];
        NSInteger sep1index = i-1;
        NSInteger sep2index = i;
        UIView *sep1, *sep2;
        if(sep1index >= 0 && sep1index < self.seperators.count)
            sep1 = [self.seperators objectAtIndex:sep1index];
        if(sep2index >= 0 && sep2index < self.seperators.count)
            sep2 = [self.seperators objectAtIndex:sep2index];
        sep2.hidden = NO;
        if(i == self.currentOption){
            [self setSelectedButton:dayButton];
            sep1.hidden = YES;
            sep2.hidden = YES;
        }
    }
}
@end
