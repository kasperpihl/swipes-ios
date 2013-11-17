//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define CONTENT_VIEW_TAG 9
#define SHOW_ITEM_TAG 5432


#define TOOLBAR_HEIGHT GLOBAL_TOOLBAR_HEIGHT
#define DEFAULT_ROW_HEIGHT 60
#define SCHEDULE_ROW_HEIGHTS 46
#define LABEL_X CELL_LABEL_X

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 15
#define TITLE_WIDTH (320)
#define TITLE_BOTTOM_MARGIN (TITLE_TOP_MARGIN)
#define CONTAINER_INIT_HEIGHT (TITLE_HEIGHT + TITLE_TOP_MARGIN + TITLE_BOTTOM_MARGIN)


#define TAGS_LABEL_RECT CGRectMake(LABEL_X,TAGS_LABEL_PADDING,320-LABEL_X-10,500)

#define TAGS_LABEL_PADDING 18.5
#define NOTES_PADDING 13.5
#define kRepeatPickerHeight 70
#import "StyleHandler.h"

#import "ToDoListViewController.h"
#import "KPSegmentedViewController.h"
#import "ToDoViewController.h"
#import "HPGrowingTextView.h"
#import "NotesView.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
#import "KPToolbar.h"
#import "KPBlurry.h"
#import "UIColor+Utilities.h"
#import "KPRepeatPicker.h"
//#import "UIButton+PassTouch.h"
#import "AppDelegate.h"
#import "KPTimePicker.h"
#import "DotView.h"
typedef NS_ENUM(NSUInteger, KPEditMode){
    KPEditModeNone = 0,
    KPEditModeTitle,
    KPEditModeRepeat,
    KPEditModeTags,
    KPEditModeAlarm,
    KPEditModeNotes
};

@interface ToDoViewController () <HPGrowingTextViewDelegate,NotesViewDelegate,ToolbarDelegate,KPRepeatPickerDelegate,KPTimePickerDelegate>
@property (nonatomic) KPEditMode activeEditMode;


@property (nonatomic) UIView *titleContainerView;
@property (nonatomic) HPGrowingTextView *textView;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *tagsContainerView;
@property (nonatomic) UIView *alarmContainer;
@property (nonatomic) UIView *notesContainer;
@property (nonatomic) UIView *repeatedContainer;
@property (nonatomic) KPRepeatPicker *repeatPicker;

@property (nonatomic) UILabel *alarmLabel;
@property (nonatomic) UILabel *tagsLabel;
@property (nonatomic) UITextView *notesView;
@property (nonatomic) UILabel *repeatedLabel;


@property (nonatomic) KPToolbar *toolbarEditView;
@property (nonatomic) DotView *dotView;

@property (nonatomic,strong) KPTimePicker *timePicker;

@end

