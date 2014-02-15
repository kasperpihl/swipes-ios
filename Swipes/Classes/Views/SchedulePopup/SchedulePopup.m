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
#import "SettingsHandler.h"
#import "KPBlurry.h"
#import "CKCalendarView.h"
#import "KPToolbar.h"
#import "KPTimePicker.h"
#import "UIColor+Utilities.h"
#import "RootViewController.h"
#import "MenuButton.h"
#import "PlusAlertView.h"
#import "AnalyticsHandler.h"
#import "UIView+Utilities.h"

#import "UserHandler.h"
#import "KPLocationAlert.h"


#import "LocationSearchView.h"

#define POPUP_WIDTH 315
#define CONTENT_VIEW_TAG 1


#define SCHEDULE_BUTTON_START_TAG 7367
#define kSepHorTag 203
#define kSepVerTag 204

#define SEPERATOR_COLOR_LIGHT alpha(tcolor(TextColor),0.5)
#define SEPERATOR_MARGIN 0.02//0.02


#define SCHEUDLE_IMAGE_SIZE 36
#define SCHEDULE_IMAGE_CENTER_SPACING 13

#define BUTTON_TOP_INSET 60
#define BUTTON_IMAGE_BOTTOM_MARGIN 40


#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE 310

#define kToolbarHeight 70
#define kToolbarPadding 10

#define kTimePickerDuration 0.20f

#define kHelpLevelDistance 8

#define kSepExtraOut 5
typedef enum {
    CustomPickerTypeDay = 0,
    CustomPickerTypeHour,
    CustomPickerTypeMinute,
    CustomPickerTypeAMPM
} CustomPickerTypes;

@interface SchedulePopup () <KPBlurryDelegate,CKCalendarDelegate,ToolbarDelegate,KPTimePickerDelegate, UIGestureRecognizerDelegate,LocationSearchDelegate>
@property (nonatomic,copy) SchedulePopupBlock block;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic) BOOL isPickingDate;
@property (nonatomic) BOOL isChoosingLocation;
@property (nonatomic) BOOL hasReturned;
@property (nonatomic) NSDate *pickingDate;
@property (nonatomic) IBOutletCollection(UIView) NSArray *seperators;
@property (nonatomic) IBOutletCollection(UIButton) NSMutableArray *scheduleButtons;
@property (nonatomic,strong) CKCalendarView *calendarView;
@property (nonatomic,strong) LocationSearchView *locationView;
@property (nonatomic,strong) KPToolbar *toolbar;
@property (nonatomic,strong) KPTimePicker *timePicker;
@property (nonatomic) KPScheduleButtons activeButton;
@property (nonatomic,strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, weak) IBOutlet UIView *timeViewer;
@property (nonatomic) BOOL didUseTimePicker;
@property (nonatomic) UILabel *helpLabel;
@end
@implementation SchedulePopup
-(NSMutableArray *)scheduleButtons{
    if(!_scheduleButtons) _scheduleButtons = [NSMutableArray array];
    return _scheduleButtons;
}
-(void)setStartingTimeForDate:(NSDate**)date{
    NSDate *weekendStartDay = (NSDate*)[kSettings valueForSetting:SettingWeekendStart];
    KPSettings setting;
    if([*date weekday] == weekendStartDay.weekday || [*date weekday] == weekendStartDay.weekday + 1) setting = SettingWeekendStartTime;
    else if([*date weekday] == 1 && weekendStartDay.weekday == 7) setting = SettingWeekendStartTime;
    else setting = SettingWeekStartTime;
    //else if(*week.weekday == 0 && )
    NSDate *dateForSetting = (NSDate*)[kSettings valueForSetting:setting];
    *date = [*date dateAtHours:dateForSetting.hour minutes:dateForSetting.minute];
}
+(SchedulePopup*)popupWithFrame:(CGRect)frame block:(SchedulePopupBlock)block{
    SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:frame];
    popup.block = block;
    return popup;
}
-(NSString *)stringForScheduleButton:(KPScheduleButtons)state{
    NSString *returnString;
    switch (state) {
        case KPScheduleButtonLaterToday:
            returnString = @"Later Today";
            break;
        case KPScheduleButtonThisEvening:
            returnString = @"This Evening";
            break;
        case KPScheduleButtonTomorrow:
            returnString = @"Tomorrow";
            break;
        case KPScheduleButtonIn2Days:
            returnString = @"In 2 Days";
            break;
        case KPScheduleButtonThisWeekend:
            returnString = @"This Weekend";
            break;
        case KPScheduleButtonNextWeek:
            returnString = @"Next Week";
            break;
        case KPScheduleButtonUnscheduled:
            returnString = @"Unspecified";
            break;
        case KPScheduleButtonSpecificTime:
            returnString = @"Calendar";
            break;
            
        default:
            break;
    }
    return returnString;
}
-(void)returnState:(KPScheduleButtons)state date:(NSDate*)date location:(CLPlacemark *)location{
    if(self.hasReturned) return;
    self.hasReturned = YES;
    /* ANALYTICS 
        - Button pressed: string
        - Time forward:
        - Adjusted time: "Yes" / "No"
    */
    if(state != KPScheduleButtonCancel){
        NSString *buttonUsed = [self stringForScheduleButton:state];
        NSInteger numberOfDaysFromNow = [date daysAfterDate:[NSDate date]];
        NSString *numberOfDaysInterval = @"56+";
        if(numberOfDaysFromNow <= 6) numberOfDaysInterval = [NSString stringWithFormat:@"%i",numberOfDaysFromNow];
        else if(numberOfDaysFromNow <= 14) numberOfDaysInterval = @"7-14";
        else if(numberOfDaysFromNow <= 28) numberOfDaysInterval = @"15-28";
        else if(numberOfDaysFromNow <= 42) numberOfDaysInterval = @"29-42";
        else if(numberOfDaysFromNow <= 56) numberOfDaysInterval = @"43-56";
        NSNumber *numberOfTasks = @(self.numberOfItems);
        NSString *usedTimePicker = self.didUseTimePicker ? @"Yes" : @"No";
        NSDictionary *options = @{@"Number of days ahead":numberOfDaysInterval,@"Button Pressed": buttonUsed,@"Used Time Picker": usedTimePicker,@"Number of Tasks":numberOfTasks};
        [ANALYTICS tagEvent:@"Scheduled Tasks" options:options];
    }
    if(self.block) self.block(state,date,location);
}



