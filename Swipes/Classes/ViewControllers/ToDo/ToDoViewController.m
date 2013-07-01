//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TITLE_TEXT_VIEW_TAG 1
#define NOTES_TEXT_VIEW_TAG 2
#define EDIT_BUTTON_TAG 3
#define DONE_BUTTON_TAG 4
#define TITLE_CONTAINER_VIEW_TAG 5
#define TAGS_LABEL_TAG 7
#define TAGS_CONTAINER_TAG 8
#define CONTENT_VIEW_TAG 9
#define SCROLL_VIEW_TAG 13
#define ALARM_CONTAINER_TAG 14
#define ALARM_LABEL_TAG 15
#define ALARM_IMAGE_TAG 16
#define NOTES_CONTAINER_VIEW_TAG 17
#define TAGS_IMAGE_VIEW_TAG 18
#define NOTES_IMAGE_VIEW_TAG 19
#define DOT_VIEW_TAG 20

#define TOP_VIEW_MARGIN 60
#define SHOW_ITEM_TAG 5432


#define DEFAULT_ROW_HEIGHT 60

#define LABEL_X 50

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 19
#define TITLE_WIDTH (320)
#define TITLE_BOTTOM_MARGIN (TITLE_TOP_MARGIN)
#define CONTAINER_INIT_HEIGHT (TITLE_HEIGHT + TITLE_TOP_MARGIN + TITLE_BOTTOM_MARGIN)

#define CLOSE_BUTTON_TOP_INSET -25
#define CLOSE_BUTTON_RIGHT_INSET -10

#define TAGS_LABEL_RECT CGRectMake(LABEL_X,TAGS_LABEL_PADDING,320-LABEL_X-10,500)

#define TAGS_LABEL_PADDING 18.5
#define NOTES_PADDING 10.5


#import "UIViewController+KNSemiModal.h"
#import "KPAddTagPanel.h"
#import "KPSegmentedViewController.h"
#import "TagHandler.h"
#import "ToDoViewController.h"
#import "HPGrowingTextView.h"
#import "ToDoHandler.h"
#import "ToDoCell.h"
#import "SchedulePopup.h"
#import "AlarmPopup.h"
#import "NSDate-Utilities.h"
#import "NotesView.h"
#import "AlarmView.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
typedef NS_ENUM(NSUInteger, KPEditMode){
    KPEditModeNone = 0,
    KPEditModeTitle,
    KPEditModeTags,
    KPEditModeAlarm,
    KPEditModeNotes
};

@interface ToDoViewController () <HPGrowingTextViewDelegate,KPAddTagDelegate,KPTagDelegate,NotesViewDelegate>
@property (nonatomic) KPEditMode activeEditMode;


@property (nonatomic,weak) IBOutlet UIView *titleContainerView;
@property (nonatomic,weak) IBOutlet HPGrowingTextView *editTitleTextView;
@property (nonatomic,weak) IBOutlet UIView *dotView;

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIView *tagsContainerView;
@property (nonatomic,weak) IBOutlet UIView *alarmContainer;
@property (nonatomic,weak) IBOutlet UIView *notesContainer;

@property (nonatomic,weak) IBOutlet UILabel *alarmLabel;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet UITextView *notesView;

@property (nonatomic,weak) IBOutlet UIImageView *alarmImage;
@property (nonatomic,weak) IBOutlet UIImageView *tagsImage;
@property (nonatomic,weak) IBOutlet UIImageView *notesImage;
@end

