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


#define ROWS_NUMBER 2
#define COLUMNS_NUMBER 2
#define BUTTON_PADDING 20
#define CONTENT_VIEW_HEIGHT 230
#define CONTENT_VIEW_WIDTH 250
#define UNSPECIFIED_HEIGHT 50
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
        
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-CONTENT_VIEW_WIDTH)/2, (self.frame.size.height-CONTENT_VIEW_HEIGHT)/2, CONTENT_VIEW_WIDTH, CONTENT_VIEW_HEIGHT+UNSPECIFIED_HEIGHT)];
        contentView.backgroundColor = [UtilityClass colorWithRed:50 green:50 blue:50 alpha:0.8];
        contentView.layer.cornerRadius = 10;
        contentView.tag = CONTENT_VIEW_TAG;
        contentView.hidden = YES;
        
        
        
        UIButton *tomorrowButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [tomorrowButton setTitle:@"Tomorrow" forState:UIControlStateNormal];
        tomorrowButton.frame = [self frameForButtonNumber:KPScheduleButtonTomorrow];
        [tomorrowButton addTarget:self action:@selector(pressedTomorrow:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:tomorrowButton];
        
        UIButton *everyDayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [everyDayButton setTitle:@"Everyday" forState:UIControlStateNormal];
        everyDayButton.frame = [self frameForButtonNumber:KPScheduleButtonEveryday];
        [everyDayButton addTarget:self action:@selector(pressedEveryday:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:everyDayButton];
        
        UIButton *inAWeekButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [inAWeekButton setTitle:@"In a week" forState:UIControlStateNormal];
        inAWeekButton.frame = [self frameForButtonNumber:KPScheduleButtonInAWeek];
        [inAWeekButton addTarget:self action:@selector(pressedInAWeek:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:inAWeekButton];
        
        UIButton *specificTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [specificTimeButton setTitle:@"Specific time" forState:UIControlStateNormal];
        specificTimeButton.frame = [self frameForButtonNumber:KPScheduleButtonSpecificTime];
        [contentView addSubview:specificTimeButton];
        
        UIButton *unspecifiedButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [unspecifiedButton setTitle:@"No specified time" forState:UIControlStateNormal];
        unspecifiedButton.frame = CGRectMake(30, CONTENT_VIEW_HEIGHT, CONTENT_VIEW_WIDTH-2*30, 44);
        [unspecifiedButton addTarget:self action:@selector(pressedUnspecified:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:unspecifiedButton];
        
        [self addSubview:contentView];
        self.contentView = [self viewWithTag:CONTENT_VIEW_TAG];
    }
    return self;
}
-(CGRect)frameForButtonNumber:(NSInteger)number{
    CGFloat width = CONTENT_VIEW_WIDTH/COLUMNS_NUMBER-(2*BUTTON_PADDING);
    CGFloat height = CONTENT_VIEW_HEIGHT/ROWS_NUMBER-(2*BUTTON_PADDING);
    CGFloat x = ((number-1) % COLUMNS_NUMBER) * CONTENT_VIEW_WIDTH/COLUMNS_NUMBER + BUTTON_PADDING;
    
    CGFloat y = floor((number-1) / ROWS_NUMBER) * CONTENT_VIEW_HEIGHT/ROWS_NUMBER + BUTTON_PADDING;
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
