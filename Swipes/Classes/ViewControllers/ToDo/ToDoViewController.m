//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define CONTENT_VIEW_TAG 9
#define SHOW_ITEM_TAG 5432


#define TOOLBAR_HEIGHT 52
#define DEFAULT_ROW_HEIGHT 60
#define SCHEDULE_ROW_HEIGHTS 46
#define LABEL_X CELL_LABEL_X

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 15
#define TITLE_WIDTH (320)
#define TITLE_BOTTOM_MARGIN (10)
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
#import "KPRepeatPicker.h"
//#import "UIButton+PassTouch.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import "KPTimePicker.h"
#import "DotView.h"
#import "EvernoteView.h"
#import "MCSwipeTableViewCell.h"

#import "SectionHeaderView.h"

#import "SchedulePopup.h"
#import "ToDoViewController+ViewHelpers.h"

typedef NS_ENUM(NSUInteger, KPEditMode){
    KPEditModeNone = 0,
    KPEditModeTitle,
    KPEditModeRepeat,
    KPEditModeTags,
    KPEditModeAlarm,
    KPEditModeNotes,
    KPEditModeEvernote
};

@interface ToDoViewController () <HPGrowingTextViewDelegate, NotesViewDelegate,EvernoteViewDelegate, ToolbarDelegate,KPRepeatPickerDelegate,KPTimePickerDelegate,MCSwipeTableViewCellDelegate>
@property (nonatomic) KPEditMode activeEditMode;

@property (nonatomic) CellType cellType;
@property (nonatomic) MCSwipeTableViewCell *cell;
@property (nonatomic) UIButton *backButton;
@property (nonatomic,weak) IBOutlet UIView *contentView;

@property (nonatomic) SectionHeaderView *sectionHeader;

@property (nonatomic) UIView *titleContainerView;
@property (nonatomic) HPGrowingTextView *textView;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *tagsContainerView;
@property (nonatomic) UIView *alarmContainer;
@property (nonatomic) UIView *notesContainer;
@property (nonatomic) UIView *repeatedContainer;
@property (nonatomic) UIView *evernoteContainer;
@property (nonatomic) KPRepeatPicker *repeatPicker;

@property (nonatomic) UILabel *alarmLabel;
@property (nonatomic) UILabel *tagsLabel;
@property (nonatomic) UITextView *notesView;
@property (nonatomic) UILabel *repeatedLabel;
@property (nonatomic) UILabel *evernoteLabel;
@property (nonatomic) KPToolbar *toolbarEditView;
@property (nonatomic) DotView *dotView;


@property (nonatomic) NSString *objectId;
@property (nonatomic,strong) KPTimePicker *timePicker;

@end