@implementation ToDoViewController
-(id)init{
    self = [super init];
    if(self){
        self.view.tag = SHOW_ITEM_TAG;
        self.view.backgroundColor = tbackground(BackgroundColor);
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        contentView.tag = CONTENT_VIEW_TAG;
        contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        
        self.titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CONTAINER_INIT_HEIGHT)];
        self.titleContainerView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
        
        CGFloat buttonWidth = BUTTON_HEIGHT;
        
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(CELL_LABEL_X, TITLE_TOP_MARGIN, TITLE_WIDTH-buttonWidth-CELL_LABEL_X, TITLE_HEIGHT)];
        self.textView.contentInset = UIEdgeInsetsMake(0, -8, 0, -8);
        self.textView.minNumberOfLines = 1;
        self.textView.backgroundColor = CLEAR;
        self.textView.maxNumberOfLines = 6;
        self.textView.returnKeyType = UIReturnKeyDone; //just as an example
        self.textView.font = EDIT_TASK_TITLE_FONT;
        self.textView.delegate = self;
        self.textView.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        self.textView.textColor = tcolor(TaskCellTitle);
        [self.titleContainerView addSubview:self.textView];
        
        CGFloat dotWidth = CELL_LABEL_X;
        DotView *dotView = [[DotView alloc] init];
        dotView.dotColor = tcolor(TasksColor);
        UIButton *priorityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, dotWidth, CONTAINER_INIT_HEIGHT)];
        priorityButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [priorityButton addTarget:self action:@selector(pressedPriority) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetCenter(dotView, dotWidth/2, self.textView.frame.size.height/2+TITLE_TOP_MARGIN);
        dotView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
        [priorityButton addSubview:dotView];
        [self.titleContainerView addSubview:priorityButton];
        self.dotView = dotView;
        
        [contentView addSubview:self.titleContainerView];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleContainerView.frame.size.height, 320, contentView.frame.size.height - self.titleContainerView.frame.size.height-TOOLBAR_HEIGHT)];
        //self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.alwaysBounceVertical = YES;
        
        
        /*
            Alarm container and button!
        */
        self.alarmContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SCHEDULE_ROW_HEIGHTS)];
        [self addAndGetImage:@"edit_schedule_icon" inView:self.alarmContainer];
        self.alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X, self.alarmContainer.frame.size.height)];
        self.alarmLabel.backgroundColor = CLEAR;
        [self setColorsFor:self.alarmLabel];
        self.alarmLabel.font = EDIT_TASK_TEXT_FONT;
        [self.alarmContainer addSubview:self.alarmLabel];
        UIButton *alarmButton = [self addClickButtonToView:self.alarmContainer action:@selector(pressedAlarm:)];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
        longPressGestureRecognizer.allowableMovement = 44.0f;
        longPressGestureRecognizer.minimumPressDuration = 0.7f;
        [alarmButton addGestureRecognizer:longPressGestureRecognizer];
        [self.scrollView addSubview:self.alarmContainer];

        self.repeatedContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SCHEDULE_ROW_HEIGHTS)];
        self.repeatedContainer.userInteractionEnabled = YES;
        self.repeatedContainer.layer.masksToBounds = YES;
        
        self.repeatPicker = [[KPRepeatPicker alloc] initWithHeight:70 selectedDate:[NSDate date] option:RepeatNever];
        self.repeatPicker.delegate = self;
        CGRectSetY(self.repeatPicker, self.repeatedContainer.frame.size.height);
        [self.repeatedContainer addSubview:self.repeatPicker];
        
        [self addAndGetImage:@"edit_repeat_icon" inView:self.repeatedContainer];
        self.repeatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X, self.repeatedContainer.frame.size.height)];
        self.repeatedLabel.backgroundColor = CLEAR;
        [self setColorsFor:self.repeatedLabel];
        self.repeatedLabel.font = EDIT_TASK_TEXT_FONT;
        [self.repeatedContainer addSubview:self.repeatedLabel];
        UIButton *clickButton = [self addClickButtonToView:self.repeatedContainer action:@selector(pressedRepeat:)];
        clickButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        [self.scrollView addSubview:self.repeatedContainer];
        /*
            Tags Container with button!
        */
        self.tagsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEFAULT_ROW_HEIGHT)];
        //[self addSeperatorToView:self.tagsContainerView];
        [self addAndGetImage:@"edit_tags_icon" inView:self.tagsContainerView];
        
        self.tagsLabel = [[UILabel alloc] initWithFrame:TAGS_LABEL_RECT];
        self.tagsLabel.numberOfLines = 0;
        self.tagsLabel.font = EDIT_TASK_TEXT_FONT;
        self.tagsLabel.backgroundColor = [UIColor clearColor];
        [self setColorsFor:self.tagsLabel];
        [self.tagsContainerView addSubview:self.tagsLabel];
        
        [self addClickButtonToView:self.tagsContainerView action:@selector(pressedTags:)];
        
        [self.scrollView addSubview:self.tagsContainerView];
        
        /*
         Notes view
        */
        self.notesContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEFAULT_ROW_HEIGHT)];
        [self addAndGetImage:@"edit_notes_icon" inView:self.notesContainer];
        self.notesView = [[UITextView alloc] initWithFrame:CGRectMake(LABEL_X, NOTES_PADDING, 320-LABEL_X-10, 500)];
        self.notesView.font = EDIT_TASK_TEXT_FONT;
        self.notesView.contentInset = UIEdgeInsetsMake(0,-5,0,0);
        self.notesView.editable = NO;
        self.notesView.textColor = tcolor(TagColor);
        self.notesView.backgroundColor = CLEAR;
        [self.notesContainer addSubview:self.notesView];
        
        [self addClickButtonToView:self.notesContainer action:@selector(pressedNotes:)];        
        [self.scrollView addSubview:self.notesContainer];
        
        
        /* Adding scroll and content view */
        [contentView addSubview:self.scrollView];
        
        self.toolbarEditView = [[KPToolbar alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height-TOOLBAR_HEIGHT, contentView.frame.size.width, TOOLBAR_HEIGHT) items:@[@"backarrow_icon_white",@"trashcan_icon_white",@"share_icon_white"]];
        self.toolbarEditView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin);
        self.toolbarEditView.delegate = self;
        [contentView addSubview:self.toolbarEditView];
        
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
        
    }
    return self;
}
-(void)longPressRecognized:(UIGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self openTimePicker];
    }
}
-(void)openTimePicker{
    if(self.timePicker) return;
    NSDate *date = self.model.schedule;
    if(!date || [date isInPast]) return;
    self.timePicker = [[KPTimePicker alloc] initWithFrame:self.segmentedViewController.view.bounds];
    self.timePicker.delegate = self;
    self.timePicker.pickingDate = date;
    self.timePicker.minimumDate = [date dateAtStartOfDay];
    if([date isToday]) self.timePicker.minimumDate = [[NSDate date] dateByAddingMinutes:5];
    self.timePicker.maximumDate = [[[date dateByAddingDays:1] dateAtStartOfDay] dateBySubtractingMinutes:5];
    self.timePicker.alpha = 0;
    [self.segmentedViewController.view addSubview:self.timePicker];
    [UIView animateWithDuration:0.2f animations:^{
        self.timePicker.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)timePicker:(KPTimePicker *)timePicker selectedDate:(NSDate *)date{
    [UIView animateWithDuration:0.2f animations:^{
        timePicker.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished){
            [timePicker removeFromSuperview];
            self.timePicker = nil;
            if(date) [KPToDo scheduleToDos:@[self.model] forDate:date save:YES];
        }
    }];
    
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0 && [self.delegate respondsToSelector:@selector(didPressCloseToDoViewController:)]){
        [self.delegate didPressCloseToDoViewController:self];
    }
    else if(item == 1){
        [self.segmentedViewController pressedDelete:self];
    }
    else if(item == 2){
        [self.segmentedViewController pressedShare:self];
    }
}
-(void)repeatPicker:(KPRepeatPicker *)repeatPicker selectedOption:(RepeatOptions)option{
    self.activeEditMode = KPEditModeNone;
    if(option != self.model.repeatOptionValue){
        [self.model setRepeatOption:option save:YES];
    }
    [self updateRepeated];
    [self layout];
}
-(void)setColorsFor:(id)object{
    if([object respondsToSelector:@selector(setTextColor:)]) [object setTextColor:tcolor(TagColor)];
    //if([object respondsToSelector:@selector(setHighlightedTextColor:)]) [object setHighlightedTextColor:EDIT_TASK_GRAYED_OUT_TEXT];
}
-(UIImageView *)addAndGetImage:(NSString*)imageName inView:(UIView*)view{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.image = [UIImage imageNamed:imageName];//[UtilityClass imageNamed: withColor:EDIT_TASK_GRAYED_OUT_TEXT];
    imageView.frame = CGRectSetPos(imageView.frame,(LABEL_X-imageView.frame.size.width)/2, (view.frame.size.height-imageView.frame.size.height)/2);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    [view addSubview:imageView];
    return imageView;
}
-(UIButton*)addClickButtonToView:(UIView*)view action:(SEL)action{
    UIButton *clickedButton = [[UIButton alloc] initWithFrame:view.bounds];
    clickedButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [clickedButton setBackgroundImage:[color(55,55,55,0.1) image] forState:UIControlStateHighlighted];
    //clickedButton.contentEdgeInsets = UIEdgeInsetsMake(0, LABEL_X, 0, LABEL_X/3);
    [clickedButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:clickedButton];
    return clickedButton;
}
-(void)addSeperatorToView:(UIView*)view{
    CGFloat seperatorHeight = 1;
    CGFloat leftMargin = LABEL_X;
    CGFloat rightMargin = LABEL_X/3;
    
    UIView *seperator2View = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, view.frame.size.width-rightMargin-leftMargin, seperatorHeight)];
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, view.frame.size.height-seperatorHeight, view.frame.size.width-rightMargin-leftMargin, seperatorHeight)];
    seperatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    seperator2View.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    seperatorView.backgroundColor = seperator2View.backgroundColor = tbackground(BackgroundColor);//tbackground(EditTaskTitleBackground);
    [view addSubview:seperatorView];
    [view addSubview:seperator2View];
}
-(void)setActiveEditMode:(KPEditMode)activeEditMode{
    if(activeEditMode != _activeEditMode){
        KPEditMode oldState = _activeEditMode;
        _activeEditMode = activeEditMode;
        if(activeEditMode != KPEditModeNone) [self clearActiveEditMode:oldState];
    }
}
-(void)clearActiveEditMode:(KPEditMode)state{
    switch (state) {
        case KPEditModeTitle:{
            [self.textView resignFirstResponder];
            break;
        }
        case KPEditModeRepeat:
            [self updateRepeated];
            [self layout];
            break;
        case KPEditModeTags:
        case KPEditModeAlarm:
        case KPEditModeNotes:
        case KPEditModeNone:
            break;
    }
}


#pragma mark HPGrowingTextViewDelegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    if(growingTextView.text.length > 255) growingTextView.text = [growingTextView.text substringToIndex:254];
}
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    self.activeEditMode = KPEditModeTitle;
}
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    growingTextView.text = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if(growingTextView.text.length > 0){
        self.model.title = growingTextView.text;
        [self.model save];
    }
    else{
        growingTextView.text = self.model.title;
    }
    self.activeEditMode = KPEditModeNone;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [growingTextView resignFirstResponder];
    return NO;
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGFloat titleHeight = height+TITLE_TOP_MARGIN+TITLE_BOTTOM_MARGIN;
    CGRectSetHeight(self.titleContainerView,titleHeight);
    CGRectSetY(self.scrollView, titleHeight);
    CGRectSetHeight(self.scrollView, self.contentView.frame.size.height-titleHeight-TOOLBAR_HEIGHT);
}
#pragma mark NotesViewDelegate
-(void)pressedPriority{
    self.model.priorityValue = (self.model.priorityValue == 0) ? 1 : 0;
    [self.model save];
    [self updateDot];
}
-(void)savedNotesView:(NotesView *)notesView text:(NSString *)text{
    [BLURRY dismissAnimated:YES];
    self.model.notes = text;
    [self.model save];
    [self updateNotes];
    [self layout];
}
-(void)pressedCancelNotesView:(NotesView *)notesView{
    [BLURRY dismissAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)updateNotes{
    if(!self.model.notes || self.model.notes.length == 0){
        self.notesView.text = @"Add notes";
    }
    else{
        self.notesView.text = self.model.notes;
    }
    self.notesView.frame = CGRectSetSize(self.notesView, self.view.frame.size.width, 500);
    //CGSize contentSize = [self.notesView sizeThatFits:CGSizeMake(self.notesView.frame.size.width, 500)];
    [self.notesView sizeToFit];
    CGRectSetHeight(self.notesContainer, self.notesView.frame.size.height+2*NOTES_PADDING);
}
-(void)updateRepeated{
    NSDate *repeatDate = self.model.repeatedDate;
    if(!repeatDate) repeatDate = self.model.schedule;
    if(repeatDate){
        if(![self.repeatPicker.selectedDate isEqualToDate:repeatDate] || self.repeatPicker.currentOption != self.model.repeatOptionValue)  [self.repeatPicker setSelectedDate:repeatDate option:self.model.repeatOptionValue];
    }
    else return;
    NSString* labelText;
    NSString *timeInString = [UtilityClass timeStringForDate:self.model.repeatedDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    BOOL addTime = YES;
    if(self.activeEditMode == KPEditModeRepeat){
        labelText = @"Repeat every...";
    }else{
        switch (self.model.repeatOptionValue) {
            case RepeatEveryDay:{
                labelText = @"Every day";
                break;
            }
            case RepeatEveryMonFriOrSatSun:{
                if(self.model.repeatedDate.isTypicallyWeekend) labelText = @"Every Saturday and Sunday";
                else labelText = @"Every Monday to Friday";
                break;
            }
            case RepeatEveryWeek:{
                [dateFormatter setDateFormat:@"EEEE"];
                NSString *weekday = [dateFormatter stringFromDate:self.model.repeatedDate];
                labelText = [NSString stringWithFormat:@"Every %@",weekday];
                break;
            }
            case RepeatEveryMonth:{
                NSString *dateOfMonth = [UtilityClass dayOfMonthForDate:self.model.repeatedDate];
                labelText = [NSString stringWithFormat:@"Every month the %@",dateOfMonth];
                break;
            }
            case RepeatEveryYear:{
                NSString *dateOfMonth = [UtilityClass dayOfMonthForDate:self.model.repeatedDate];
                [dateFormatter setDateFormat:@"MMMM"];
                NSString *month = [dateFormatter stringFromDate:self.model.repeatedDate];
                labelText = [NSString stringWithFormat:@"Every year %@ %@",month,dateOfMonth];
                break;
            }
            default:
                addTime = NO;
                labelText = @"Never repeat";
                break;
        }
        if(addTime) labelText = [labelText stringByAppendingFormat:@" at %@",timeInString];
    }
    self.repeatedLabel.text = labelText;
}
-(void)layoutWithHeight:(CGFloat)height{
    CGRectSetHeight(self.view, height);
    CGRectSetY(self.scrollView, self.titleContainerView.frame.size.height);
    CGRectSetHeight(self.scrollView, self.contentView.frame.size.height-self.titleContainerView.frame.size.height-TOOLBAR_HEIGHT);
    CGRectSetY(self.toolbarEditView, self.contentView.frame.size.height - TOOLBAR_HEIGHT);
    self.toolbarEditView.autoresizingMask = UIViewAutoresizingNone;
}
-(void)injectInCell:(UITableViewCell *)cell{
    if(self.view.superview)[self.view removeFromSuperview];
    [self layoutWithHeight:cell.frame.size.height];
    [cell.contentView addSubview:self.view];
}
-(void)updateTags{
    self.tagsLabel.frame = TAGS_LABEL_RECT;
    NSString *tagsString = self.model.tagString;
    if(!tagsString || tagsString.length == 0){
        tagsString = @"Set tags";
    }
    self.tagsLabel.text = tagsString;
    [self.tagsLabel sizeToFit];

    CGFloat containerHeight = self.tagsLabel.frame.size.height + 2*TAGS_LABEL_PADDING;
    CGRectSetHeight(self.tagsContainerView, containerHeight);
}
-(void)updateDot{
    
    self.dotView.dotColor = [StyleHandler colorForCellType:[self.model cellTypeForTodo]];
    self.dotView.priority = (self.model.priorityValue == 1);
}
-(void)updateSchedule{
    if(!self.model.schedule){// || [self.model.schedule isInPast]){
        self.alarmLabel.text = @"Unspecified";
        if(self.model.completionDate){
            self.alarmLabel.text = [NSString stringWithFormat:@"Completed: %@",[self.model readableTime:self.model.completionDate showTime:YES]];
        }
    }
    else{
        self.alarmLabel.text = [NSString stringWithFormat:@"%@",[self.model readableTime:self.model.schedule showTime:YES]];
    }
}
-(void)update{
    self.textView.text = self.model.title;
    [self updateTags];
    [self updateSchedule];
    [self updateNotes];
    [self updateDot];
    [self updateRepeated];
    [self layout];
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
    }
    [self update];
}
-(void)layout{
    CGFloat tempHeight = 0;
    CGRectSetY(self.alarmContainer, tempHeight);
    tempHeight += self.alarmContainer.frame.size.height;
    
    self.repeatedContainer.hidden = !self.model.schedule;
    if(!self.repeatedContainer.hidden){
        CGFloat repeatHeight = (self.activeEditMode == KPEditModeRepeat) ? SCHEDULE_ROW_HEIGHTS+kRepeatPickerHeight : SCHEDULE_ROW_HEIGHTS;
        CGRectSetHeight(self.repeatedContainer, repeatHeight);
        CGRectSetY(self.repeatedContainer, tempHeight);
        tempHeight += self.repeatedContainer.frame.size.height;
    }
    CGRectSetY(self.tagsContainerView, tempHeight);
    tempHeight += self.tagsContainerView.frame.size.height;
    
    CGRectSetY(self.notesContainer, tempHeight);
    tempHeight += self.notesContainer.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,tempHeight);
}
-(void)pressedRepeat:(id)sender{
    if(self.activeEditMode == KPEditModeRepeat){
        self.activeEditMode = KPEditModeNone;
    }
    else{
        self.activeEditMode = KPEditModeRepeat;
    }
    [self updateRepeated];
    [self layout];
}
-(void)pressedDone:(id)sender{
    [self.delegate didPressCloseToDoViewController:self];
}
-(void)pressedAlarm:(id)sender{
    self.activeEditMode = KPEditModeAlarm;
    if([self.delegate respondsToSelector:@selector(scheduleToDoViewController:)]) [self.delegate scheduleToDoViewController:self];
}
-(void)pressedNotes:(id)sender{
    CGFloat extra = (OSVER >= 7) ? 0 : 0;
    NotesView *notesView = [[NotesView alloc] initWithFrame:CGRectMake(0, 0+extra, 320, self.segmentedViewController.view.frame.size.height-extra)];
    [notesView setNotesText:self.model.notes title:self.model.title];
    notesView.delegate = self;
    BLURRY.showPosition = PositionBottom;
    [BLURRY showView:notesView inViewController:self.segmentedViewController];
}
-(void)pressedTags:(id)sender{
    self.activeEditMode = KPEditModeTags;
    [self.segmentedViewController tagViewWithDismissAction:^{
        self.activeEditMode = KPEditModeNone;
        [self updateTags];
        [self layout];
    }];
}
-(void)dealloc{
    self.scrollView = nil;
    self.alarmContainer = nil;
    self.tagsContainerView = nil;
    self.notesContainer = nil;
    self.titleContainerView = nil;
    self.toolbarEditView = nil;
    self.alarmLabel = nil;
    self.tagsLabel =  nil;
    self.notesView = nil;
    self.dotView = nil;
    self.textView = nil;
    
    self.repeatedContainer = nil;
    self.repeatedLabel = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