-(NSDate*)dateForButton:(KPScheduleButtons)button{
    NSDate *date;
    switch (button) {
        case KPScheduleButtonLaterToday:{
            NSDate *laterToday = (NSDate*)[kSettings valueForSetting:SettingLaterToday];
            NSInteger minutes = laterToday.hour * 60 + laterToday.minute;
            date = [[NSDate dateWithMinutesFromNow:minutes] dateToNearest15Minutes];
            break;
        }
        case KPScheduleButtonThisEvening:{
            NSDate *eveningStartTimeDate = (NSDate*)[kSettings valueForSetting:SettingEveningStartTime];
            date = [NSDate dateThisOrTheNextDayWithHours:eveningStartTimeDate.hour minutes:eveningStartTimeDate.minute];
            break;
        }
        case KPScheduleButtonTomorrow:{
            date = [NSDate dateTomorrow];
            [self setStartingTimeForDate:&date];
            break;
        }
        case KPScheduleButtonIn2Days:{
            date = [NSDate dateWithDaysFromNow:2];
            [self setStartingTimeForDate:&date];
            break;
        }
        case KPScheduleButtonThisWeekend:{
            NSDate *thisWeekend = (NSDate*)[kSettings valueForSetting:SettingWeekendStart];
            NSDate *weekendStartTime = (NSDate*)[kSettings valueForSetting:SettingWeekendStartTime];
            date = [NSDate dateThisOrNextWeekWithDay:thisWeekend.weekday hours:weekendStartTime.hour minutes:weekendStartTime.minute];
            break;
        }
        case KPScheduleButtonNextWeek:{
            NSDate *nextWeek = (NSDate*)[kSettings valueForSetting:SettingWeekStart];
            NSDate *weekStartTime = (NSDate*)[kSettings valueForSetting:SettingWeekStartTime];
            date = [NSDate dateThisOrNextWeekWithDay:nextWeek.weekday hours:weekStartTime.hour minutes:weekStartTime.minute];
            break;
        }
        case KPScheduleButtonUnscheduled:
        case KPScheduleButtonSpecificTime:
        case KPScheduleButtonLocation:
        case KPScheduleButtonCancel:
            date = nil;
            break;
    }
    return date;
}
-(void)cancelled{
    [self returnState:KPScheduleButtonCancel date:nil location:nil];
}
-(void)pressedScheduleButton:(UIButton*)sender{
    KPScheduleButtons thisButton = [self buttonForTag:sender.tag];
    if(thisButton == KPScheduleButtonSpecificTime) [self pressedSpecific:self];
    else if(thisButton == KPScheduleButtonLocation) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        self.helpLabel.hidden = YES;
        if(!kUserHandler.isPlus){
            [ANALYTICS pushView:@"Location plus popup"];
            self.contentView.hidden = YES;
            [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Location"}];
            [PlusAlertView alertInView:window message:@"Location reminders is an upcoming feature in Swipes Plus. Check out the whole package." block:^(BOOL succeeded, NSError *error) {
                [ANALYTICS popView];
                self.helpLabel.hidden = NO;
                self.contentView.hidden = NO;
                if(succeeded){
                    [ROOT_CONTROLLER upgrade];
                }
            }];
        }
        else{
            [self pressedLocation:self];
            return;
        }
    }
    else if(thisButton != KPScheduleButtonCancel){
        NSDate *date = [self dateForButton:thisButton];
        [self returnState:thisButton date:date location:nil];
    }
}
-(CGRect)positionForButton:(UIButton*)scheduleButton{
    KPScheduleButtons button = [self buttonForTag:scheduleButton.tag];
    CGFloat y = scheduleButton.frame.origin.y;
    CGFloat x = scheduleButton.frame.origin.x;
    if(button == 1 || button == 4 || button == 7) x = -scheduleButton.frame.size.width - kSepExtraOut;
    if(button == 3 || button == 6 || button == 9) x = self.contentView.frame.size.width + scheduleButton.frame.size.width + kSepExtraOut;
    if(button >= 1 && button <= 3) y = -scheduleButton.frame.size.height - kSepExtraOut;
    
    if(button >= 7 && button <= 9) y = self.contentView.frame.size.height + scheduleButton.frame.size.height + kSepExtraOut;
    return CGRectMake(x, y, scheduleButton.frame.size.width, scheduleButton.frame.size.height);
}
-(void)pressedLocation:(id)sender{
    if(!self.isChoosingLocation){
        self.isChoosingLocation = YES;
        [self animateScheduleButtonsShow:NO duration:0.1];
        self.locationView.hidden = NO;
        self.toolbar.hidden = NO;
        if([self.locationView numberOfHistoryPlaces] == 0) [self.locationView.searchField becomeFirstResponder];
    }
    else{
        if([self.locationView.searchField isFirstResponder]) [self.locationView.searchField resignFirstResponder];
        self.isChoosingLocation = NO;
        [self animateScheduleButtonsShow:YES duration:0.1];
        self.locationView.hidden = YES;
        self.toolbar.hidden = YES;
    }
}
-(void)pressedSpecific:(id)sender{
    if(!self.isPickingDate){
        self.isPickingDate = YES;
        CGFloat contentHeight = self.calendarView.frame.size.height + kToolbarHeight;
        CGFloat scaling = contentHeight/POPUP_WIDTH;
        self.calendarView.hidden = NO;
        self.calendarView.alpha = 1.0;
        UIImage *screenShotOfCalendar = [self.calendarView screenshot];
        self.calendarView.hidden = YES;
        
        UIImageView *calendarImageView = [[UIImageView alloc] initWithImage:screenShotOfCalendar];
        
        
        calendarImageView.center = self.calendarView.center;
        calendarImageView.alpha = 0;
        [self.contentView addSubview:calendarImageView];
        self.toolbar.alpha = 0;
        self.toolbar.hidden = NO;
        CGFloat buttonDuration = 0.1;
        CGFloat scaleDuration = 0.2;
        CGFloat calendarDuration = 0.1;
        CGFloat delay = buttonDuration;
        [self animateScheduleButtonsShow:NO duration:buttonDuration];
        [UIView animateWithDuration:scaleDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.transform = CGAffineTransformMakeScale(1.0, scaling);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            CGRectSetHeight(self.contentView, contentHeight);
            self.contentView.center = self.center;
            [UIView animateWithDuration:calendarDuration animations:^{
                calendarImageView.alpha = 1;
                self.toolbar.alpha = 1;
            } completion:^(BOOL finished) {
                self.calendarView.hidden = NO;
                [calendarImageView removeFromSuperview];
            }];
        }];
    }
    else{
        self.isPickingDate = NO;
        CGFloat contentHeight = self.calendarView.frame.size.height + kToolbarHeight;
        CGFloat scaling = POPUP_WIDTH/contentHeight;
        
        self.toolbar.alpha = 0;
        self.toolbar.hidden = NO;
        CGFloat buttonDuration = 0.1;
        CGFloat scaleDuration = 0.2;
        CGFloat calendarDuration = 0.1;
        CGFloat delay = calendarDuration;
        [UIView animateWithDuration:calendarDuration animations:^{
            self.calendarView.alpha = 0;
            self.toolbar.alpha = 0;
        } completion:^(BOOL finished) {
            self.calendarView.hidden = YES;
            self.toolbar.hidden = YES;
        }];
        [UIView animateWithDuration:scaleDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.transform = CGAffineTransformMakeScale(1.0, scaling);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            CGRectSetHeight(self.contentView, POPUP_WIDTH);
            self.contentView.center = self.center;
            [self animateScheduleButtonsShow:YES duration:buttonDuration];
        }];
    }
}
-(void)animateScheduleButtonsShow:(BOOL)show duration:(CGFloat)duration{
    [UIView animateWithDuration:duration animations:^{
        for (UIButton *button in self.scheduleButtons) {
            button.alpha = show ? 1 : 0;
        }
        for(UIView *seperator in self.seperators){
            seperator.alpha = show ? 1 : 0;
        }
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if([otherGestureRecognizer isEqual:self.panRecognizer] && !self.timePicker) return NO;
    return YES;
}

-(void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame{
    
    if(self.isPickingDate){
        CGRectSetHeight(self.contentView, frame.size.height + kToolbarHeight);
        //self.contentView.center = self.center;
    }
}

-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0){
        if(self.isPickingDate) [self pressedSpecific:self];
        else if(self.isChoosingLocation) [self pressedLocation:self];
    }
    if(item == 1) [self returnState:KPScheduleButtonSpecificTime date:self.calendarView.selectedDate location:nil];
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

-(void)locationSearchView:(LocationSearchView *)locationSearchView selectedLocation:(CLPlacemark *)location{
    NSLog(@"place: %@",location);
    [self returnState:KPScheduleButtonLocation date:nil location:location];
    [self pressedLocation:self];
}

-(void)calendar:(CKCalendarView *)calendar updateTimeForDate:(NSDate *__autoreleasing *)date{
    [self setStartingTimeForDate:&*date];
    if([*date isToday] && [*date isEarlierThanDate:[NSDate date]]) *date = [[[NSDate date] dateByAddingMinutes:5] dateToNearest5Minutes];
}

-(void)calendar:(CKCalendarView *)calendar longPressForDate:(NSDate *)date{
    [self openTimePickerWithButton:KPScheduleButtonSpecificTime andDate:date];
}

-(void)calendar:(CKCalendarView *)calendar pressedTitleButton:(UIButton *)sender{
    [self openTimePickerWithButton:KPScheduleButtonSpecificTime andDate:self.calendarView.selectedDate];
}

-(void)openTimePickerWithButton:(KPScheduleButtons)button andDate:(NSDate*)date{
    if(self.timePicker) return;
    self.activeButton = button;
    self.didUseTimePicker = YES;
    self.timePicker = [[KPTimePicker alloc] initWithFrame:self.bounds];
    self.timePicker.delegate = self;
    self.timePicker.pickingDate = date;
    self.timePicker.minimumDate = [date dateAtStartOfDay];
    if(button == KPScheduleButtonLaterToday || [date isToday]) self.timePicker.minimumDate = [[NSDate date] dateByAddingMinutes:5];
    self.timePicker.maximumDate = [[[date dateByAddingDays:1] dateAtStartOfDay] dateBySubtractingMinutes:5];
    self.timePicker.alpha = 0;
    [self addSubview:self.timePicker];
    [UIView animateWithDuration:kTimePickerDuration animations:^{
        self.timePicker.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)timePicker:(KPTimePicker *)timePicker selectedDate:(NSDate *)date{
    [UIView animateWithDuration:kTimePickerDuration animations:^{
        timePicker.alpha = 0;
    } completion:^(BOOL finished) {
            [timePicker removeFromSuperview];
            self.timePicker = nil;
            if(date) [self returnState:self.activeButton date:date location:nil];
            self.didUseTimePicker = NO;
    }];
}
-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    if(!self.timePicker) return;
    [self.timePicker forwardGesture:sender];
}
-(void)longPressRecognized:(UIGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        UIView *view = sender.view;
        KPScheduleButtons button = [self buttonForTag:view.tag];
        if(button == KPScheduleButtonSpecificTime){
            [self pressedSpecific:self];
            return;
        }
        NSDate *dateForButton = [self dateForButton:button];
        if(!dateForButton) return;
        [self openTimePickerWithButton:button andDate:dateForButton];
    }
    
}



-(void)keyboardWillHide:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRectSetCenterY(self.contentView, self.bounds.size.height/2);
    [UIView commitAnimations];
}
-(void)keyboardWillShow:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRectSetY(self.contentView,20);
    [UIView commitAnimations];
}