@implementation ToDoViewController
-(id)init{
    self = [super init];
    if(self){
        self.view.tag = SHOW_ITEM_TAG;
        self.view.backgroundColor = tbackground(BackgroundColor);
        
        
        NSInteger startY = (OSVER >= 7) ? 20 : 0;
        NSInteger toolbarWidth = 120;
        self.toolbarEditView = [[KPToolbar alloc] initWithFrame:CGRectMake(320-toolbarWidth, startY, toolbarWidth, TOOLBAR_HEIGHT) items:@[@"share_icon_white",@"trashcan_icon_white"] delegate:self];
        [self.view addSubview:self.toolbarEditView];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, startY, 160, TOOLBAR_HEIGHT)];
        [backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:@"Schedule" forState:UIControlStateNormal];
        backButton.titleLabel.font = KP_LIGHT(16);
        [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [backButton setImage:[UIImage imageNamed:@"backarrow_small_icon_white"] forState:UIControlStateNormal];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [self.view addSubview:backButton];
        self.backButton = backButton;
        
        self.cell = [[MCSwipeTableViewCell alloc] init];
        self.cell.frame = CGRectMake(0, CGRectGetMaxY(self.toolbarEditView.frame), 320, self.view.bounds.size.height-CGRectGetMaxY(self.toolbarEditView.frame));
        self.cell.shouldRegret = YES;
        self.cell.delegate = self;
        self.cell.bounceAmplitude = 0;
        self.cell.mode = MCSwipeTableViewCellModeExit;
        UIView *contentView = [[UIView alloc] initWithFrame:self.cell.bounds];
        contentView.backgroundColor = tbackground(BackgroundColor);
        contentView.tag = CONTENT_VIEW_TAG;
        
        //contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        
/*        self.topToolbar = [[KPToolbar alloc] init];
        self.topToolbar.frame = CGRectMake(0, 20, contentView.frame.size.width, TOOLBAR_HEIGHT);
        self.topToolbar.delegate = self;
        self.topToolbar.items = @[@"backarrow_icon_white",@"",@"schedule",@"today",@"done"];
        self.topToolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin);
        [contentView addSubview:self.topToolbar];
  */
        
        self.titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CONTAINER_INIT_HEIGHT)];
        self.titleContainerView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
        
        CGFloat buttonWidth = BUTTON_HEIGHT;
        
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(CELL_LABEL_X,  TITLE_TOP_MARGIN, TITLE_WIDTH-buttonWidth-CELL_LABEL_X, TITLE_HEIGHT)];
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
        
        
        
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleContainerView.frame), 320, contentView.frame.size.height - CGRectGetMaxY(self.titleContainerView.frame)-TOOLBAR_HEIGHT)];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
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
         Evernote Container with button!
         self.evernoteContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEFAULT_ROW_HEIGHT)];
         [self addAndGetImage:@"edit_notes_icon" inView:self.evernoteContainer];
         
         self.evernoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X, self.evernoteContainer.frame.size.height)];
         self.evernoteLabel.font = EDIT_TASK_TEXT_FONT;
         self.evernoteLabel.backgroundColor = CLEAR;
         [self setColorsFor:self.evernoteLabel];
         [self.evernoteContainer addSubview:self.evernoteLabel];
         
         [self addClickButtonToView:self.evernoteContainer action:@selector(pressedEvernote:)];
         
         [self.scrollView addSubview:self.evernoteContainer];
        */
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
        
        
        [self.cell.contentView addSubview:contentView];
        [self.view addSubview:self.cell];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
        
        self.sectionHeader = [[SectionHeaderView alloc] initWithColor:[UIColor greenColor] font:SECTION_HEADER_FONT title:@"Test"];
        CGRectSetY(self.sectionHeader, CGRectGetMaxY(self.toolbarEditView.frame));
        [self.view addSubview:self.sectionHeader];
        notify(@"updated sync",updateFromSync:);
    }
    return self;
}
- (void)updateFromSync:(NSNotification *)notification
{
    
    NSDictionary *changeEvent = [notification userInfo];
    NSLog(@"changeEvent:%@",changeEvent);
    NSSet *updatedObjects = [changeEvent objectForKey:@"updated"];
    NSSet *deletedObjects = [changeEvent objectForKey:@"deleted"];
    if([deletedObjects containsObject:self.objectId]){
        [self pressedBack:nil];
    }else if([updatedObjects containsObject:self.model.objectId]) [self update];
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
    ROOT_CONTROLLER.lockSettings = YES;
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
        ROOT_CONTROLLER.lockSettings = NO;
        if(finished){
            [timePicker removeFromSuperview];
            self.timePicker = nil;
            if(date) [KPToDo scheduleToDos:@[self.model] forDate:date save:YES];
        }
    }];
    
}
-(void)pressedBack:(UIButton*)sender{
    if(self.activeEditMode == KPEditModeTitle){
        [self.textView resignFirstResponder];
    }
    [BLURRY dismissAnimated:YES];
    self.activeEditMode = KPEditModeNone;
    if([self.delegate respondsToSelector:@selector(didPressCloseToDoViewController:)]){
        [self.delegate didPressCloseToDoViewController:self];
    }
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 1){
        [self.segmentedViewController deleteNumberOfItems:1 inView:self completion:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [KPToDo deleteToDos:@[self.model] save:YES];
                [self pressedBack:nil];
            }
        }];
    }
    else if(item == 0){
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
        case KPEditModeEvernote:
        case KPEditModeNone:
            break;
    }
}
#pragma mark MCSwipeTableViewCellDelegate
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    NSLog(@"triggered:%i",mode);
    __block CellType targetCellType = [StyleHandler cellTypeForCell:self.cellType state:state];
    NSLog(@"target:%i",targetCellType);
    switch (targetCellType) {
        case CellTypeSchedule:{
            //SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
            SchedulePopup *popup = [SchedulePopup popupWithFrame:self.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate) {
                [BLURRY dismissAnimated:YES];
                if(button == KPScheduleButtonCancel){
                }
                else{
                    [KPToDo scheduleToDos:@[self.model] forDate:chosenDate save:YES];
                    [self update];
                }
            }];
            popup.numberOfItems = 1;
            BLURRY.blurryTopColor = alpha(tcolor(TextColor),0.4);
            BLURRY.dismissAction = ^{
                [cell bounceToOrigin];
            };
            [BLURRY showView:popup inViewController:self];
            return;
        }
        case CellTypeToday:
            [KPToDo scheduleToDos:@[self.model] forDate:[NSDate date] save:YES];
            break;
        case CellTypeDone:
            [KPToDo completeToDos:@[self.model] save:YES];
            break;
        case CellTypeNone:
            break;
    }
    [self update];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:cell selector:@selector(bounceToOrigin) userInfo:nil repeats:NO];
    
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
        [KPToDo save];
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
    CGRectSetY(self.scrollView, CGRectGetMaxY(self.titleContainerView.frame));
    CGRectSetHeight(self.scrollView, self.contentView.frame.size.height-CGRectGetMaxY(self.titleContainerView.frame)-TOOLBAR_HEIGHT);
}

