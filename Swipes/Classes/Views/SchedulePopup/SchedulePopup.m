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
#define SELECT_DATE_VIEW_TAG 3
#define DATE_PICKER_TAG 4
#define MONTH_LABEL_TAG 5
#define BACK_ONE_MONTH_BUTTON_TAG 6
#define FORWARD_ONE_MONTH_BUTTON_TAG 7


#define SEPERATOR_COLOR_DARK gray(77,0.7)
#define SEPERATOR_COLOR_LIGHT gray(128,0.5)
#define SEPERATOR_MARGIN 0//0.02




#define PICKER_CUT_HEIGHT 10
#define PICKER_CUT_WIDTH 15

#define BUTTON_TOP_INSET 60
#define BUTTON_IMAGE_BOTTOM_MARGIN 40



#define PICK_DATE_BUTTON_HEIGHT 45

#define MONTH_LABEL_Y 10
#define MONTH_LABEL_HEIGHT 30

#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE 300

typedef enum {
    CustomPickerTypeDay = 0,
    CustomPickerTypeHour,
    CustomPickerTypeMinute,
    CustomPickerTypeAMPM
} CustomPickerTypes;

@interface SchedulePopup ()
@property (nonatomic,copy) SchedulePopupBlock block;
@property (nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,weak) IBOutlet UILabel *monthLabel;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) IBOutlet UIView *selectDateView;
@property (nonatomic,weak) IBOutlet UIButton *backOneMonth;
@property (nonatomic,weak) IBOutlet UIButton *forwardOneMonth;

