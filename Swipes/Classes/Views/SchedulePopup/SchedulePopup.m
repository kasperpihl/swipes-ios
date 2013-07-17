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
#define POPUP_WIDTH 310
#define CONTENT_VIEW_TAG 1
#define SELECT_DATE_VIEW_TAG 3
#define DATE_PICKER_TAG 4
#define MONTH_LABEL_TAG 5
#define BACK_ONE_MONTH_BUTTON_TAG 6
#define FORWARD_ONE_MONTH_BUTTON_TAG 7
#define TIME_VIEWER_TAG 8
#define TIME_VIEWER_LABEL_TAG 9
#define TIME_INDICATOR_TAG 10

#define SEPERATOR_COLOR_LIGHT color(157,159,161,1)
#define SEPERATOR_MARGIN 0//0.02


#define SCHEUDLE_IMAGE_SIZE 36
#define SCHEDULE_IMAGE_CENTER_SPACING 13


#define PICKER_CUT_HEIGHT 10
#define PICKER_CUT_WIDTH 15

#define BUTTON_TOP_INSET 60
#define BUTTON_IMAGE_BOTTOM_MARGIN 40



#define PICK_DATE_BUTTON_HEIGHT 45

#define MONTH_LABEL_Y 10
#define MONTH_LABEL_HEIGHT 30

#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE 310


typedef enum {
    CustomPickerTypeDay = 0,
    CustomPickerTypeHour,
    CustomPickerTypeMinute,
    CustomPickerTypeAMPM
} CustomPickerTypes;
typedef struct
{
    int     hours;
    int     minutes;
} TimeRef;

