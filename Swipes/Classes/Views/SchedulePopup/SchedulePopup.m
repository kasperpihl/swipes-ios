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
#define CONTAINER_VIEW_TAG 2
#define SELECT_DATE_VIEW_TAG 3
#define DATE_PICKER_TAG 4
#define MONTH_LABEL_TAG 5

#define SEPERATOR_COLOR_DARK [UtilityClass colorWithRed:77 green:77 blue:77 alpha:0.7]
#define SEPERATOR_COLOR_LIGHT [UtilityClass colorWithRed:128 green:128 blue:128 alpha:0.5]
#define SEPERATOR_MARGIN 0.02
#define SEPERATOR_WIDTH 2

#define BUTTON_FONT [UIFont fontWithName:@"Franchise-Bold" size:20]

#define PICKER_CUT_HEIGHT 10

#define MONTH_LABEL_Y 5
#define MONTH_LABEL_HEIGHT 30
#define MONTH_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]
#define MONTH_LABEL_COLOR [UtilityClass colorWithRed:255 green:255 blue:255 alpha:1]

#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE 300
#define ANIMATION_SCALE 0.1
#define ANIMATION_DURATION 0.25
#define EXTRA_SCALE 1.02
#define EXTRA_DURATION 0.1
typedef enum {
    CustomPickerTypeDay = 0,
    CustomPickerTypeHour,
    CustomPickerTypeMinute,
    CustomPickerTypeAMPM
} CustomPickerTypes;

