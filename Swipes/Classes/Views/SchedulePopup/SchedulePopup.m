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
#import "KPBlurry.h"
#import "CKCalendarView.h"
#define POPUP_WIDTH 309
#define CONTENT_VIEW_TAG 1
#define TIME_VIEWER_TAG 8
#define TIME_VIEWER_LABEL_TAG 9
#define TIME_SLIDER_TAG 10
#define SCHEDULE_BUTTON_START_TAG 7367
#define kSepHorTag 203
#define kSepVerTag 204

#define SEPERATOR_COLOR_LIGHT tbackground(TaskTableGradientBackground)//color(254,184,178,1)
#define SEPERATOR_MARGIN 0.05//0.02


#define SCHEUDLE_IMAGE_SIZE 36
#define SCHEDULE_IMAGE_CENTER_SPACING 13

#define BUTTON_TOP_INSET 60
#define BUTTON_IMAGE_BOTTOM_MARGIN 40


#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE 309


#define kSepExtraOut 5
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

@interface SchedulePopup () <KPBlurryDelegate>
@property (nonatomic,copy) SchedulePopupBlock block;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic) BOOL isPickingDate;
@property (nonatomic) BOOL hasReturned;
@property (nonatomic) NSDate *pickingDate;
@property (nonatomic) IBOutletCollection(UIView) NSArray *seperators;
@property (nonatomic) IBOutletCollection(UIButton) NSMutableArray *scheduleButtons;
@property (nonatomic,strong) CKCalendarView *calendarView;