@interface SchedulePopup ()
@property (nonatomic,copy) SchedulePopupBlock block;
@property (nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,weak) IBOutlet UILabel *monthLabel;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) IBOutlet UIView *selectDateView;
@property (nonatomic,weak) IBOutlet UIButton *backOneMonth;
@property (nonatomic,weak) IBOutlet UIButton *forwardOneMonth;
@property (nonatomic) NSInteger startingHour;
@property (nonatomic) BOOL isPickingDate;
@property (nonatomic) BOOL hasReturned;
@property (nonatomic, weak) IBOutlet UIView *timeViewer;
@property (nonatomic) NSDate *pickingDate;
@property (nonatomic) NSDate *activeTime;
@property (nonatomic) CGPoint lastPosition;
@property TimeRef currentTime;
@end
@implementation SchedulePopup
-(TimeRef)startingTimeForDate:(NSDate*)date{
    TimeRef time;
    if(date.isTypicallyWeekend) time.hours = 10;
    else time.hours = 9;
    time.minutes = 0;
    return time;
}
+(SchedulePopup *)showInView:(UIView *)view withBlock:(SchedulePopupBlock)block{
    SchedulePopup *scheduleView = [[SchedulePopup alloc] initWithFrame:view.bounds];
    [view addSubview:scheduleView];
    scheduleView.block = block;
    [scheduleView show:YES completed:nil];
    return scheduleView;
}
-(void)returnState:(KPScheduleButtons)state date:(NSDate*)date{
    if(self.hasReturned) return;
    self.hasReturned = YES;
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        if(self.block) self.block(state,date);
    }];
}
-(void)cancelled{
    [self returnState:KPScheduleButtonCancel date:nil];
}
-(void)pressedLaterToday:(id)sender{
    [self returnState:KPScheduleButtonLaterToday date:[[NSDate dateWithHoursFromNow:3] dateToNearest15Minutes]];
}
-(void)pressedThisEvening:(id)sender{
    NSDate *date = [NSDate dateThisOrTheNextDayWithHours:19 minutes:0];
    [self returnState:KPScheduleButtonThisEvening date:date];
}
-(void)pressedTomorrow:(id)sender{
    NSDate *tomorrow = [[NSDate dateTomorrow] dateAtStartOfDay];
    TimeRef time = [self startingTimeForDate:tomorrow];
    [self returnState:KPScheduleButtonTomorrow date:[tomorrow dateByAddingHours:time.hours]];
}
-(void)pressedIn2Days:(id)sender{
    NSDate *in2Days = [[NSDate dateWithDaysFromNow:2] dateAtStartOfDay];
    NSDate *startingTime = [in2Days dateByAddingHours:[self startingTimeForDate:in2Days].hours];
    [self returnState:KPScheduleButtonIn2Days date:startingTime];
}
-(void)pressedThisWeekend:(id)sender{
    NSDate *thisWeekend = [NSDate dateThisOrNextWeekWithDay:7 hours:10 minutes:0];
    [self returnState:KPScheduleButtonThisWeekend date:thisWeekend];
}
-(void)pressedNextWeek:(id)sender{
    
    NSDate *nextWeek = [NSDate dateThisOrNextWeekWithDay:2 hours:self.startingHour minutes:0];
    [self returnState:KPScheduleButtonThisWeekend date:nextWeek];
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
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startingHour = 9;
        [self setContainerSize:CGSizeMake(POPUP_WIDTH, POPUP_WIDTH)];
        UIView *contentView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        
        contentView.backgroundColor = POPUP_BACKGROUND;//POPUP_BACKGROUND_COLOR;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        contentView.tag = CONTENT_VIEW_TAG;
        
        for(NSInteger i = 1 ; i < GRID_NUMBER ; i++){
            UIView *verticalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:YES];
            UIView *horizontalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:NO];
            verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, CONTENT_VIEW_SIZE/GRID_NUMBER*i-(SEPERATOR_WIDTH/2),CONTENT_VIEW_SIZE*SEPERATOR_MARGIN);
            horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,CONTENT_VIEW_SIZE*SEPERATOR_MARGIN, CONTENT_VIEW_SIZE/GRID_NUMBER*i-(SEPERATOR_WIDTH/2));
            [contentView addSubview:verticalSeperatorView];
            [contentView addSubview:horizontalSeperatorView];
        }
        
        UIButton *laterTodayButton = [self buttonForScheduleButton:KPScheduleButtonLaterToday title:@"Later Today"];
        
        [laterTodayButton addTarget:self action:@selector(pressedLaterToday:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:laterTodayButton];
        
        NSString *thisEveText = ([[NSDate date] hour] >= 18) ? @"Tomorrow Eve" : @"This Evening";
        UIButton *thisEveningButton = [self buttonForScheduleButton:KPScheduleButtonThisEvening title:thisEveText];
        [thisEveningButton addTarget:self action:@selector(pressedThisEvening:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:thisEveningButton];
        
        UIButton *tomorrowButton = [self buttonForScheduleButton:KPScheduleButtonTomorrow title:@"Tomorrow"];
        [tomorrowButton addTarget:self action:@selector(pressedTomorrow:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:tomorrowButton];
        
        
        
        NSDate *twoDaysDate = [NSDate dateWithDaysFromNow:2];
        NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [weekday setLocale:usLocale];
        [weekday setDateFormat: @"EEEE"];
        NSString *twoDaysString = [weekday stringFromDate:twoDaysDate];
        UIButton *in2DaysButton = [self buttonForScheduleButton:KPScheduleButtonIn2Days title:twoDaysString];
        [in2DaysButton addTarget:self action:@selector(pressedIn2Days:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:in2DaysButton];
        
        
        UIButton *thisWeekendButton = [self buttonForScheduleButton:KPScheduleButtonThisWeekend title:@"This Weekend"];
        [thisWeekendButton addTarget:self action:@selector(pressedThisWeekend:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:thisWeekendButton];
        
        
        UIButton *nextWeekButton = [self buttonForScheduleButton:KPScheduleButtonNextWeek title:@"Next Week"];
        [nextWeekButton addTarget:self action:@selector(pressedNextWeek:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:nextWeekButton];
        
        UIButton *specificTimeButton = [self buttonForScheduleButton:KPScheduleButtonSpecificTime title:@"Pick A Date"];
        [specificTimeButton addTarget:self action:@selector(pressedSpecific:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:specificTimeButton];
        
        UIButton *unspecifiedButton = [self buttonForScheduleButton:KPScheduleButtonUnscheduled title:@"Unspecified"];
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
    colorBottomSeperator.backgroundColor = tcolor(ColoredSeperator);
    [selectDateView addSubview:colorBottomSeperator];
    
    UIButton *backOneMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backOneMonthButton setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    //backOneMonthButton.layer.borderWidth = 1;
    [backOneMonthButton addTarget:self action:@selector(pressedBackMonth:) forControlEvents:UIControlEventTouchUpInside];
    backOneMonthButton.tag = BACK_ONE_MONTH_BUTTON_TAG;
    backOneMonthButton.layer.borderColor = SEPERATOR_COLOR_LIGHT.CGColor;
    backOneMonthButton.frame = CGRectMake(0, 0, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT);
    [selectDateView addSubview:backOneMonthButton];
    self.backOneMonth = (UIButton*)[selectDateView viewWithTag:BACK_ONE_MONTH_BUTTON_TAG];
    
    UIButton *forwardOneMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [forwardOneMonthButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    forwardOneMonthButton.frame = CGRectMake(selectDateView.frame.size.width-COLOR_SEPERATOR_HEIGHT-PICK_DATE_BUTTON_HEIGHT, 0, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT, PICK_DATE_BUTTON_HEIGHT+COLOR_SEPERATOR_HEIGHT);
    //forwardOneMonthButton.layer.borderWidth = 1;
    forwardOneMonthButton.layer.borderColor = SEPERATOR_COLOR_LIGHT.CGColor;
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
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-PICKER_CUT_WIDTH, -PICKER_CUT_HEIGHT, 310, 216)];
    picker.minimumDate = [NSDate date];
    picker.minuteInterval = 5;
    picker.date = [[NSDate date] dateByAddingHours:1];
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
    //pickerButtonSeperator.backgroundColor = SEGMENT_SELECTED;
    [selectDateView addSubview:pickerButtonSeperator];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.titleLabel.font = BUTTON_FONT;
    backButton.frame = CGRectMake(0, buttonY , buttonWidth , PICK_DATE_BUTTON_HEIGHT);
    [backButton addTarget:self action:@selector(pressedSpecific:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [selectDateView addSubview:backButton];
    
    
    UIView *dateButtonsSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, buttonY, SEPERATOR_WIDTH, PICK_DATE_BUTTON_HEIGHT)];
    //dateButtonsSeperator.backgroundColor = SEGMENT_SELECTED;
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
-(void)highlightedButton:(UIButton *)sender{
    UIImageView *iconImage = (UIImageView*)[sender viewWithTag:1337];
    iconImage.highlighted = YES;
}
-(void)deHighlightedButton:(UIButton *)sender{
    UIImageView *iconImage = (UIImageView*)[sender viewWithTag:1337];
    iconImage.highlighted = NO;
}
-(UIButton*)buttonForScheduleButton:(KPScheduleButtons)scheduleButton title:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UtilityClass imageWithColor:POPUP_SELECTED] forState:UIControlStateHighlighted];
    button.titleLabel.font = SCHEDULE_BUTTON_FONT;
    if(SCHEDULE_BUTTON_CAPITAL) title = [title uppercaseString];
    button.titleLabel.shadowOffset = CGSizeMake(1,1);
    [button setTitleShadowColor:tbackground(TaskCellBackground) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [button setTitleColor:tbackground(TaskCellBackground) forState:UIControlStateHighlighted];
    UIImage *iconImage = [self imageForScheduleButton:scheduleButton];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    iconImageView.tag = 1337;
    iconImageView.highlightedImage = [UtilityClass image:iconImage withColor:tbackground(TaskCellBackground)];
    button.frame = [self frameForButtonNumber:scheduleButton];
    CGFloat imageHeight = iconImageView.frame.size.height;
    CGFloat textHeight = [@"Kasjper" sizeWithFont:SCHEDULE_BUTTON_FONT].height;
    NSInteger dividor = (SCHEDULE_IMAGE_CENTER_SPACING == 0) ? 3 : 2;
    CGFloat spacing = (button.frame.size.height-imageHeight-textHeight-SCHEDULE_IMAGE_CENTER_SPACING)/dividor;
    [button addTarget:self action:@selector(highlightedButton:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(highlightedButton:) forControlEvents:UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(deHighlightedButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(deHighlightedButton:) forControlEvents:UIControlEventTouchCancel];
    [button addTarget:self action:@selector(deHighlightedButton:) forControlEvents:UIControlEventTouchDragOutside];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [button addGestureRecognizer:panGestureRecognizer];
    iconImageView.frame = CGRectSetPos(iconImageView.frame, (button.frame.size.width-iconImage.size.width)/2,spacing);
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, spacing, 0);
    [button addSubview:iconImageView];
    return button;
}
-(UIImage *)imageForScheduleButton:(KPScheduleButtons)scheduleButton{
    NSString *imageString;
    switch (scheduleButton) {
        case KPScheduleButtonLaterToday:
            imageString = @"schedule_image_coffee";
            break;
        case KPScheduleButtonThisEvening:
            imageString = @"schedule_image_moon";
            break;
        case KPScheduleButtonTomorrow:
            imageString = @"schedule_image_sun";
            break;
        case KPScheduleButtonIn2Days:
            imageString = @"schedule_image_notebook";
            break;
        case KPScheduleButtonThisWeekend:
            imageString = @"schedule_image_glasses";
            break;
        case KPScheduleButtonNextWeek:
            imageString = @"schedule_image_circle";
            break;
        case KPScheduleButtonUnscheduled:
            imageString = @"schedule_image_cloud";
            break;
        case KPScheduleButtonSpecificTime:
            imageString = @"schedule_image_calender";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageString];//[SchedulePopup imageWithImage:[UIImage imageNamed:imageString] scaledToSize:CGSizeMake(SCHEUDLE_IMAGE_SIZE, SCHEUDLE_IMAGE_SIZE)];
}
-(CGRect)frameForButtonNumber:(NSInteger)number{
    CGFloat width = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat height = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat x = ((number-1) % GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    
    CGFloat y = floor((number-1) / GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    return CGRectMake(x, y, width, height);
}
-(void)showTime:(NSDate*)time{
    UIView *timeView = [self viewWithTag:TIME_VIEWER_TAG];
    
    if(!timeView){
        CGFloat startOfIndicator = 100;
        CGFloat indicatorBottomMargin = 50;
        CGFloat heightOfIndicator = self.bounds.size.height-startOfIndicator-indicatorBottomMargin;
        NSInteger widthOfIndicator = 260;
        timeView = [[UIView alloc] initWithFrame:self.bounds];
        timeView.backgroundColor = color(253, 99, 73, 0.95);
        timeView.tag = TIME_VIEWER_TAG;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 60)];
        label.tag = TIME_VIEWER_LABEL_TAG;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = KP_BOLD(40);
        label.textAlignment = UITextAlignmentCenter;
        [timeView addSubview:label];
        UIView *timeBackground = [[UIView alloc] initWithFrame:CGRectMake((320-widthOfIndicator)/2, startOfIndicator, widthOfIndicator,heightOfIndicator)];
        timeBackground.backgroundColor = [UIColor clearColor];
        timeBackground.layer.borderWidth = 2;
        timeBackground.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        
        [timeView addSubview:timeBackground];
        [self addSubview:timeView];
    }
    
    
    UILabel *timeLabel = (UILabel*)[timeView viewWithTag:TIME_VIEWER_LABEL_TAG];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [timeFormatter stringFromDate:time];
    timeLabel.text = timeString;
    //timeView.text = [NSString stringWithFormat:@"%i:%i",timeRef.hours,timeRef.minutes];
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    
    CGPoint velocity = [sender velocityInView:self];
    CGPoint location = [sender locationInView:self];
    CGFloat vel = fabsf(velocity.y);
    NSInteger minutesPerInterval = 5;
    CGFloat interval = 5;
    //if(vel > 100) minutesPerInterval = 15;
    if(vel > 150){
        minutesPerInterval = 60;
        interval = 10;
    }
    if(vel > 1000){
        minutesPerInterval = 120;
        interval = 15;
    }
   // NSLog(@"vel:%f",vel);
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.pickingDate = [[NSDate date] dateAtHours:13 minutes:15];
        self.activeTime = self.pickingDate;
        [self showTime:self.activeTime];
        self.lastPosition = location;
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        NSInteger movedIntervals = (self.lastPosition.y - location.y)/interval;
        BOOL update = NO;
        if(movedIntervals != 0){
            self.activeTime = [self.activeTime dateByAddingMinutes:movedIntervals*minutesPerInterval];
            NSDate *upperLimit = [self.pickingDate dateAtHours:23 minutes:55];
            NSDate *lowerLimit = [self.pickingDate dateAtHours:0 minutes:0];
            update = YES;
            self.lastPosition = location;
            if([self.activeTime isLaterThanDate:upperLimit]) self.activeTime = upperLimit;
            if([self.activeTime isEarlierThanDate:lowerLimit]) self.activeTime = lowerLimit;
        }
        if(update) [self showTime:self.activeTime];
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIView *timeView = (UILabel *)[self viewWithTag:TIME_VIEWER_TAG];
        [timeView removeFromSuperview];
    }
}
@end
