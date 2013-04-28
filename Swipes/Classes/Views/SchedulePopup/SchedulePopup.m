//
//  SchedulePopup.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 24/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SchedulePopup.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
#define POPUP_WIDTH 300
#define CONTENT_VIEW_TAG 1

#define SEPERATOR_COLOR_DARK [UtilityClass colorWithRed:77 green:77 blue:77 alpha:0.7]
#define SEPERATOR_COLOR_LIGHT [UtilityClass colorWithRed:128 green:128 blue:128 alpha:0.5]
#define SEPERATOR_MARGIN 0.02
#define SEPERATOR_WIDTH 2

#define BUTTON_FONT [UIFont fontWithName:@"Franchise-Bold" size:20]

#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE 300
#define ANIMATION_SCALE 0.1
#define ANIMATION_DURATION 0.25
#define EXTRA_SCALE 1.02
#define EXTRA_DURATION 0.1
@interface SchedulePopup ()
@property (nonatomic,copy) SchedulePopupBlock block;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) IBOutlet UIView *specificTimeView;
@property (nonatomic,weak) IBOutlet UIView *inAWeekView;
@property (nonatomic) NSDate *selectedDate;
@property (nonatomic) KPScheduleButtons selectedButton;
@end
@implementation SchedulePopup
+(SchedulePopup *)showInView:(UIView *)view withBlock:(SchedulePopupBlock)block{
    SchedulePopup *scheduleView = [[SchedulePopup alloc] initWithFrame:view.bounds];
    [view addSubview:scheduleView];
    scheduleView.block = block;
    [scheduleView show:YES];
    return scheduleView;
}
-(void)returnState:(KPScheduleButtons)state date:(NSDate*)date{
    self.selectedButton = state;
    self.selectedDate = date;
    [self show:NO];
}
-(void)pressedBackground:(id)sender{
    [self returnState:KPScheduleButtonCancel date:nil];
}
-(void)pressedTomorrow:(id)sender{
    [self returnState:KPScheduleButtonTomorrow date:[NSDate dateTomorrow]];
}
-(void)pressedInAWeek:(id)sender{
    [self returnState:KPScheduleButtonInAWeek date:[NSDate dateWithDaysFromNow:7]];
}
-(void)pressedEveryday:(id)sender{
    [self returnState:KPScheduleButtonEveryday date:nil];
}
-(void)pressedSpecific:(id)sender{
    [self returnState:KPScheduleButtonSpecificTime date:[NSDate dateWithDaysFromNow:14]];
}
-(void)pressedUnspecified:(id)sender{
    [self returnState:KPScheduleButtonUnscheduled date:nil];
}
-(UIView*)seperatorWithSize:(CGFloat)size vertical:(BOOL)vertical{
    CGFloat width = (vertical) ? SEPERATOR_WIDTH : size;
    CGFloat height = (vertical) ? size : SEPERATOR_WIDTH;
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    UIView *seperator1,*seperator2;
    if(vertical){
        seperator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEPERATOR_WIDTH/2, height)];
        seperator1.backgroundColor = SEPERATOR_COLOR_DARK;
        seperator2 = [[UIView alloc] initWithFrame:CGRectMake(SEPERATOR_WIDTH/2, 0, SEPERATOR_WIDTH/2, height)];
        seperator2.backgroundColor = SEPERATOR_COLOR_LIGHT;
    }
    else{
        seperator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, SEPERATOR_WIDTH/2)];
        seperator1.backgroundColor = SEPERATOR_COLOR_LIGHT;
        seperator2 = [[UIView alloc] initWithFrame:CGRectMake(0, SEPERATOR_WIDTH/2, width, SEPERATOR_WIDTH/2)];
        seperator2.backgroundColor = SEPERATOR_COLOR_DARK;
    }
    [seperator addSubview:seperator1];
    [seperator addSubview:seperator2];
    return seperator;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UtilityClass colorWithRed:155 green:155 blue:155 alpha:0.5];
        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backgroundButton.frame = backgroundView.bounds;
        [backgroundButton addTarget:self action:@selector(pressedBackground:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:backgroundButton];
        
        
        [self addSubview:backgroundView];
        
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-CONTENT_VIEW_SIZE)/2, (self.frame.size.height-CONTENT_VIEW_SIZE)/2, CONTENT_VIEW_SIZE, CONTENT_VIEW_SIZE)];
        contentView.backgroundColor = [UtilityClass colorWithRed:77 green:77 blue:77 alpha:0.9];
        contentView.layer.cornerRadius = 5;
        contentView.tag = CONTENT_VIEW_TAG;
        contentView.hidden = YES;
        
        
        for(NSInteger i = 1 ; i < GRID_NUMBER ; i++){
            UIView *verticalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:YES];
            UIView *horizontalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:NO];
            verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, CONTENT_VIEW_SIZE/GRID_NUMBER*i-(SEPERATOR_WIDTH/2),CONTENT_VIEW_SIZE*SEPERATOR_MARGIN);
            horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,CONTENT_VIEW_SIZE*SEPERATOR_MARGIN, CONTENT_VIEW_SIZE/GRID_NUMBER*i-(SEPERATOR_WIDTH/2));
            [contentView addSubview:verticalSeperatorView];
            [contentView addSubview:horizontalSeperatorView];
        }
        
        
        UIButton *tomorrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tomorrowButton.titleLabel.font = BUTTON_FONT;
        tomorrowButton.titleLabel.textColor = [UIColor whiteColor];
        [tomorrowButton setTitle:@"Tomorrow" forState:UIControlStateNormal];
        tomorrowButton.frame = [self frameForButtonNumber:KPScheduleButtonTomorrow];
        [tomorrowButton addTarget:self action:@selector(pressedTomorrow:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:tomorrowButton];
        
        UIButton *everyDayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [everyDayButton setTitle:@"Everyday" forState:UIControlStateNormal];
        everyDayButton.titleLabel.font = BUTTON_FONT;
        everyDayButton.titleLabel.textColor = [UIColor whiteColor];
        everyDayButton.frame = [self frameForButtonNumber:KPScheduleButtonEveryday];
        [everyDayButton addTarget:self action:@selector(pressedEveryday:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:everyDayButton];
        
        UIButton *inAWeekButton = [UIButton buttonWithType:UIButtonTypeCustom];
        inAWeekButton.titleLabel.textColor = [UIColor whiteColor];
        inAWeekButton.titleLabel.font = BUTTON_FONT;
        [inAWeekButton setTitle:@"In a week" forState:UIControlStateNormal];
        inAWeekButton.frame = [self frameForButtonNumber:KPScheduleButtonInAWeek];
        [inAWeekButton addTarget:self action:@selector(pressedInAWeek:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:inAWeekButton];
        
        UIButton *specificTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        specificTimeButton.titleLabel.textColor = [UIColor whiteColor];
        specificTimeButton.titleLabel.font = BUTTON_FONT;
        [specificTimeButton setTitle:@"Pick a date" forState:UIControlStateNormal];
        specificTimeButton.frame = [self frameForButtonNumber:KPScheduleButtonSpecificTime];
        [contentView addSubview:specificTimeButton];
        
        UIButton *unspecifiedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unspecifiedButton.titleLabel.textColor = [UIColor whiteColor];
        unspecifiedButton.titleLabel.font = BUTTON_FONT;
        [unspecifiedButton setTitle:@"Unspecified" forState:UIControlStateNormal];
        unspecifiedButton.frame = [self frameForButtonNumber:KPScheduleButtonUnscheduled];
        /*unspecifiedButton.frame = CGRectMake(30, CONTENT_VIEW_HEIGHT, CONTENT_VIEW_WIDTH-2*30, 44);*/
        [unspecifiedButton addTarget:self action:@selector(pressedUnspecified:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:unspecifiedButton];
        
        [self addSubview:contentView];
        self.contentView = [self viewWithTag:CONTENT_VIEW_TAG];
    }
    return self;
}
-(CGRect)frameForButtonNumber:(NSInteger)number{
    CGFloat width = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat height = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat x = ((number-1) % GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    
    CGFloat y = floor((number-1) / GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    return CGRectMake(x, y, width, height);
}
-(void)show:(BOOL)show{
    if(show){
        self.contentView.transform = CGAffineTransformMakeScale(ANIMATION_SCALE, ANIMATION_SCALE);
        self.contentView.hidden = NO;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.contentView.transform = CGAffineTransformMakeScale(EXTRA_SCALE, EXTRA_SCALE);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:EXTRA_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentView.transform = CGAffineTransformMakeScale(EXTRA_SCALE/EXTRA_SCALE, EXTRA_SCALE/EXTRA_SCALE);
            } completion:^(BOOL finished) {
               
            }];
        }];
    }else{
        [UIView animateWithDuration:EXTRA_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.contentView.transform = CGAffineTransformMakeScale(EXTRA_SCALE, EXTRA_SCALE);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentView.transform = CGAffineTransformMakeScale(ANIMATION_SCALE, ANIMATION_SCALE);
            } completion:^(BOOL finished) {
                if(self.block) self.block(self.selectedButton,self.self.selectedDate);
                [self removeFromSuperview];
            }];
        }];
    }
}
@end