@interface SchedulePopup ()
@property (nonatomic,copy) SchedulePopupBlock block;
@property (nonatomic,weak) IBOutlet UIView *containerView;
@property (nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,weak) IBOutlet UILabel *monthLabel;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) IBOutlet UIView *selectDateView;
@property (nonatomic) BOOL isPickingDate;
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
-(void)pressedIn2Days:(id)sender{
    [self returnState:KPScheduleButtonIn2Days date:[NSDate dateWithDaysFromNow:2]];
}
-(void)pressedIn3Days:(id)sender{
    [self returnState:KPScheduleButtonIn3Days date:[NSDate dateWithDaysFromNow:3]];
}
-(void)pressedSpecific:(id)sender{
    [UIView transitionWithView:self.containerView
                      duration:0.7f
                       options:(self.isPickingDate ? UIViewAnimationOptionTransitionFlipFromRight :
                                UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        if(!self.isPickingDate)
                        {
                            self.contentView.hidden = true;
                            self.selectDateView.hidden = false;
                        }
                        else
                        {
                            self.contentView.hidden = false;
                            self.selectDateView.hidden = true;
                        }
                    }
     
                    completion:^(BOOL finished) {
                        if (finished) {
                            self.isPickingDate = !self.isPickingDate;
                        }
                    }];
    //[self returnState:KPScheduleButtonSpecificTime date:[NSDate dateWithDaysFromNow:14]];
}
-(void)pressedUnspecified:(id)sender{
    [self returnState:KPScheduleButtonUnscheduled date:nil];
}
-(void)selectedDate:(UIButton*)sender{
    [self returnState:KPScheduleButtonSpecificTime date:self.datePicker.date];
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
        
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-CONTENT_VIEW_SIZE)/2, (self.frame.size.height-CONTENT_VIEW_SIZE)/2, CONTENT_VIEW_SIZE, CONTENT_VIEW_SIZE)];
        containerView.hidden = YES;
        containerView.tag = CONTAINER_VIEW_TAG;
        
        UIView *contentView = [[UIView alloc] initWithFrame:containerView.bounds];
        contentView.backgroundColor = [UtilityClass colorWithRed:77 green:77 blue:77 alpha:0.9];
        contentView.layer.cornerRadius = 5;
        contentView.tag = CONTENT_VIEW_TAG;
        
        for(NSInteger i = 1 ; i < GRID_NUMBER ; i++){
            UIView *verticalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:YES];
            UIView *horizontalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:NO];
            verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, CONTENT_VIEW_SIZE/GRID_NUMBER*i-(SEPERATOR_WIDTH/2),CONTENT_VIEW_SIZE*SEPERATOR_MARGIN);
            horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,CONTENT_VIEW_SIZE*SEPERATOR_MARGIN, CONTENT_VIEW_SIZE/GRID_NUMBER*i-(SEPERATOR_WIDTH/2));
            [contentView addSubview:verticalSeperatorView];
            [contentView addSubview:horizontalSeperatorView];
        }
        UIButton *tomorrowButton = [self buttonForScheduleButton:KPScheduleButtonTomorrow];
        [tomorrowButton setTitle:@"Tomorrow" forState:UIControlStateNormal];
        [tomorrowButton addTarget:self action:@selector(pressedTomorrow:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:tomorrowButton];
        
        UIButton *in2DaysButton = [self buttonForScheduleButton:KPScheduleButtonIn2Days];
        NSDate *twoDaysDate = [NSDate dateWithDaysFromNow:2];
        NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
        [weekday setDateFormat: @"EEEE"];
        [in2DaysButton addTarget:self action:@selector(pressedIn2Days:) forControlEvents:UIControlEventTouchUpInside];
        NSString *twoDaysString = [weekday stringFromDate:twoDaysDate];
        [in2DaysButton setTitle:twoDaysString forState:UIControlStateNormal];
        [contentView addSubview:in2DaysButton];
        
        
        
        UIButton *in3DaysButton = [self buttonForScheduleButton:KPScheduleButtonIn3Days];
        NSDate *threeDaysDate = [NSDate dateWithDaysFromNow:3];
        [in3DaysButton addTarget:self action:@selector(pressedIn3Days:) forControlEvents:UIControlEventTouchUpInside];
        NSString *threeDaysString = [weekday stringFromDate:threeDaysDate];
        [in3DaysButton setTitle:threeDaysString forState:UIControlStateNormal];
        [contentView addSubview:in3DaysButton];
        
        UIButton *inAWeekButton = [self buttonForScheduleButton:KPScheduleButtonInAWeek];
        [inAWeekButton setTitle:@"In a week" forState:UIControlStateNormal];
        [inAWeekButton addTarget:self action:@selector(pressedInAWeek:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:inAWeekButton];
        
        UIButton *specificTimeButton = [self buttonForScheduleButton:KPScheduleButtonSpecificTime];
        [specificTimeButton setTitle:@"Pick a date" forState:UIControlStateNormal];
        [specificTimeButton addTarget:self action:@selector(pressedSpecific:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:specificTimeButton];
        
        UIButton *unspecifiedButton = [self buttonForScheduleButton:KPScheduleButtonUnscheduled];
        [unspecifiedButton setTitle:@"Unspecified" forState:UIControlStateNormal];
        [unspecifiedButton addTarget:self action:@selector(pressedUnspecified:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:unspecifiedButton];
        [containerView addSubview:contentView];
        self.contentView = [containerView viewWithTag:CONTENT_VIEW_TAG];
        
        
        
        UIView *selectDateView = [[UIView alloc] initWithFrame:containerView.bounds];
        selectDateView.hidden = YES;
        selectDateView.tag = SELECT_DATE_VIEW_TAG;
        selectDateView.backgroundColor = [UtilityClass colorWithRed:77 green:77 blue:77 alpha:0.9];
        selectDateView.layer.cornerRadius = 5;
        
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MONTH_LABEL_Y, selectDateView.frame.size.width, MONTH_LABEL_HEIGHT)];
        monthLabel.textAlignment = UITextAlignmentCenter;
        monthLabel.textColor = MONTH_LABEL_COLOR;
        monthLabel.tag = MONTH_LABEL_TAG;
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.font = MONTH_LABEL_FONT;
        [selectDateView addSubview:monthLabel];
        self.monthLabel = (UILabel*)[selectDateView viewWithTag:MONTH_LABEL_TAG];
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, -PICKER_CUT_HEIGHT, 280, 200)];
        picker.minimumDate = [[NSDate dateTomorrow] dateAtStartOfDay];
        picker.minuteInterval = 5;
        picker.tag = DATE_PICKER_TAG;
        picker.maximumDate = [NSDate dateWithDaysFromNow:730];
        [picker addTarget:self action:@selector(changedDate:) forControlEvents:UIControlEventValueChanged];
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        [self changedDate:picker];
        CGSize pickerSize = [picker sizeThatFits:CGSizeZero];
        
        UIView *pickerTransformView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, pickerSize.width, pickerSize.height-2*PICKER_CUT_HEIGHT)];
        pickerTransformView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        [pickerTransformView addSubview:picker];
        pickerTransformView.layer.borderWidth = 1;
        pickerTransformView.layer.borderColor = [[UIColor blackColor] CGColor];
        pickerTransformView.layer.cornerRadius = 5;
        pickerTransformView.layer.masksToBounds = YES;
        pickerTransformView.frame = CGRectSetPos(pickerTransformView.frame, (selectDateView.frame.size.width-pickerTransformView.frame.size.width)/2, 50);
        self.datePicker = (UIDatePicker*)[pickerTransformView viewWithTag:DATE_PICKER_TAG];
        [selectDateView addSubview:pickerTransformView];
        
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        backButton.frame = CGRectMake(15, 235, 50, 44);
        [backButton addTarget:self action:@selector(pressedSpecific:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [selectDateView addSubview:backButton];
        
        UIButton *setDateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        setDateButton.frame = CGRectMake(200, 235, 80, 44);
        [setDateButton setTitle:@"Set date" forState:UIControlStateNormal];
        [setDateButton addTarget:self action:@selector(selectedDate:) forControlEvents:UIControlEventTouchUpInside];
        [selectDateView addSubview:setDateButton];
        
        
        
        [containerView addSubview:selectDateView];
        self.selectDateView = [containerView viewWithTag:SELECT_DATE_VIEW_TAG];
        
        
        [self addSubview:containerView];
        self.containerView = [self viewWithTag:CONTAINER_VIEW_TAG];
        
    }
    return self;
}
-(void)changedDate:(UIDatePicker*)picker{
    if([picker.date compare:picker.minimumDate] == NSOrderedSame){
        [picker setDate:[picker.minimumDate dateByAddingMinutes:1] animated:YES];
    }
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"MMMM Y"];
    NSString *monthLabelString = [weekday stringFromDate:picker.date];
    if(![self.monthLabel.text isEqualToString:monthLabelString])[self.monthLabel setText:monthLabelString];
}
-(UIButton*)buttonForScheduleButton:(KPScheduleButtons)scheduleButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = BUTTON_FONT;
    button.titleLabel.textColor = [UIColor whiteColor];
    
    button.frame = [self frameForButtonNumber:scheduleButton];
    return button;
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
        self.containerView.transform = CGAffineTransformMakeScale(ANIMATION_SCALE, ANIMATION_SCALE);
        self.containerView.hidden = NO;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(EXTRA_SCALE, EXTRA_SCALE);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:EXTRA_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(EXTRA_SCALE/EXTRA_SCALE, EXTRA_SCALE/EXTRA_SCALE);
            } completion:^(BOOL finished) {
               
            }];
        }];
    }else{
        [UIView animateWithDuration:EXTRA_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(EXTRA_SCALE, EXTRA_SCALE);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(ANIMATION_SCALE, ANIMATION_SCALE);
            } completion:^(BOOL finished) {
                if(self.block) self.block(self.selectedButton,self.self.selectedDate);
                [self removeFromSuperview];
            }];
        }];
    }
}
@end
