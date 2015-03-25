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
#import "NotificationHandler.h"

#import "LocationSearchView.h"

#define POPUP_WIDTH 308 
#define CONTENT_VIEW_TAG 1


#define SCHEDULE_BUTTON_START_TAG 7367
#define kSepHorTag 203
#define kSepVerTag 204



#define SCHEUDLE_IMAGE_SIZE 36
#define SCHEDULE_IMAGE_CENTER_SPACING 13

#define BUTTON_TOP_INSET 60
#define BUTTON_IMAGE_BOTTOM_MARGIN 40


#define GRID_NUMBER 3
#define BUTTON_PADDING 0
#define CONTENT_VIEW_SIZE POPUP_WIDTH

#define kToolbarHeight valForScreen(50,60)
#define kToolbarPadding 10

#define kTimePickerDuration 0.20f

#define kHelpLevelDistance 28

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
@property (nonatomic) UISegmentedControl *leaveOrArrive;
@end
@implementation SchedulePopup
-(NSMutableArray *)scheduleButtons{
    if(!_scheduleButtons) _scheduleButtons = [NSMutableArray array];
    return _scheduleButtons;
}
-(void)setCalendarDate:(NSDate *)calendarDate{
    _calendarDate = calendarDate;
    if(calendarDate && [calendarDate isInFuture])
        [self.calendarView selectDate:calendarDate makeVisible:YES];
    else
        [self.calendarView selectDate:[NSDate date] makeVisible:YES];
}
-(void)setStartingTimeForDate:(NSDate**)date{
    NSNumber *weekendStartDay = (NSNumber*)[kSettings valueForSetting:SettingWeekendStart];
    KPSettings setting;
    if([*date weekday] == weekendStartDay.integerValue || [*date weekday] == weekendStartDay.integerValue + 1) setting = SettingWeekendStartTime;
    else if([*date weekday] == 1 && weekendStartDay.integerValue == 7) setting = SettingWeekendStartTime;
    else setting = SettingWeekStartTime;
    //else if(*week.weekday == 0 && )
    NSNumber *dateForSetting = (NSNumber*)[kSettings valueForSetting:setting];
    *date = [[*date dateAtStartOfDay] dateByAddingTimeInterval:dateForSetting.integerValue];
}
+(SchedulePopup*)popupWithFrame:(CGRect)frame block:(SchedulePopupBlock)block{
    SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:frame];
    popup.block = block;
    return popup;
}
-(NSString *)stringForScheduleButton:(KPScheduleButtons)state{
    NSString *returnString;
    switch (state) {
        case KPScheduleButtonLaterToday:{
            returnString = @"Later Today";
            break;
        }
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
        case KPScheduleButtonLocation:
            returnString = @"Location";
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
    GeoFenceType type = GeoFenceNone;
    if(state != KPScheduleButtonCancel){
        
        NSNumber *numberOfTasks = @(self.numberOfItems);
        NSString *buttonUsed = [self stringForScheduleButton:state];
        NSMutableDictionary *options = [@{@"Number of Tasks":numberOfTasks,@"From": buttonUsed} mutableCopy];
        if(state != KPScheduleButtonLocation){
            [options setObject:@([date daysAfterDate:[NSDate date]]) forKey:@"Number of Days Ahead"];
            [options setObject:(self.didUseTimePicker ? @"Yes" : @"No") forKey:@"Used Time Picker"];
            if(self.didUseTimePicker){
                [ANALYTICS trackEvent:@"Time Picker" options:@{@"Number of Tasks": numberOfTasks, @"From": buttonUsed}];
            }
        }
        [ANALYTICS trackEvent:@"Snoozed Tasks" options:[options copy]];
        [ANALYTICS trackCategory:@"Tasks" action:@"Snoozed" label:buttonUsed value:@([date daysAfterDate:[NSDate date]])];
    }
    if(self.block) self.block(state,date,location,type);
}



-(NSDate*)dateForButton:(KPScheduleButtons)button{
    NSDate *date;
    switch (button) {
        case KPScheduleButtonLaterToday:{
            
            NSNumber *laterToday = (NSNumber*)[kSettings valueForSetting:SettingLaterToday];
            date = [[[NSDate date] dateByAddingTimeInterval:laterToday.integerValue] dateToNearest15Minutes];
            break;
        }
        case KPScheduleButtonThisEvening:{
            NSNumber *eveningStartTime = (NSNumber*)[kSettings valueForSetting:SettingEveningStartTime];
            NSInteger hours = eveningStartTime.integerValue/D_HOUR;
            NSInteger minutes = (eveningStartTime.integerValue % D_HOUR) / D_MINUTE;
            date = [NSDate dateThisOrTheNextDayWithHours:hours minutes:minutes];
            break;
        }
        case KPScheduleButtonTomorrow:{
            NSDate *startTime = [NSDate date];
            [self setStartingTimeForDate:&startTime];
            NSDate *now = [NSDate date];
            if([startTime isLaterThanDate:now])
                date = now;
            else
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
            NSNumber *thisWeekend = (NSNumber*)[kSettings valueForSetting:SettingWeekendStart];
            NSNumber *weekendStartTime = (NSNumber*)[kSettings valueForSetting:SettingWeekendStartTime];
            NSInteger hours = weekendStartTime.integerValue/D_HOUR;
            NSInteger minutes = (weekendStartTime.integerValue % D_HOUR) / D_MINUTE;
            date = [NSDate dateThisOrNextWeekWithDay:thisWeekend.integerValue hours:hours minutes:minutes];
            break;
        }
        case KPScheduleButtonNextWeek:{
            NSNumber *nextWeek = (NSNumber*)[kSettings valueForSetting:SettingWeekStart];
            NSNumber *weekStartTime = (NSNumber*)[kSettings valueForSetting:SettingWeekStartTime];
            NSInteger hours = weekStartTime.integerValue/D_HOUR;
            NSInteger minutes = (weekStartTime.integerValue % D_HOUR) / D_MINUTE;
            date = [NSDate dateThisOrNextWeekWithDay:nextWeek.integerValue hours:hours minutes:minutes];
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
        [self pressedLocation:self];
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

-(void)positionHelpLabelForHeight:(CGFloat)height{
    CGRectSetCenterY(self.helpLabel, self.center.y + height/2 + kHelpLevelDistance);
}

-(void)pressedLocation:(id)sender{
    if(!self.isChoosingLocation){
        StartLocationResult result = [NOTIHANDLER startLocationServices];
        if(result != LocationStarted) return;
        self.isChoosingLocation = YES;
        [self animateScheduleButtonsShow:NO duration:0.1];
        
        self.toolbar.alpha = 0;
        CGRectSetWidth(self.toolbar, self.contentView.frame.size.width/3);
        self.toolbar.items = @[@"roundBack"];
        self.toolbar.hidden = NO;
        self.locationView.hidden = NO;
        self.locationView.alpha = 0;
        
        self.leaveOrArrive.hidden = NO;
        self.leaveOrArrive.alpha = 0;
        
        
        CGFloat contentHeight = POPUP_WIDTH + 60;
        CGFloat scaling = contentHeight/POPUP_WIDTH;
        
        CGFloat buttonDuration = 0.1;
        CGFloat scaleDuration = 0.2;
        CGFloat calendarDuration = 0.1;
        CGFloat delay = buttonDuration;
        [self animateScheduleButtonsShow:NO duration:buttonDuration];
        [UIView animateWithDuration:scaleDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.helpLabel.alpha = 0;
            self.contentView.transform = CGAffineTransformMakeScale(1.0, scaling);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            CGRectSetHeight(self.contentView, contentHeight);
            self.contentView.center = self.center;
            [UIView animateWithDuration:calendarDuration animations:^{
                
                self.locationView.alpha = 1;
                self.toolbar.alpha = 1;
                self.leaveOrArrive.alpha = 1;
            } completion:^(BOOL finished) {
                if([self.locationView numberOfHistoryPlaces] == 0) [self.locationView.searchField becomeFirstResponder];
            }];
        }];
        
        
    }
    else{
        if([self.locationView.searchField isFirstResponder]) [self.locationView.searchField resignFirstResponder];
        self.isChoosingLocation = NO;
        CGFloat contentHeight = self.locationView.frame.size.height + kToolbarHeight;
        CGFloat scaling = POPUP_WIDTH/contentHeight;

        
        CGFloat buttonDuration = 0.1;
        CGFloat scaleDuration = 0.2;
        CGFloat calendarDuration = 0.1;
        CGFloat delay = calendarDuration;
        [UIView animateWithDuration:calendarDuration animations:^{
            self.locationView.alpha = 0;
            self.toolbar.alpha = 0;
            self.leaveOrArrive.alpha = 0;
        } completion:^(BOOL finished) {
            self.locationView.hidden = YES;
            self.toolbar.hidden = YES;
            self.leaveOrArrive.hidden = YES;
            self.toolbar.alpha = 1;
        }];
        [UIView animateWithDuration:scaleDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.transform = CGAffineTransformMakeScale(1.0, scaling);
            self.helpLabel.alpha = 1;
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            CGRectSetHeight(self.contentView, POPUP_WIDTH);
            self.contentView.center = self.center;
            [self animateScheduleButtonsShow:YES duration:buttonDuration];
        }];
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
        CGRectSetWidth(self.toolbar, self.contentView.frame.size.width);
        self.toolbar.items = @[@"",@"roundBack",@"roundConfirm",@""];
        self.toolbar.hidden = NO;
        CGFloat buttonDuration = 0.1;
        CGFloat scaleDuration = 0.2;
        CGFloat calendarDuration = 0.1;
        CGFloat delay = buttonDuration;
        [self animateScheduleButtonsShow:NO duration:buttonDuration];
        [UIView animateWithDuration:scaleDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self positionHelpLabelForHeight:contentHeight];
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
            self.toolbar.alpha = 1;
        }];
        [UIView animateWithDuration:scaleDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self positionHelpLabelForHeight:POPUP_WIDTH];
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
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if([otherGestureRecognizer isEqual:self.panRecognizer] && !self.timePicker) return NO;
    return YES;
}
-(void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame{
    
    if(self.isPickingDate){
        CGRectSetHeight(self.contentView, frame.size.height + kToolbarHeight);
        [self positionHelpLabelForHeight:self.contentView.frame.size.height];
        //self.contentView.center = self.center;
    }
}

-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0){
        if(self.isChoosingLocation) [self pressedLocation:self];
    }
    if(item == 1){
        if(self.isPickingDate) [self pressedSpecific:self];
    }
    if(item == 2) [self returnState:KPScheduleButtonSpecificTime date:self.calendarView.selectedDate location:nil];
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
    if(self.timePicker){
        return;
    }
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
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    if(OSVER == 7){
        keyboardHeight = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? keyboardFrame.size.height : keyboardFrame.size.width;
    }
    NSInteger spacing = 3;
    NSInteger startPoint = (OSVER >= 7) ? (20 + spacing) : spacing;
    CGRectSetY(self.contentView,startPoint);
    CGRectSetHeight(self.contentView, self.frame.size.height - keyboardHeight - startPoint- spacing);
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
    MenuButton *button = [[MenuButton alloc] initWithFrame:[self frameForButtonNumber:scheduleButton] title:title];
    button.iconLabel.titleLabel.font = iconFont(41);
    //tcolor(TextColor)
    [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [button.iconLabel setTitle:[self iconStringForScheduleButton:scheduleButton highlighted:NO] forState:UIControlStateNormal];
    [button.iconLabel setTitle:[self iconStringForScheduleButton:scheduleButton highlighted:YES] forState:UIControlStateHighlighted];
    [button setTitleColor:tcolor(LaterColor) forState:UIControlStateNormal];
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

-(NSString *)iconStringForScheduleButton:(KPScheduleButtons)scheduleButton highlighted:(BOOL)highlighted{
    NSString *imageString;
    switch (scheduleButton) {
        case KPScheduleButtonLaterToday:
            imageString = @"scheduleCoffee";
            break;
        case KPScheduleButtonThisEvening:
            imageString = @"scheduleMoon";
            break;
        case KPScheduleButtonTomorrow:
            imageString = @"scheduleSun";
            break;
        case KPScheduleButtonIn2Days:
            imageString = @"scheduleLogbook";
            break;
        case KPScheduleButtonThisWeekend:
            imageString = @"scheduleGlass";
            break;
        case KPScheduleButtonNextWeek:
            imageString = @"scheduleCircle";
            break;
        case KPScheduleButtonUnscheduled:
            imageString = @"scheduleCloud";
            break;
        case KPScheduleButtonLocation:
            imageString = @"scheduleLocation";
            break;
        case KPScheduleButtonSpecificTime:
            imageString = @"scheduleCalendar";
            break;
        default:
            break;
    }
    if(highlighted) imageString = [imageString stringByAppendingString:@"Full"];
    return iconString(imageString);
}

-(void)addLocationView{
    self.locationView = [[LocationSearchView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height-kToolbarHeight-kToolbarPadding)];
    self.locationView.hidden = YES;
    self.locationView.delegate = self;
    self.locationView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    [self.contentView addSubview:self.locationView];
    /*UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Arrive",@"Leave"]];
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:KP_LIGHT(15), UITextAttributeFont, nil] forState:UIControlStateNormal];
    [segmentedControl setSelectedSegmentIndex:0];
    if(OSVER < 7){
        NSDictionary *attributes = @{UITextAttributeTextColor:tcolor(TextColor),UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]};
        [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        NSDictionary *highlightedAttributes = @{UITextAttributeTextColor:tcolor(TextColor),UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]};
        [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
        
        // Change color of selected segment
        
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        segmentedControl.backgroundColor = CLEAR;
        segmentedControl.tintColor = tcolor(BackgroundColor);

        // Add rounded yellow corner to segmented controll view
        [segmentedControl.layer setCornerRadius:4.0f];
        [segmentedControl.layer setBorderColor:tcolor(TextColor).CGColor];
        [segmentedControl.layer setBorderWidth:0.f];
        [segmentedControl.layer setShadowColor:CLEAR.CGColor];
        [segmentedControl.layer setShadowOpacity:0];
        [segmentedControl.layer setShadowRadius:0];
        [segmentedControl.layer setShadowOffset:CGSizeMake(0, 0)];
    }
    else [segmentedControl setTintColor:tcolor(TextColor)];
    segmentedControl.hidden = YES;
    CGFloat padding = (self.contentView.frame.size.width/4-41)/2;
    CGRectSetHeight(segmentedControl, 41);
    CGRectSetWidth(segmentedControl, 150);
    segmentedControl.center = CGPointMake(self.contentView.frame.size.width-segmentedControl.frame.size.width/2-padding, self.contentView.frame.size.height-kToolbarHeight/2-kToolbarPadding/2);
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.leaveOrArrive = segmentedControl;
    [self.contentView addSubview:self.leaveOrArrive];*/
    
}

-(void)addPickerView{
    //UIColor *weekdayColor = [[tcolor(SearchDrawerBackground) getColorSaturatedWithPercentage:-0.5] getColorBrightenedWithPercentage:0.5];
    self.calendarView = [[CKCalendarView alloc] initWithFrame:CGRectMake(0, 0, CONTENT_VIEW_SIZE, CONTENT_VIEW_SIZE)];
    self.calendarView.onlyShowCurrentMonth = NO;
    self.calendarView.hidden = YES;
    self.calendarView.delegate = self;
    self.calendarView.backgroundColor = CLEAR;
    [self setCalendarDate:[NSDate date]];
    self.calendarView.titleColor = tcolor(TextColor);
    
    self.calendarView.dayOfWeekTextColor = tcolor(LaterColor);//tcolorF(TextColor,ThemeDark);
    self.calendarView.adaptHeightToNumberOfWeeksInMonth = YES;
    
    self.toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-kToolbarHeight, self.contentView.frame.size.width, kToolbarHeight-kToolbarPadding) items:nil delegate:self];
    self.toolbar.hidden = YES;
    self.toolbar.font = iconFont(41);
    self.toolbar.titleColor = tcolor(TextColor); //tcolorF(TextColor,ThemeDark);
    self.toolbar.titleHighlightString = @"Full";
    self.toolbar.items = @[@"",@"roundBack",@"roundConfirm",@""];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.toolbar.backgroundColor = CLEAR;
    
    [self.contentView addSubview:self.toolbar];
    [self.contentView addSubview:self.calendarView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //self.backgroundColor = tcolor(LaterColor);
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(cancelled) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = self.bounds;
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [self addSubview:closeButton];
        
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        helpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        helpLabel.backgroundColor = CLEAR;
        helpLabel.textColor = alpha(tcolorF(SubTextColor,ThemeLight),0.8);
        helpLabel.textAlignment = NSTextAlignmentCenter;
        helpLabel.text = LOCALIZE_STRING(@"Hold down to adjust time");
        helpLabel.font = KP_REGULAR(13);
        self.helpLabel = helpLabel;
        [self addSubview:helpLabel];
        
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPUP_WIDTH, POPUP_WIDTH)];
        contentView.autoresizesSubviews = YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        contentView.center = self.center;
        
        contentView.backgroundColor = retColor(tcolor(BackgroundColor), gray(248,1));
        contentView.layer.cornerRadius = 10;
        //contentView.layer.masksToBounds = YES;
        contentView.layer.shadowOffset = CGSizeMake(0, 1);
        //contentView.layer.shadowRadius = 10;
        contentView.layer.shadowColor = tcolorF(BackgroundColor,ThemeDark).CGColor;
        contentView.layer.shadowOpacity = 0.7;
        contentView.tag = CONTENT_VIEW_TAG;
        
        /* Schedule buttons */
        NSNumber *laterToday = (NSNumber*)[kSettings valueForSetting:SettingLaterToday];
        NSString *title = [NSString stringWithFormat:LOCALIZE_STRING(@"Later  +%luh"),(long)(laterToday.integerValue/3600)];
        UIButton *laterTodayButton = [self buttonForScheduleButton:KPScheduleButtonLaterToday title:title];
        [contentView addSubview:laterTodayButton];
        NSNumber *eveningStartTime = (NSNumber*)[kSettings valueForSetting:SettingEveningStartTime];
        NSInteger hours = eveningStartTime.integerValue/D_HOUR;
        NSInteger minutes = (eveningStartTime.integerValue % D_HOUR) / D_MINUTE;
        NSDate *thisEveningTime = [[NSDate date] dateAtHours:hours minutes:minutes];
        NSString *thisEveText = ([[NSDate date] isLaterThanDate:thisEveningTime]) ? LOCALIZE_STRING(@"Tomorrow Eve") : LOCALIZE_STRING(@"This Evening");
        UIButton *thisEveningButton = [self buttonForScheduleButton:KPScheduleButtonThisEvening title:thisEveText];
        [contentView addSubview:thisEveningButton];
        UIButton *tomorrowButton = [self buttonForScheduleButton:KPScheduleButtonTomorrow title:LOCALIZE_STRING(@"Tomorrow")];
        [contentView addSubview:tomorrowButton];
        NSDate *twoDaysDate = [NSDate dateWithDaysFromNow:2];
        NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:LOCALIZE_STRING(@"en_US")];
        [weekday setLocale:usLocale];
        [weekday setDateFormat: @"EEEE"];
        NSString *twoDaysString = [[weekday stringFromDate:twoDaysDate] capitalizedString];
        UIButton *in2DaysButton = [self buttonForScheduleButton:KPScheduleButtonIn2Days title:twoDaysString];
        [contentView addSubview:in2DaysButton];
        UIButton *thisWeekendButton = [self buttonForScheduleButton:KPScheduleButtonThisWeekend title:LOCALIZE_STRING(@"This Weekend")];
        [contentView addSubview:thisWeekendButton];
        UIButton *nextWeekButton = [self buttonForScheduleButton:KPScheduleButtonNextWeek title:LOCALIZE_STRING(@"Next Week")];
        [contentView addSubview:nextWeekButton];
        UIButton *specificTimeButton = [self buttonForScheduleButton:KPScheduleButtonSpecificTime title:LOCALIZE_STRING(@"Pick A Date")];
        [contentView addSubview:specificTimeButton];
        UIButton *locationButton = [self buttonForScheduleButton:KPScheduleButtonLocation title:LOCALIZE_STRING(@"At Location")];
        if( [kUserHandler isPlus] )
            [contentView addSubview:locationButton];
        
        UIButton *unspecifiedButton = [self buttonForScheduleButton:KPScheduleButtonUnscheduled title:LOCALIZE_STRING(@"Unspecified")];
        [contentView addSubview:unspecifiedButton];
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        self.panRecognizer.delegate = self;
        [contentView addGestureRecognizer:self.panRecognizer];
        
        [self addSubview:contentView];
        self.contentView = [self viewWithTag:CONTENT_VIEW_TAG];
        [self positionHelpLabelForHeight:CGRectGetHeight(self.contentView.frame)];
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

-(void)layoutSubviews{
    [super layoutSubviews];
    [self positionHelpLabelForHeight:self.contentView.frame.size.height];
}

-(void)dealloc{
    clearNotify();
    self.calendarView = nil;
    self.locationView = nil;
}
@end