@implementation ToDoViewController
-(id)init{
    self = [super init];
    if(self){
        self.view.tag = SHOW_ITEM_TAG;
        self.view.backgroundColor = EDIT_TASK_BACKGROUND;
        UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        contentView.tag = CONTENT_VIEW_TAG;
        contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        
        UIView *titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CONTAINER_INIT_HEIGHT)];
        titleContainerView.tag = TITLE_CONTAINER_VIEW_TAG;
        titleContainerView.backgroundColor = EDIT_TASK_TITLE_BACKGROUND;
        
        CGFloat buttonWidth = BUTTON_HEIGHT;
        
        HPGrowingTextView *textView;
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, TITLE_TOP_MARGIN, TITLE_WIDTH-buttonWidth, TITLE_HEIGHT)];
        textView.contentInset = UIEdgeInsetsMake(0, LABEL_X-8, 0, -8);
        textView.tag = TITLE_TEXT_VIEW_TAG;
        textView.minNumberOfLines = 1;
        textView.backgroundColor = CLEAR;
        textView.maxNumberOfLines = 6;
        textView.returnKeyType = UIReturnKeyDone; //just as an example
        textView.font = EDIT_TASK_TITLE_FONT;
        textView.delegate = self;
        textView.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.textColor = EDIT_TASK_TITLE_COLOR;
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DOT_SIZE,DOT_SIZE)];
        dotView.tag = DOT_VIEW_TAG;
        dotView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        centerItemForSize(dotView, LABEL_X, textView.frame.size.height);
        dotView.layer.cornerRadius = DOT_SIZE/2;
        dotView.tag = DOT_VIEW_TAG;
        [textView addSubview:dotView];
        self.dotView = [textView viewWithTag:DOT_VIEW_TAG];
    
        [titleContainerView addSubview:textView];
        self.editTitleTextView = (HPGrowingTextView*)[titleContainerView viewWithTag:TITLE_TEXT_VIEW_TAG];
        
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(titleContainerView.frame.size.width-buttonWidth,0,buttonWidth,CONTAINER_INIT_HEIGHT-COLOR_SEPERATOR_HEIGHT);
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        doneButton.imageEdgeInsets = UIEdgeInsetsMake(CLOSE_BUTTON_TOP_INSET, 0, 0, CLOSE_BUTTON_RIGHT_INSET);
        [doneButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
        [titleContainerView addSubview:doneButton];
        
        [contentView addSubview:titleContainerView];
        self.titleContainerView = [contentView viewWithTag:TITLE_CONTAINER_VIEW_TAG];
        
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleContainerView.frame.size.height, 320, contentView.frame.size.height - titleContainerView.frame.size.height)];
        scrollView.tag = SCROLL_VIEW_TAG;
        scrollView.scrollEnabled = YES;
        scrollView.alwaysBounceVertical = YES;
        
        
        /*
            Alarm container and button!
        */
        UIView *alarmContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEFAULT_ROW_HEIGHT)];
        alarmContainer.tag = ALARM_CONTAINER_TAG;
        [self addSeperatorToView:alarmContainer];

        self.alarmImage = [self addAndGetImage:@"edit_alarm_icon" inView:alarmContainer tag:ALARM_IMAGE_TAG];
        
        UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X, alarmContainer.frame.size.height)];
        alarmLabel.backgroundColor = CLEAR;
        [self setColorsFor:alarmLabel];
        alarmLabel.font = EDIT_TASK_TEXT_FONT;
        alarmLabel.tag = ALARM_LABEL_TAG;
        
        [alarmContainer addSubview:alarmLabel];
        self.alarmLabel = (UILabel*)[alarmContainer viewWithTag:ALARM_LABEL_TAG];
        
        [self addClickButtonToView:alarmContainer action:@selector(pressedAlarm:)];
        
        [scrollView addSubview:alarmContainer];
        self.alarmContainer = [scrollView viewWithTag:ALARM_CONTAINER_TAG];

        /*
            Tags Container with button!
        */
        UIView *tagsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEFAULT_ROW_HEIGHT)];
        tagsContainer.tag = TAGS_CONTAINER_TAG;
        [self addSeperatorToView:tagsContainer];
        
        self.tagsImage = [self addAndGetImage:@"edit_tags_icon" inView:tagsContainer tag:TAGS_IMAGE_VIEW_TAG];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:TAGS_LABEL_RECT];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 0;
        tagsLabel.font = EDIT_TASK_TEXT_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        [self setColorsFor:tagsLabel];
        [tagsContainer addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[tagsContainer viewWithTag:TAGS_LABEL_TAG];
        
        [self addClickButtonToView:tagsContainer action:@selector(pressedTags:)];
        
        [scrollView addSubview:tagsContainer];
        self.tagsContainerView = [scrollView viewWithTag:TAGS_CONTAINER_TAG];
        
        /*
         Notes view
        */
        UIView *notesContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, DEFAULT_ROW_HEIGHT)];
        notesContainer.tag = NOTES_CONTAINER_VIEW_TAG;
        //[self addSeperatorToView:notesContainer];
        self.notesImage = [self addAndGetImage:@"edit_notes_icon" inView:notesContainer tag:NOTES_IMAGE_VIEW_TAG];
        //self.notesImage.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        UITextView *notesView = [[UITextView alloc] initWithFrame:CGRectMake(LABEL_X, NOTES_PADDING, 320-LABEL_X-10, 500)];
        notesView.tag = NOTES_TEXT_VIEW_TAG;
        notesView.font = EDIT_TASK_TEXT_FONT;
        notesView.contentInset = UIEdgeInsetsMake(0,-8,0,0);
        notesView.editable = NO;
        notesView.backgroundColor = CLEAR;
        [notesContainer addSubview:notesView];
        self.notesView = (UITextView*)[notesContainer viewWithTag:NOTES_TEXT_VIEW_TAG];
        
        [self addClickButtonToView:notesContainer action:@selector(pressedNotes:)];
        
        
        [scrollView addSubview:notesContainer];
        self.notesContainer = [scrollView viewWithTag:NOTES_CONTAINER_VIEW_TAG];
        
        
        /* Adding scroll and content view */
        [contentView addSubview:scrollView];
        self.scrollView = (UIScrollView*)[contentView viewWithTag:SCROLL_VIEW_TAG];
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
    }
    return self;
}
-(void)setColorsFor:(id)object{
    if([object respondsToSelector:@selector(setTextColor:)]) [object setTextColor:EDIT_TASK_TEXT_COLOR];
    if([object respondsToSelector:@selector(setHighlightedTextColor:)]) [object setHighlightedTextColor:EDIT_TASK_GRAYED_OUT_TEXT];
}
-(UIImageView *)addAndGetImage:(NSString*)imageName inView:(UIView*)view tag:(NSInteger)tag{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.image = [UtilityClass imageNamed:imageName withColor:EDIT_TASK_GRAYED_OUT_TEXT];
    imageView.tag = tag;
    imageView.frame = CGRectSetPos(imageView.frame,(LABEL_X-imageView.frame.size.width)/2, (view.frame.size.height-imageView.frame.size.height)/2);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    [view addSubview:imageView];
    return (UIImageView*)[view viewWithTag:tag];
}
-(void)addClickButtonToView:(UIView*)view action:(SEL)action{
    UIButton *clickedButton = [[UIButton alloc] initWithFrame:view.bounds];
    clickedButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [clickedButton setBackgroundImage:[UtilityClass imageWithColor:color(55,55,55,0.5)] forState:UIControlStateHighlighted];
    //clickedButton.contentEdgeInsets = UIEdgeInsetsMake(0, LABEL_X, 0, LABEL_X/3);
    [clickedButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:clickedButton];
}
-(void)addSeperatorToView:(UIView*)view{
    CGFloat seperatorHeight = 1;
    CGFloat rightMargin = LABEL_X/3;
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(LABEL_X, view.frame.size.height-seperatorHeight, view.frame.size.width-LABEL_X-rightMargin, seperatorHeight)];
    seperatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    seperatorView.backgroundColor = EDIT_TASK_SEPERATOR_COLOR;
    [view addSubview:seperatorView];
}
-(void)setActiveEditMode:(KPEditMode)activeEditMode{
    if(activeEditMode != _activeEditMode){
        if(activeEditMode != KPEditModeNone) [self clearActiveEditMode];
        _activeEditMode = activeEditMode;
    }
}
-(void)clearActiveEditMode{
    switch (self.activeEditMode) {
        case KPEditModeTitle:{
            [self.editTitleTextView resignFirstResponder];
        }
        case KPEditModeTags:
        case KPEditModeAlarm:
        case KPEditModeNotes:
        case KPEditModeNone:
            break;
    }
}
#pragma mark - KPAddTagDelegate
-(void)closeTagPanel:(KPAddTagPanel *)tagPanel{
    [self.segmentedViewController dismissSemiModalView];
    self.activeEditMode = KPEditModeNone;
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel createdTag:(NSString *)tag{
    [TAGHANDLER addTag:tag];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel changedSize:(CGSize)size{
    [self.segmentedViewController resizeSemiView:size animated:NO];
}

#pragma mark - KPTagDelegate
-(NSArray *)selectedTagsForTagList:(KPTagList *)tagList{
    NSArray *selectedTags = [TAGHANDLER selectedTagsForToDos:@[self.model]];
    return selectedTags;
}
-(NSArray *)tagsForTagList:(KPTagList *)tagList{
    NSArray *allTags = [TAGHANDLER allTags];
    return allTags;
}
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    [TAGHANDLER updateTags:@[tag] remove:NO toDos:@[self.model]];
    [self updateTags];
    [self layout];
    [self.segmentedViewController updateBackground];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [TAGHANDLER updateTags:@[tag] remove:YES toDos:@[self.model]];
    [self updateTags];
    [self layout];
    [self.segmentedViewController updateBackground];
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
        [TODOHANDLER changeToDos:@[self.model] title:growingTextView.text save:YES];
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
    CGRectSetHeight(self.scrollView, self.contentView.frame.size.height-titleHeight);
}
#pragma mark NotesViewDelegate
-(void)pressedCancelNotesView:(NotesView *)notesView{
    [self.segmentedViewController dismissSemiModalView];
}
-(void)savedNotesView:(NotesView *)notesView text:(NSString *)text{
    [self.model updateNotes:text save:YES];
    [self.segmentedViewController dismissSemiModalViewWithCompletion:^{
        [self updateNotes];
        [self layout];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)updateNotes{
    if(!self.model.notes || self.model.notes.length == 0){
        self.notesView.text = @"Add notes";
        self.notesImage.highlighted = YES;
        self.notesView.textColor = EDIT_TASK_GRAYED_OUT_TEXT;
    }
    else{
        self.notesImage.highlighted = NO;
        self.notesView.textColor = EDIT_TASK_TEXT_COLOR;
        self.notesView.text = self.model.notes;
    }
    CGRectSetHeight(self.notesView, self.notesView.contentSize.height);
    
    CGRectSetHeight(self.notesContainer, self.notesView.frame.size.height+2*NOTES_PADDING);
}
-(void)updateTags{
    self.tagsLabel.frame = TAGS_LABEL_RECT;
    NSString *tagsString = [self.model stringifyTags];
    self.tagsImage.highlighted = NO;
    self.tagsLabel.highlighted = NO;
    if(!tagsString || tagsString.length == 0){
        tagsString = @"Set tags";
        self.tagsLabel.highlighted = YES;
        self.tagsImage.highlighted = YES;
    }
    self.tagsLabel.text = tagsString;
    [self.tagsLabel sizeToFit];

    CGFloat containerHeight = self.tagsLabel.frame.size.height + 2*TAGS_LABEL_PADDING;
    CGRectSetHeight(self.tagsContainerView, containerHeight);
}
-(void)updateDot{
    
    self.dotView.backgroundColor = [TODOHANDLER colorForCellType:[self.model cellTypeForTodo]];
}
-(void)updateAlarm{
    if(!self.model.schedule || [self.model.schedule isInPast]){
        self.alarmImage.highlighted = YES;
        self.alarmLabel.highlighted = YES;
        self.alarmLabel.text = @"Remind me";
    }
    else{
        self.alarmLabel.highlighted = NO;
        self.alarmImage.highlighted = NO;
        self.alarmLabel.text = [self.model readableTime:self.model.schedule showTime:YES];
    }
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
        self.editTitleTextView.text = model.title;
        [self updateTags];
        [self updateAlarm];
        [self updateNotes];
        [self updateDot];
        [self layout];
    }
}
-(void)layout{
    CGFloat tempHeight = 0;
    CGRectSetY(self.alarmContainer, tempHeight);
    tempHeight += self.alarmContainer.frame.size.height;
    
    CGRectSetY(self.tagsContainerView, tempHeight);
    tempHeight += self.tagsContainerView.frame.size.height;
    
    CGRectSetY(self.notesContainer, tempHeight);
    tempHeight += self.notesContainer.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,tempHeight);
}
-(void)setInjectedCell:(ToDoCell *)injectedCell{
    if(_injectedCell != injectedCell){
        if(injectedCell) [injectedCell.contentView addSubview:self.view];
        else [self cleanInjectedCell];
        _injectedCell = injectedCell;
    }
}
-(void)cleanInjectedCell{
    [[self.injectedCell viewWithTag:SHOW_ITEM_TAG] removeFromSuperview];
}
-(void)pressedDone:(id)sender{
    [self.delegate didPressCloseToDoViewController:self];
}
-(void)pressedAlarm:(id)sender{
    self.activeEditMode = KPEditModeAlarm;
    /*AlarmView *alarmView = [[AlarmView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    [self.segmentedViewController presentSemiView:alarmView withOptions:@{KNSemiModalOptionKeys.animationDuration:@0.25f,KNSemiModalOptionKeys.shadowOpacity:@0.5f} completion:^{
    }];*/
    [AlarmPopup showInView:[self segmentedViewController].view withBlock:^(NSDate *chosenDate) {
        [self.model updateAlarm:chosenDate force:NO save:YES];
        [self updateAlarm];
    } andDate:self.model.alarm];
}
-(void)pressedNotes:(id)sender{
    NotesView *notesView = [[NotesView alloc] initWithFrame:CGRectMake(0, 0, 320, self.segmentedViewController.view.frame.size.height - DEFAULT_SPACE_FROM_SLIDE_UP_VIEW)];
    [notesView setNotesText:self.model.notes];
    notesView.delegate = self;
    [self.segmentedViewController presentSemiView:notesView withOptions:@{KNSemiModalOptionKeys.animationDuration:@0.25f,KNSemiModalOptionKeys.shadowOpacity:@0.5f} completion:^{
    }];
}
-(void)pressedTags:(id)sender{
    self.activeEditMode = KPEditModeTags;
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, 450) andTags:[TAGHANDLER allTags] andMaxHeight:320];
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    
    [self.segmentedViewController presentSemiView:tagView withOptions:@{KNSemiModalOptionKeys.animationDuration:@0.25f,KNSemiModalOptionKeys.shadowOpacity:@0.5f} completion:^{
        [tagView scrollIfNessecary];
    }];
}
-(void)dealloc{
    self.injectedCell = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