-(CGRect)frameForButtonNumber:(NSInteger)number{
    CGFloat width = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat height = CONTENT_VIEW_SIZE/GRID_NUMBER-(2*BUTTON_PADDING);
    CGFloat x = ((number-1) % GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    
    CGFloat y = floor((number-1) / GRID_NUMBER) * CONTENT_VIEW_SIZE/GRID_NUMBER + BUTTON_PADDING;
    return CGRectMake(x, y, width, height);
}


-(KPScheduleButtons)buttonForTag:(NSInteger)tag{
    return tag - SCHEDULE_BUTTON_START_TAG;
}

-(NSInteger)tagForButton:(KPScheduleButtons)button{
    return button+SCHEDULE_BUTTON_START_TAG;
}

-(UIButton*)buttonForScheduleButton:(KPScheduleButtons)scheduleButton title:(NSString *)title{
    MenuButton *button = [[MenuButton alloc] initWithFrame:[self frameForButtonNumber:scheduleButton] title:title image:[self imageForScheduleButton:scheduleButton highlighted:NO] highlightedImage:[self imageForScheduleButton:scheduleButton highlighted:YES]];
    button.tag = [self tagForButton:scheduleButton];
    //[button setBackgroundImage:[POPUP_SELECTED image] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(pressedScheduleButton:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressGestureRecognizer.allowableMovement = 44.0f;
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.minimumPressDuration = 0.6f;
    [button addGestureRecognizer:longPressGestureRecognizer];
    [self.scheduleButtons addObject:button];
    return button;
}

-(UIImage *)imageForScheduleButton:(KPScheduleButtons)scheduleButton highlighted:(BOOL)highlighted{
    NSString *imageString;
    switch (scheduleButton) {
        case KPScheduleButtonLaterToday:
            imageString = timageStringBW(@"schedule_image_coffee");
            break;
        case KPScheduleButtonThisEvening:
            imageString = timageStringBW(@"schedule_image_moon");
            break;
        case KPScheduleButtonTomorrow:
            imageString = timageStringBW(@"schedule_image_sun");
            break;
        case KPScheduleButtonIn2Days:
            imageString = timageStringBW(@"schedule_image_notebook");
            break;
        case KPScheduleButtonThisWeekend:
            imageString = timageStringBW(@"schedule_image_glasses");
            break;
        case KPScheduleButtonNextWeek:
            imageString = timageStringBW(@"schedule_image_circle");
            break;
        case KPScheduleButtonUnscheduled:
            imageString = timageStringBW(@"schedule_image_cloud");
            break;
        case KPScheduleButtonLocation:
            imageString = timageStringBW(@"schedule_image_location");
            break;
        case KPScheduleButtonSpecificTime:
            imageString = timageStringBW(@"schedule_image_calender");
            break;
        default:
            break;
    }
    if(highlighted) imageString = [imageString stringByAppendingString:@"-high"];
    return [UIImage imageNamed:imageString];
}

-(void)addLocationView{
    self.locationView = [[LocationSearchView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height-kToolbarHeight)];
    self.locationView.hidden = YES;
    self.locationView.delegate = self;
    self.locationView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    
    [self.contentView addSubview:self.locationView];
}

-(void)addPickerView{
    //UIColor *weekdayColor = [[tcolor(SearchDrawerBackground) getColorSaturatedWithPercentage:-0.5] getColorBrightenedWithPercentage:0.5];
    self.calendarView = [[CKCalendarView alloc] initWithFrame:CGRectMake(0, 0, 315, 315)];
    self.calendarView.onlyShowCurrentMonth = NO;
    self.calendarView.hidden = YES;
    self.calendarView.delegate = self;
    self.calendarView.backgroundColor = CLEAR;
    [self.calendarView selectDate:[NSDate date] makeVisible:YES];
    self.calendarView.titleColor = tcolor(TextColor);
    self.calendarView.dayOfWeekTextColor = tcolor(TextColor);
    self.calendarView.adaptHeightToNumberOfWeeksInMonth = YES;
    
    self.toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-kToolbarHeight, self.contentView.frame.size.width, kToolbarHeight-kToolbarPadding) items:@[timageStringBW(@"round_backarrow"),timageStringBW(@"round_checkmark")] delegate:self];
    self.toolbar.hidden = YES;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.toolbar.backgroundColor = CLEAR;
    
    [self.contentView addSubview:self.toolbar];
    [self.contentView addSubview:self.calendarView];
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
        
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        helpLabel.backgroundColor = CLEAR;
        helpLabel.textColor = tcolor(BackgroundColor);
        helpLabel.textAlignment = NSTextAlignmentCenter;
        helpLabel.text = @"Hold down to adjust time";
        helpLabel.font = KP_REGULAR(16);
        self.helpLabel = helpLabel;
        [self addSubview:helpLabel];
        
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPUP_WIDTH, POPUP_WIDTH)];
        contentView.center = self.center;
        CGRectSetY(self.helpLabel, CGRectGetMinY(contentView.frame)-CGRectGetHeight(helpLabel.frame)-kHelpLevelDistance);
        
        contentView.backgroundColor = tcolor(BackgroundColor);
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
        NSDate *eveningStartTimeDate = (NSDate*)[kSettings valueForSetting:SettingEveningStartTime];
        NSDate *thisEveningTime = [[NSDate date] dateAtHours:eveningStartTimeDate.hour minutes:eveningStartTimeDate.minute];
        NSString *thisEveText = ([[NSDate date] isLaterThanDate:thisEveningTime]) ? @"Tomorrow Eve" : @"This Evening";
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
        UIButton *locationButton = [self buttonForScheduleButton:KPScheduleButtonLocation title:@"At Location"];
        [contentView addSubview:locationButton];
        
        UIButton *unspecifiedButton = [self buttonForScheduleButton:KPScheduleButtonUnscheduled title:@"Unspecified"];
        [contentView addSubview:unspecifiedButton];
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        self.panRecognizer.delegate = self;
        [contentView addGestureRecognizer:self.panRecognizer];
        
        [self addSubview:contentView];
        self.contentView = [self viewWithTag:CONTENT_VIEW_TAG];
        [self addPickerView];
        [self addLocationView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

-(void)dealloc{
    clearNotify();
    self.calendarView = nil;
    self.locationView = nil;
}
@end