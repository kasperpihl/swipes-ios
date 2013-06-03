//
//  AlarmView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define POPUP_WIDTH 300
#define CONTENT_VIEW_TAG 1
#define SELECT_DATE_VIEW_TAG 3
#define DATE_PICKER_TAG 4
#define MONTH_LABEL_TAG 5
#define BACK_ONE_MONTH_BUTTON_TAG 6
#define FORWARD_ONE_MONTH_BUTTON_TAG 7

#define SEPERATOR_COLOR_DARK gray(77,0.7)

#define PICK_DATE_BUTTON_HEIGHT 45

#define PICKER_CUT_HEIGHT 10
#define PICKER_CUT_WIDTH 15


#define MONTH_LABEL_Y 10
#define MONTH_LABEL_HEIGHT 30

#import "AlarmPopup.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
#import "AlarmView.h"
@interface AlarmView ()
@property (nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,weak) IBOutlet UILabel *monthLabel;
@property (nonatomic,weak) IBOutlet UIView *selectDateView;
@property (nonatomic,weak) IBOutlet UIButton *backOneMonth;
@property (nonatomic,weak) IBOutlet UIButton *forwardOneMonth;

@end
@implementation AlarmView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *selectDateView = [[UIView alloc] initWithFrame:self.bounds];
        selectDateView.tag = SELECT_DATE_VIEW_TAG;
        selectDateView.backgroundColor = POPUP_BACKGROUND; //POPUP_BACKGROUND_COLOR
        selectDateView.layer.masksToBounds = YES;
        
        /*UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, selectDateView.frame.size.height-COLOR_SEPERATOR_HEIGHT, selectDateView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        colorBottomSeperator.backgroundColor = SWIPES_COLOR;
        [selectDateView addSubview:colorBottomSeperator];*/
        
        
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
        picker.minimumDate = [NSDate date];
        picker.date = [[[NSDate dateTomorrow] dateAtStartOfDay] dateByAddingHours:9];
        picker.minuteInterval = 5;
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
        
        
        
        CGFloat buttonY = selectDateView.frame.size.height-PICK_DATE_BUTTON_HEIGHT;
        CGFloat buttonWidth = selectDateView.frame.size.width/2;
        
        UIView *pickerButtonSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, buttonY-COLOR_SEPERATOR_HEIGHT, selectDateView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        pickerButtonSeperator.backgroundColor = SWIPES_COLOR;
        [selectDateView addSubview:pickerButtonSeperator];
        
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.titleLabel.font = BUTTON_FONT;
        backButton.frame = CGRectMake(0, buttonY , buttonWidth , PICK_DATE_BUTTON_HEIGHT);
        [backButton addTarget:self action:@selector(pressedRemove) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:@"CLEAR" forState:UIControlStateNormal];
        [selectDateView addSubview:backButton];
        
        
        UIView *dateButtonsSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, buttonY, SEPERATOR_WIDTH, PICK_DATE_BUTTON_HEIGHT)];
        dateButtonsSeperator.backgroundColor = SEGMENT_SELECTED;
        [selectDateView addSubview:dateButtonsSeperator];
        
        
        UIButton *setDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        setDateButton.titleLabel.font = BUTTON_FONT;
        setDateButton.frame = CGRectMake(buttonWidth, buttonY,buttonWidth , PICK_DATE_BUTTON_HEIGHT);
        [setDateButton setTitle:@"REMIND ME" forState:UIControlStateNormal];
        [setDateButton addTarget:self action:@selector(selectedDate:) forControlEvents:UIControlEventTouchUpInside];
        [selectDateView addSubview:setDateButton];
        [self addSubview:selectDateView];
    }
    return self;
}

-(void)pressedRemove{
   
}
-(void)selectedDate:(UIButton*)sender{
    
}
-(void)setPickerDate:(NSDate*)pickerDate{
    self.datePicker.date = pickerDate;
    [self changedDate:self.datePicker];
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
@end