#pragma mark - NotesViewDelegate

-(void)pressedPriority{
    self.model.priorityValue = (self.model.priorityValue == 0) ? 1 : 0;
    [KPToDo save];
    [self updateDot];
}
-(void)savedNotesView:(NotesView *)notesView text:(NSString *)text{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
    self.model.notes = text;
    [KPToDo save];
    [self updateNotes];
    [self layout];
}
-(void)pressedCancelNotesView:(NotesView *)notesView{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
}

#pragma mark - EvernoteViewDelegate

- (void)selectedEvernoteInView:(EvernoteView *)EvernoteView guid:(NSString *)guid title:(NSString *)title
{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
//    self.model.notes = text;
//    [KPToDo save];
    [self updateNotes];
    [self layout];
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
    self.notesView.frame = CGRectSetSize(self.notesView, self.view.frame.size.width-LABEL_X-10, 1500);
    //CGSize contentSize = [self.notesView sizeThatFits:CGSizeMake(self.notesView.frame.size.width, 500)];
    [self.notesView sizeToFit];
    CGRectSetHeight(self.notesView,self.notesView.frame.size.height+20);
    CGRectSetHeight(self.notesContainer, self.notesView.frame.size.height+2*NOTES_PADDING);
}

-(void)updateRepeated{
    NSDate *repeatDate = self.model.repeatedDate;
    if (!repeatDate)
        repeatDate = self.model.schedule;

    if (repeatDate){
        if(![self.repeatPicker.selectedDate isEqualToDate:repeatDate] || self.repeatPicker.currentOption != self.model.repeatOptionValue)  [self.repeatPicker setSelectedDate:repeatDate option:self.model.repeatOptionValue];
    }
    else
        return;
    
    NSString* labelText;
    NSString *timeInString = [UtilityClass timeStringForDate:self.model.repeatedDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    BOOL addTime = YES;
    if (self.activeEditMode == KPEditModeRepeat) {
        labelText = @"Repeat every...";
    }
    else {
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
    NSLog(@"%f",CGRectGetMaxY(self.titleContainerView.frame));
    CGRectSetY(self.scrollView, CGRectGetMaxY(self.titleContainerView.frame));
    CGRectSetHeight(self.scrollView, self.contentView.frame.size.height - CGRectGetMaxY(self.titleContainerView.frame)-TOOLBAR_HEIGHT);
    CGRectSetY(self.toolbarEditView, self.contentView.frame.size.height - TOOLBAR_HEIGHT);
    self.toolbarEditView.autoresizingMask = UIViewAutoresizingNone;
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
            self.alarmLabel.text = [NSString stringWithFormat:@"Completed: %@",[UtilityClass readableTime:self.model.completionDate showTime:YES]];
        }
    }
    else{
        self.alarmLabel.text = [NSString stringWithFormat:@"%@",[UtilityClass readableTime:self.model.schedule showTime:YES]];
    }
}