@property (nonatomic, weak) IBOutlet UIView *timeViewer;
@property (nonatomic) NSDate *activeTime;
@property (nonatomic) CGPoint lastPosition;
@property (nonatomic,weak) IBOutlet UIImageView *timeSlider;
@property (nonatomic) CGFloat currentAngle;
@property (nonatomic) CGFloat lastChangedAngle;
@property (nonatomic) CGFloat maxMeasuredVel;
@end
@implementation SchedulePopup
-(NSMutableArray *)scheduleButtons{
    if(!_scheduleButtons) _scheduleButtons = [NSMutableArray array];
    return _scheduleButtons;
}
-(TimeRef)startingTimeForDate:(NSDate*)date{
    TimeRef time;
    if(date.isTypicallyWeekend) time.hours = 10;
    else time.hours = 9;
    time.minutes = 0;
    return time;
}
+(SchedulePopup*)popupWithFrame:(CGRect)frame block:(SchedulePopupBlock)block{
    SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:frame];
    popup.block = block;
    return popup;
}
-(void)returnState:(KPScheduleButtons)state date:(NSDate*)date{
    if(self.hasReturned) return;
    self.hasReturned = YES;
    if(self.block) self.block(state,date);
}
-(NSDate*)dateForButton:(KPScheduleButtons)button{
    NSDate *date;
    switch (button) {
        case KPScheduleButtonLaterToday:
            date = [[NSDate dateWithHoursFromNow:3] dateToNearest15Minutes];
            break;
        case KPScheduleButtonThisEvening:
            date = [NSDate dateThisOrTheNextDayWithHours:19 minutes:0];
            break;
        case KPScheduleButtonTomorrow:{
            TimeRef time = [self startingTimeForDate:[NSDate dateTomorrow]];
            date = [[NSDate dateTomorrow] dateAtHours:time.hours minutes:time.minutes];
            break;
        }
        case KPScheduleButtonIn2Days:{
            TimeRef time = [self startingTimeForDate:[NSDate dateWithDaysFromNow:2]];
            date = [[NSDate dateWithDaysFromNow:2] dateAtHours:time.hours minutes:time.minutes];
            break;
        }
        case KPScheduleButtonThisWeekend:
            date = [NSDate dateThisOrNextWeekWithDay:7 hours:10 minutes:0];
        case KPScheduleButtonNextWeek:
            date = [NSDate dateThisOrNextWeekWithDay:2 hours:9 minutes:0];
            break;
        case KPScheduleButtonUnscheduled:
            date = nil;
        case KPScheduleButtonSpecificTime:
        case KPScheduleButtonCancel:
            return nil;
    }
    return date;
}
-(void)cancelled{
    [self returnState:KPScheduleButtonCancel date:nil];
}
-(void)pressedScheduleButton:(UIButton*)sender{
    KPScheduleButtons thisButton = sender.tag - SCHEDULE_BUTTON_START_TAG;
    NSLog(@"thisButton:%i",thisButton);
    if(thisButton == KPScheduleButtonSpecificTime) [self pressedSpecific:self];
    else if(thisButton != KPScheduleButtonCancel){
        NSDate *date = [self dateForButton:thisButton];
        [self returnState:thisButton date:date];
    }
}
-(CGRect)positionForButton:(UIButton*)scheduleButton{
    KPScheduleButtons button = scheduleButton.tag - SCHEDULE_BUTTON_START_TAG;
    CGFloat y = scheduleButton.frame.origin.y;
    CGFloat x = scheduleButton.frame.origin.x;
    if(button == 1 || button == 4 || button == 7) x = -scheduleButton.frame.size.width - kSepExtraOut;
    if(button == 3 || button == 6 || button == 9) x = self.contentView.frame.size.width + scheduleButton.frame.size.width + kSepExtraOut;
    if(button >= 1 && button <= 3) y = -scheduleButton.frame.size.height - kSepExtraOut;
    
    if(button >= 7 && button <= 9) y = self.contentView.frame.size.height + scheduleButton.frame.size.height + kSepExtraOut;
    return CGRectMake(x, y, scheduleButton.frame.size.width, scheduleButton.frame.size.height);
}
-(void)pressedSpecific:(id)sender{
    if(!self.isPickingDate){
        self.calendarView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        self.calendarView.hidden = NO;
        self.calendarView.alpha = 0;
        [UIView animateWithDuration:1.0f animations:^{
            for (UIButton *button in self.scheduleButtons) {
                if(button.tag - SCHEDULE_BUTTON_START_TAG == 5) button.hidden = YES;
                button.frame = [self positionForButton:button];
            }
            NSInteger counter = 0;
            for(UIView *seperator in self.seperators){
               
                NSInteger targetCoordinate;
                if(counter < 2) targetCoordinate = -SEPERATOR_WIDTH - kSepExtraOut;
                else targetCoordinate = POPUP_WIDTH + SEPERATOR_WIDTH + kSepExtraOut;
                counter++;
                if (counter % 2) CGRectSetX(seperator, targetCoordinate);
                else CGRectSetY(seperator, targetCoordinate);
            }
            self.calendarView.transform = CGAffineTransformIdentity;
            self.calendarView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        
    }
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
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(cancelled) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = self.bounds;
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [self addSubview:closeButton];
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPUP_WIDTH, POPUP_WIDTH)];
        contentView.center = self.center;
        
        contentView.backgroundColor = tbackground(SearchDrawerBackground);//POPUP_BACKGROUND_COLOR color(254,115,103,1);//;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        contentView.tag = CONTENT_VIEW_TAG;
        NSMutableArray *seperatorArray = [NSMutableArray array];
        for(NSInteger i = 1 ; i < GRID_NUMBER ; i++){
            UIView *verticalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:YES];
            verticalSeperatorView.tag = kSepVerTag;
            UIView *horizontalSeperatorView = [self seperatorWithSize:CONTENT_VIEW_SIZE*(1-(SEPERATOR_MARGIN*2)) vertical:NO];
            horizontalSeperatorView.tag = kSepHorTag;
            verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, CONTENT_VIEW_SIZE/GRID_NUMBER*i,CONTENT_VIEW_SIZE*SEPERATOR_MARGIN);
            horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,CONTENT_VIEW_SIZE*SEPERATOR_MARGIN, CONTENT_VIEW_SIZE/GRID_NUMBER*i);
            [contentView addSubview:verticalSeperatorView];
            [contentView addSubview:horizontalSeperatorView];
            [seperatorArray addObject:verticalSeperatorView];
            [seperatorArray addObject:horizontalSeperatorView];
        }
        self.seperators = [seperatorArray copy];
        /* Schedule buttons */
        UIButton *laterTodayButton = [self buttonForScheduleButton:KPScheduleButtonLaterToday title:@"Later Today"];
        [contentView addSubview:laterTodayButton];
        NSString *thisEveText = ([[NSDate date] hour] >= 19) ? @"Tomorrow Eve" : @"This Evening";
        UIButton *thisEveningButton = [self buttonForScheduleButton:KPScheduleButtonThisEvening title:thisEveText];
        [contentView addSubview:thisEveningButton];
        UIButton *tomorrowButton = [self buttonForScheduleButton:KPScheduleButtonTomorrow title:@"Tomorrow"];
        [contentView addSubview:tomorrowButton];
        NSDate *twoDaysDate = [NSDate dateWithDaysFromNow:2];
        NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [weekday setLocale:usLocale];
        [weekday setDateFormat: @"EEEE"];
        NSString *twoDaysString = [weekday stringFromDate:twoDaysDate];
        UIButton *in2DaysButton = [self buttonForScheduleButton:KPScheduleButtonIn2Days title:twoDaysString];
        [contentView addSubview:in2DaysButton];
        UIButton *thisWeekendButton = [self buttonForScheduleButton:KPScheduleButtonThisWeekend title:@"This Weekend"];
        [contentView addSubview:thisWeekendButton];
        UIButton *nextWeekButton = [self buttonForScheduleButton:KPScheduleButtonNextWeek title:@"Next Week"];
        [contentView addSubview:nextWeekButton];
        UIButton *specificTimeButton = [self buttonForScheduleButton:KPScheduleButtonSpecificTime title:@"Pick A Date"];
        [contentView addSubview:specificTimeButton];
        UIButton *unspecifiedButton = [self buttonForScheduleButton:KPScheduleButtonUnscheduled title:@"Unspecified"];
        [contentView addSubview:unspecifiedButton];
        
        [self addSubview:contentView];
        self.contentView = [self viewWithTag:CONTENT_VIEW_TAG];
        [self addPickerView];
    }
    return self;
}
-(void)addPickerView{
    self.calendarView = [[CKCalendarView alloc] initWithFrame:CGRectMake(0, 0, 309, 309)];
    self.calendarView.onlyShowCurrentMonth = NO;
    self.calendarView.hidden = YES;
    self.calendarView.backgroundColor = CLEAR;
    self.calendarView.titleColor = [UIColor whiteColor];
    self.calendarView.dayOfWeekTextColor = [UIColor whiteColor];
    self.calendarView.adaptHeightToNumberOfWeeksInMonth = YES;
    [self.contentView addSubview:self.calendarView];
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
    button.tag = SCHEDULE_BUTTON_START_TAG + scheduleButton;
    if(SCHEDULE_BUTTON_CAPITAL) title = [title uppercaseString];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pressedScheduleButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    [self.scheduleButtons addObject:button];
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
    return [UIImage imageNamed:imageString];
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
    UILabel *timeLabel = (UILabel*)[timeView viewWithTag:TIME_VIEWER_LABEL_TAG];
    timeLabel.text = [UtilityClass timeStringForDate:time];
}
-(void)showTimeView:(BOOL)show{
    UIView *timeView = [self viewWithTag:TIME_VIEWER_TAG];
    
    if(!timeView){
        CGFloat startOfIndicator = 100;
        NSInteger widthOfIndicator = 200;
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
        
        UIImageView *timeSlider = [[UIImageView alloc] initWithFrame:CGRectMake((320-widthOfIndicator)/2, startOfIndicator, widthOfIndicator,widthOfIndicator)];
        timeSlider.tag = TIME_SLIDER_TAG;
        timeSlider.image = [UIImage imageNamed:@"circle-03"];
        timeSlider.center = self.center;
        [timeView addSubview:timeSlider];
        [self addSubview:timeView];
        self.timeSlider = (UIImageView*)[self viewWithTag:TIME_SLIDER_TAG];
    }
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    NSDate *upperLimit = [self.pickingDate dateAtHours:23 minutes:55];
    NSDate *lowerLimit = [self.pickingDate dateAtHours:0 minutes:0];
    CGPoint velocity = [sender velocityInView:self];
    CGPoint location = [sender locationInView:self];
    CGFloat vel = fabsf(velocity.y)+fabsf(velocity.x);
    NSInteger minutesPerInterval = 5;
    CGFloat angleInterval = 30;
    BOOL isHours = NO;
    if(vel > 800){
        minutesPerInterval = 30;
        angleInterval = 30;
    }
    angleInterval = angleInterval*M_PI/180;
    
    CGPoint sliderCenter = self.center;
    CGPoint sliderStartPoint = CGPointMake(sliderCenter.x, sliderCenter.y - 100.0);
    if(!CGPointEqualToPoint(self.lastPosition, CGPointZero)) sliderStartPoint = self.lastPosition;
    CGFloat angle = [self angleBetweenCenterPoint:sliderCenter point1:sliderStartPoint point2:location];
    self.lastChangedAngle = self.lastChangedAngle + angle;
    self.lastPosition = location;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showTimeView:YES];
        self.pickingDate = [[NSDate date] dateAtHours:13 minutes:15];
        self.activeTime = self.pickingDate;
        [self showTime:self.activeTime];
    }
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateBegan) {
        self.currentAngle = self.currentAngle-angle;
        self.timeSlider.transform = CGAffineTransformMakeRotation(self.currentAngle);
        if(vel > self.maxMeasuredVel) self.maxMeasuredVel = vel;
        NSInteger numberOfIntervals = round(self.lastChangedAngle/angleInterval);
        if(numberOfIntervals != 0){
            NSInteger timeAdded = minutesPerInterval*numberOfIntervals;
            self.activeTime = [self.activeTime dateBySubtractingMinutes:timeAdded];
            self.lastChangedAngle = 0;
            if([self.activeTime isLaterThanDate:upperLimit]) self.activeTime = upperLimit;
            if([self.activeTime isEarlierThanDate:lowerLimit]) self.activeTime = lowerLimit;
            if(isHours) self.activeTime = [self.activeTime dateAtHours:self.activeTime.hour minutes:0];
            [self showTime:self.activeTime];
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIView *timeView = (UILabel *)[self viewWithTag:TIME_VIEWER_TAG];
        [timeView removeFromSuperview];
        NSLog(@"max measured: %f",self.maxMeasuredVel);
        self.maxMeasuredVel = 0;
    }
}
-(CGFloat)angleBetweenCenterPoint:(CGPoint)centerPoint point1:(CGPoint)p1 point2:(CGPoint)p2{
    CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}
-(void)dealloc{
    self.calendarView = nil;
}
@end