@property (nonatomic) BOOL isPickingDate;
@end
@implementation SchedulePopup
+(SchedulePopup *)showInView:(UIView *)view withBlock:(SchedulePopupBlock)block{
    SchedulePopup *scheduleView = [[SchedulePopup alloc] initWithFrame:view.bounds];
    [view addSubview:scheduleView];
    scheduleView.block = block;
    [scheduleView show:YES completed:nil];
    return scheduleView;
}
-(void)returnState:(KPScheduleButtons)state date:(NSDate*)date{
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        if(self.block) self.block(state,date);
    }];
}
-(void)cancelled{
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
                      duration:0.5f
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
    seperator.backgroundColor = SEPERATOR_COLOR_LIGHT;
    return seperator;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setContainerSize:CGSizeMake(POPUP_WIDTH, POPUP_WIDTH)];
        UIView *contentView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        
        contentView.backgroundColor = POPUP_BACKGROUND;//POPUP_BACKGROUND_COLOR;
        contentView.layer.cornerRadius = 10;
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
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [weekday setLocale:usLocale];
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
        [self.containerView addSubview:contentView];
        self.contentView = [self.containerView viewWithTag:CONTENT_VIEW_TAG];
        [self addPickerView];
        
    }
    return self;
}
-(void)addPickerView{
    UIView *selectDateView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    selectDateView.hidden = YES;
    selectDateView.tag = SELECT_DATE_VIEW_TAG;
    selectDateView.backgroundColor = POPUP_BACKGROUND; //POPUP_BACKGROUND_COLOR
    selectDateView.layer.cornerRadius = 10;
    selectDateView.layer.masksToBounds = YES;
    
    UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, selectDateView.frame.size.height-COLOR_SEPERATOR_HEIGHT, selectDateView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
    colorBottomSeperator.backgroundColor = SWIPES_COLOR;
    [selectDateView addSubview:colorBottomSeperator];
    
    UIButton *backOneMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backOneMonthButton setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    //backOneMonthButton.layer.borderWidth = 1;
    [backOneMonthButton addTarget:self action:@selector(pressedBackMonth:) forControlEvents:UIControlEventTouchUpInside];
    backOneMonthButton.tag = BACK_ONE_MONTH_BUTTON_TAG;
    backOneMonthButton.layer.borderColor = SEPERATOR_COLOR_DARK.CGColor;
    backOneMonthButton.frame = CGRectMake(0, 0, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT);
    [selectDateView addSubview:backOneMonthButton];
    self.backOneMonth = (UIButton*)[selectDateView viewWithTag:BACK_ONE_MONTH_BUTTON_TAG];
    
    UIButton *forwardOneMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [forwardOneMonthButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    forwardOneMonthButton.frame = CGRectMake(selectDateView.frame.size.width-COLOR_SEPERATOR_HEIGHT-PICK_DATE_BUTTON_HEIGHT, 0, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT);
    //forwardOneMonthButton.layer.borderWidth = 1;
    forwardOneMonthButton.layer.borderColor = SEPERATOR_COLOR_DARK.CGColor;
    [forwardOneMonthButton addTarget:self action:@selector(pressedForwardMonth:) forControlEvents:UIControlEventTouchUpInside];
    [selectDateView addSubview:forwardOneMonthButton];
    
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MONTH_LABEL_Y, selectDateView.frame.size.width, MONTH_LABEL_HEIGHT)];
    monthLabel.textAlignment = UITextAlignmentCenter;
    monthLabel.textColor = BUTTON_COLOR;
    monthLabel.tag = MONTH_LABEL_TAG;
    monthLabel.backgroundColor = [UIColor clearColor];
    monthLabel.font = BUTTON_FONT;
    [selectDateView addSubview:monthLabel];
    self.monthLabel = (UILabel*)[selectDateView viewWithTag:MONTH_LABEL_TAG];
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-PICKER_CUT_WIDTH, -PICKER_CUT_HEIGHT, 240, 200)];
    picker.minimumDate = [[NSDate dateTomorrow] dateAtStartOfDay];
    picker.minuteInterval = 5;
    picker.date = [[[NSDate dateTomorrow] dateAtStartOfDay] dateByAddingHours:9];
    picker.tag = DATE_PICKER_TAG;
    picker.maximumDate = [NSDate dateWithDaysFromNow:730];
    [picker addTarget:self action:@selector(changedDate:) forControlEvents:UIControlEventValueChanged];
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    [self changedDate:picker];
    CGSize pickerSize = [picker sizeThatFits:CGSizeZero];
    
    UIView *pickerTransformView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, pickerSize.width-2*PICKER_CUT_WIDTH, pickerSize.height-2*PICKER_CUT_HEIGHT)];
    pickerTransformView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    [pickerTransformView addSubview:picker];
    pickerTransformView.layer.borderWidth = 1;
    pickerTransformView.layer.borderColor = [[UIColor blackColor] CGColor];
    pickerTransformView.layer.cornerRadius = 5;
    pickerTransformView.layer.masksToBounds = YES;
    pickerTransformView.frame = CGRectSetPos(pickerTransformView.frame, (selectDateView.frame.size.width-pickerTransformView.frame.size.width)/2, ((selectDateView.frame.size.height-2*PICK_DATE_BUTTON_HEIGHT-COLOR_SEPERATOR_HEIGHT)-pickerTransformView.frame.size.height)/2+PICK_DATE_BUTTON_HEIGHT);
    self.datePicker = (UIDatePicker*)[pickerTransformView viewWithTag:DATE_PICKER_TAG];
    [selectDateView addSubview:pickerTransformView];
    
    
    
    CGFloat buttonY = selectDateView.frame.size.height-COLOR_SEPERATOR_HEIGHT-PICK_DATE_BUTTON_HEIGHT;
    CGFloat buttonWidth = selectDateView.frame.size.width/2;
    
    UIView *pickerButtonSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, buttonY-COLOR_SEPERATOR_HEIGHT, selectDateView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
    pickerButtonSeperator.backgroundColor = SEGMENT_SELECTED;
    [selectDateView addSubview:pickerButtonSeperator];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.titleLabel.font = BUTTON_FONT;
    backButton.frame = CGRectMake(0, buttonY , buttonWidth , PICK_DATE_BUTTON_HEIGHT);
    [backButton addTarget:self action:@selector(pressedSpecific:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [selectDateView addSubview:backButton];
    
    
    UIView *dateButtonsSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, buttonY, SEPERATOR_WIDTH, PICK_DATE_BUTTON_HEIGHT)];
    dateButtonsSeperator.backgroundColor = SEGMENT_SELECTED;
    [selectDateView addSubview:dateButtonsSeperator];
    
    UIButton *setDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    setDateButton.titleLabel.font = BUTTON_FONT;
    setDateButton.frame = CGRectMake(buttonWidth, buttonY,buttonWidth , PICK_DATE_BUTTON_HEIGHT);
    [setDateButton setTitle:@"SET DATE" forState:UIControlStateNormal];
    [setDateButton addTarget:self action:@selector(selectedDate:) forControlEvents:UIControlEventTouchUpInside];
    [selectDateView addSubview:setDateButton];
    
    
    
    [self.containerView addSubview:selectDateView];
    self.selectDateView = [self.containerView viewWithTag:SELECT_DATE_VIEW_TAG];
    
}
-(void)pressedBackMonth:(UIButton*)sender{
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setMonth:-1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* newDate = [calendar dateByAddingComponents:dateComponents toDate:self.datePicker.date options:0];
    [self.datePicker setDate:newDate animated:YES];
    [self changedDate:self.datePicker];
}
-(void)pressedForwardMonth:(UIButton*)sender{
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setMonth:1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* newDate = [calendar dateByAddingComponents:dateComponents toDate:self.datePicker.date options:0];
    [self.datePicker setDate:newDate animated:YES];
    [self changedDate:self.datePicker];
}
-(void)changedDate:(UIDatePicker*)picker{
    if([picker.date compare:picker.minimumDate] == NSOrderedSame){
        [picker setDate:[picker.minimumDate dateByAddingMinutes:1] animated:YES];
    }
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"MMMM Y"];
    NSString *monthLabelString = [weekday stringFromDate:picker.date];
    if(![self.monthLabel.text isEqualToString:monthLabelString]){
        [self.monthLabel setText:[monthLabelString uppercaseString]];
        self.backOneMonth.enabled = ![picker.date isThisMonth];
    }
    
}
-(UIButton*)buttonForScheduleButton:(KPScheduleButtons)scheduleButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = SCHEDULE_BUTTON_FONT;
    button.titleEdgeInsets = UIEdgeInsetsMake(BUTTON_TOP_INSET, 0, 0, 0);
    button.titleLabel.textColor = TABLE_CELL_BACKGROUND;
    UIImage *iconImage = [self imageForScheduleButton:scheduleButton];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    button.frame = [self frameForButtonNumber:scheduleButton];
    iconImageView.frame = CGRectSetPos(iconImageView.frame, (button.frame.size.width-iconImage.size.width)/2,button.frame.size.height-BUTTON_IMAGE_BOTTOM_MARGIN-iconImage.size.height);
    [button addSubview:iconImageView];
    return button;
}
-(UIImage *)imageForScheduleButton:(KPScheduleButtons)scheduleButton{
    NSString *imageString;
    switch (scheduleButton) {
        case KPScheduleButtonTomorrow:
            imageString = @"schedule_image_sun";
            break;
        case KPScheduleButtonIn2Days:
            imageString = @"schedule_image_mountain";
            break;
        case KPScheduleButtonIn3Days:
            imageString = @"schedule_image_notebook";
            break;
        case KPScheduleButtonInAWeek:
            imageString = @"schedule_image_circle";
            break;
        case KPScheduleButtonUnscheduled:
            imageString = @"schedule_image_list";
            break;
        case KPScheduleButtonSpecificTime:
            imageString = @"schedule_image_calender";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageString];
}
-(CGRect)frameForButtonNumber:(NSInteger)number{
    CGFloat width = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat height = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat x = ((number-1) % GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    
    CGFloat y = floor((number-1) / GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    return CGRectMake(x, y, width, height);
}
@end