- (void)updateEvernote
{
    self.evernoteLabel.text = @"Attach Evernote note";
}
-(void)updateSectionHeader{
    [self.sectionHeader setTitle:[[self.model readableTitleForStatus] uppercaseString]];
    [self.sectionHeader setColor:[StyleHandler colorForCellType:self.cellType]];
}
-(void)update
{
    if(self.model.objectId) self.objectId = self.model.objectId;
    self.textView.text = self.model.title;
    self.cellType = [self.model cellTypeForTodo];
    [self updateTags];
    [self updateSchedule];
    [self updateNotes];
    [self updateDot];
    [self updateRepeated];
    [self updateEvernote];
    [self updateSectionHeader];
    [self layout];
    
}

-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
        NSString *backLabel;
        switch ([model cellTypeForTodo]) {
            case CellTypeSchedule:
                backLabel = @"Schedule";
                break;
            case CellTypeToday:
                backLabel = @"Tasks";
                break;
            case CellTypeDone:
                backLabel = @"Done";
                break;
            default:
                backLabel = @"Back";
                break;
        }
        [self.backButton setTitle:backLabel forState:UIControlStateNormal];
    }
    [self update];
}

-(void)layout{
    CGFloat tempHeight = 0;
    CGRectSetY(self.alarmContainer, tempHeight);
    tempHeight += self.alarmContainer.frame.size.height;
    
    self.repeatedContainer.hidden = !self.model.schedule;
    if(self.model.completionDate) self.repeatedContainer.hidden = YES;
    if(!self.repeatedContainer.hidden){
        CGFloat repeatHeight = (self.activeEditMode == KPEditModeRepeat) ? SCHEDULE_ROW_HEIGHTS+kRepeatPickerHeight : SCHEDULE_ROW_HEIGHTS;
        CGRectSetHeight(self.repeatedContainer, repeatHeight);
        CGRectSetY(self.repeatedContainer, tempHeight);
        tempHeight += self.repeatedContainer.frame.size.height;
    }
    CGRectSetY(self.tagsContainerView, tempHeight);
    tempHeight += self.tagsContainerView.frame.size.height;
    
    /*CGRectSetY(self.evernoteContainer, tempHeight);
    tempHeight += self.evernoteContainer.frame.size.height;
    */
    CGRectSetY(self.notesContainer, tempHeight);
    tempHeight += self.notesContainer.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,tempHeight);
}

-(void)pressedRepeat:(id)sender
{
    if(self.activeEditMode == KPEditModeRepeat){
        self.activeEditMode = KPEditModeNone;
    }
    else{
        self.activeEditMode = KPEditModeRepeat;
    }
    [self updateRepeated];
    [self layout];
}

-(void)pressedDone:(id)sender
{
    [self.delegate didPressCloseToDoViewController:self];
}

