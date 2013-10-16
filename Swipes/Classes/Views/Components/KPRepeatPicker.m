//
//  KPDayPicker.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefSelectedColor tcolor(DoneColor)
#define kDefBackgroundColor tbackground(SearchDrawerBackground)
#define kDefFont KP_BOLD(13)
#define kDefTextColor [UIColor whiteColor]
#define kSepWidth 1
#define kSepMargin 0.0

#import "KPRepeatPicker.h"
#import "UIColor+Utilities.h"
#import "UIButton+PassTouch.h"
#import "NSDate-Utilities.h"
#import "UIView+Utilities.h"
@interface KPRepeatPicker ()
@property (nonatomic) IBOutletCollection(UILabel) NSArray *optionsButtons;
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
    if(buttonIndex < 0) buttonIndex = 0;
    if(buttonIndex > lastIndex) buttonIndex = lastIndex;
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
-(id)initWithHeight:(CGFloat)height selectedDate:(NSDate *)date option:(RepeatOptions)option{
    self = [super initWithFrame:CGRectMake(0, 0, 320, height)];
    if(self){
        self.numberOfOptions = RepeatOptionsTotal;
        self.userInteractionEnabled = YES;
        self.textColor = kDefTextColor;
        self.backgroundColor = kDefBackgroundColor;
        CGFloat buttonWidth = floorf(self.frame.size.width/self.numberOfOptions);
        NSMutableArray *buttonArray = [NSMutableArray array];
        CGFloat sepHeight = self.frame.size.height-(self.frame.size.height*kSepMargin);
        for(NSInteger i = 0 ; i < self.numberOfOptions ; i++){
            CGFloat buttonX = i*buttonWidth + i*kSepWidth;
            UIButton *dayButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX,0,buttonWidth,self.frame.size.height)];
            dayButton.titleLabel.numberOfLines = 0;
            //dayButton.titleLabel.frame = dayButton.bounds;
            //dayButton.titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
            //dayButton.transform = CGAffineTransformMakeRotation(-M_PI/2);
            dayButton.frame = CGRectMake(buttonX, 0, buttonWidth,self.frame.size.height);
            dayButton.titleLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:dayButton];
            if(i < 6){
                UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(buttonX+buttonWidth, (self.frame.size.height-sepHeight)/2, kSepWidth, sepHeight)];
                [seperator setBackgroundColor:tbackground(BackgroundColor)];
                [self addSubview:seperator];
            }
            [buttonArray addObject:dayButton];
        }
        self.optionsButtons = [buttonArray copy];
        self.font = kDefFont;
        self.selectedDate = date;
        self.currentOption = option;
        self.selectedColor = kDefSelectedColor;
        UIButton *passthroughButton = [[UIButton alloc] initWithFrame:self.bounds];
        [passthroughButton makeInsetShadowWithRadius:2 Color:alpha([UIColor blackColor],0.3) Directions:@[@"top",@"bottom"]];
        [self addSubview:passthroughButton];
    }
    return self;
}
-(NSString*)stringForOption:(RepeatOptions)option{
    NSString *buttonString;
    switch (option) {
        case RepeatNever:
            buttonString = @"never";
            break;
        case RepeatEveryDay:
            buttonString = @"day";
            break;
        case RepeatEveryMonFriOrSatSun:
            if([self.selectedDate isTypicallyWorkday]) buttonString = @"mon-fri";
            else buttonString = @"sat+sun";
        break;
        case RepeatEveryWeek:
            buttonString = @"week";
            break;
        case RepeatEveryMonth:
            buttonString = @"month";
            break;
        case RepeatEveryYear:
            buttonString = @"year";
            break;
        default:
            break;
    }
    return buttonString;
}
-(void)layoutSubviews{
    for(NSInteger i = 0 ; i < self.numberOfOptions ; i++){
        UIButton *dayButton = [self.optionsButtons objectAtIndex:i];
        [dayButton setBackgroundImage:[self.selectedColor image] forState:UIControlStateSelected];
        [dayButton setBackgroundImage:[self.selectedColor image] forState:UIControlStateSelected|UIControlStateHighlighted];
        dayButton.tag = i;
        [dayButton setTitle:[self stringForOption:i] forState:UIControlStateNormal];
        [dayButton setTitleColor:self.textColor forState:UIControlStateNormal];
        [dayButton.titleLabel setFont:self.font];
        if(i == self.currentOption) [self setSelectedButton:dayButton];
    }
}
@end