-(void)pressedAlarm:(id)sender
{
    self.activeEditMode = KPEditModeAlarm;
    SchedulePopup *popup = [SchedulePopup popupWithFrame:self.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate) {
        [BLURRY dismissAnimated:YES];
        if(button != KPScheduleButtonCancel){
            // TODO: Fix the edit mode
            [KPToDo scheduleToDos:@[self.model] forDate:chosenDate save:YES];
            //[KPToDo scheduleToDos:@[self.parent.showingModel] forDate:chosenDate save:YES];
            [self.model setRepeatOption:self.model.repeatOptionValue save:YES];
            [self update];
        }
    }];
    popup.numberOfItems = 1;
    BLURRY.blurryTopColor = alpha(tcolor(TextColor),0.2);
    [BLURRY showView:popup inViewController:self];
    /*if([self.delegate respondsToSelector:@selector(scheduleToDoViewController:)]) [self.delegate scheduleToDoViewController:self];*/
}

-(void)pressedNotes:(id)sender
{
    self.activeEditMode = KPEditModeNotes;
    CGFloat extra = (OSVER >= 7) ? 20 : 0;
    NotesView *notesView = [[NotesView alloc] initWithFrame:CGRectMake(0, 0+extra, 320, self.view.frame.size.height-extra)];
    [notesView setNotesText:self.model.notes title:self.model.title];
    notesView.delegate = self;
    BLURRY.showPosition = PositionBottom;
    [BLURRY showView:notesView inViewController:self];
    
}

-(void)pressedTags:(id)sender
{
    self.activeEditMode = KPEditModeTags;
    [self.segmentedViewController tagItems:@[self.model] inViewController:self withDismissAction:^{
        self.activeEditMode = KPEditModeNone;
        [self updateTags];
        [self layout];
    }];
}

-(void)pressedEvernote:(id)sender
{
    self.activeEditMode = KPEditModeEvernote;
    EvernoteView *evernoteView = [[EvernoteView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    evernoteView.delegate = self;
    evernoteView.caller = self.segmentedViewController;
    BLURRY.showPosition = PositionBottom;
    [BLURRY showView:evernoteView inViewController:self];
}

-(void)dealloc
{
    self.cell = nil;
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
    self.evernoteLabel = nil;
    self.evernoteContainer = nil;
    
    self.repeatedContainer = nil;
    self.repeatedLabel = nil;
    clearNotify();
}

-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
        NSLog(@"setting cell");
        _cellType = cellType;
        CellType firstCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState1];
        self.cell.modeForState1 = (firstCell == CellTypeSchedule) ? MCSwipeTableViewCellModeExit : MCSwipeTableViewCellModeNone;
        CellType secondCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState2];
        self.cell.modeForState2 = (secondCell == CellTypeSchedule) ? MCSwipeTableViewCellModeExit : MCSwipeTableViewCellModeNone;
        CellType thirdCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState3];
        self.cell.modeForState3 = (thirdCell == CellTypeSchedule) ? MCSwipeTableViewCellModeExit : MCSwipeTableViewCellModeNone;
        CellType fourthCell = [StyleHandler cellTypeForCell:cellType state:MCSwipeTableViewCellState4];
        self.cell.modeForState4 = (fourthCell == CellTypeSchedule) ? MCSwipeTableViewCellModeExit : MCSwipeTableViewCellModeNone;
        [self.cell setFirstColor:[StyleHandler colorForCellType:firstCell]];
        [self.cell setSecondColor:[StyleHandler colorForCellType:secondCell]];
        [self.cell setThirdColor:[StyleHandler colorForCellType:thirdCell]];
        [self.cell setFourthColor:[StyleHandler colorForCellType:fourthCell]];
        [self.cell setFirstIconName:[StyleHandler iconNameForCellType:firstCell]];
        [self.cell setSecondIconName:[StyleHandler iconNameForCellType:secondCell]];
        [self.cell setThirdIconName:[StyleHandler iconNameForCellType:thirdCell]];
        [self.cell setFourthIconName:[StyleHandler iconNameForCellType:fourthCell]];
        self.cell.activatedDirection = [StyleHandler directionForCellType:cellType];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
