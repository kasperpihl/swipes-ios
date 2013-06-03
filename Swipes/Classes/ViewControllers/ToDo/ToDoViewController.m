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
#define STATUS_CELL_TAG 6
#define TAGS_LABEL_TAG 7
#define TAGS_CONTAINER_TAG 8
#define CONTENT_VIEW_TAG 9
#define STATUS_IMAGE_TAG 10
#define STATUS_LABEL_TAG 11
#define STATUS_CONTAINER_TAG 12
#define SCROLL_VIEW_TAG 13
#define ALARM_CONTAINER_TAG 14
#define ALARM_LABEL_TAG 15
#define ALARM_IMAGE_TAG 16

#define TOP_VIEW_MARGIN 60
#define SHOW_ITEM_TAG 5432




#define LABEL_X 50

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 7
#define TITLE_X 6
#define TITLE_WIDTH (320-2*TITLE_X)
#define TITLE_BOTTOM_MARGIN (TITLE_TOP_MARGIN+COLOR_SEPERATOR_HEIGHT)
#define CONTAINER_INIT_HEIGHT (TITLE_HEIGHT + TITLE_TOP_MARGIN + TITLE_BOTTOM_MARGIN)
#define TAGS_LABEL_PADDING 20
#define TAGS_LABEL_RECT CGRectMake(LABEL_X,TAGS_LABEL_PADDING,320-LABEL_X-10,500)


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
typedef NS_ENUM(NSUInteger, KPEditMode){
    KPEditModeNone = 0,
    KPEditModeTitle,
    KPEditModeTags,
    KPEditModeAlarm,
    KPEditModeNotes
};

@interface ToDoViewController () <HPGrowingTextViewDelegate,KPAddTagDelegate,KPTagDelegate,NotesViewDelegate>
@property (nonatomic) KPEditMode activeEditMode;
@property (nonatomic,weak) IBOutlet HPGrowingTextView *editTitleTextView;

@property (nonatomic,weak) IBOutlet UIView *titleContainerView;

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIView *statusContainer;
@property (nonatomic,weak) IBOutlet UIView *tagsContainerView;
@property (nonatomic,weak) IBOutlet UIView *alarmContainer;

@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet UITextView *notesView;
@property (nonatomic,weak) IBOutlet UIImageView *statusImage;
@property (nonatomic,weak) IBOutlet UILabel *statusLabel;
@property (nonatomic,weak) IBOutlet UILabel *alarmLabel;
@property (nonatomic,weak) IBOutlet UIImageView *alarmImage;
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
        //titleContainerView.backgroundColor = TEXTFIELD_BACKGROUND;
        

        
        
        CGFloat buttonWidth = BUTTON_HEIGHT;
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(titleContainerView.frame.size.width-buttonWidth,0,buttonWidth,CONTAINER_INIT_HEIGHT-COLOR_SEPERATOR_HEIGHT);
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [doneButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
        [titleContainerView addSubview:doneButton];
        
        
        HPGrowingTextView *textView;
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(TITLE_X, TITLE_TOP_MARGIN, TITLE_WIDTH-buttonWidth, TITLE_HEIGHT)];
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        textView.tag = TITLE_TEXT_VIEW_TAG;
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 6;
        textView.returnKeyType = UIReturnKeyDone; //just as an example
        textView.font = TEXT_FIELD_FONT;
        textView.delegate = self;
        textView.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = TEXT_FIELD_COLOR;
        [titleContainerView addSubview:textView];
        self.editTitleTextView = (HPGrowingTextView*)[titleContainerView viewWithTag:TITLE_TEXT_VIEW_TAG];
        
        UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, CONTAINER_INIT_HEIGHT-COLOR_SEPERATOR_HEIGHT, contentView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        colorBottomSeperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        colorBottomSeperator.backgroundColor = SWIPES_COLOR;
        [titleContainerView addSubview:colorBottomSeperator];
        
        
        [contentView addSubview:titleContainerView];
        self.titleContainerView = [contentView viewWithTag:TITLE_CONTAINER_VIEW_TAG];
        
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleContainerView.frame.size.height, 320, contentView.frame.size.height - titleContainerView.frame.size.height)];
        scrollView.tag = SCROLL_VIEW_TAG;
        scrollView.scrollEnabled = YES;
        scrollView.alwaysBounceVertical = YES;
        
        
        /* 
            Status container with views
         */
        UIView *statusContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        statusContainer.tag = STATUS_CONTAINER_TAG;
        
        UIImageView *statusImage = [[UIImageView alloc] init];
        statusImage.tag = STATUS_IMAGE_TAG;
        [statusContainer addSubview:statusImage];
        self.statusImage = (UIImageView*)[statusContainer viewWithTag:STATUS_IMAGE_TAG];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X, statusContainer.frame.size.height)];
        statusLabel.backgroundColor = CLEAR;
        statusLabel.textColor = TEXT_FIELD_COLOR;
        statusLabel.font = TITLE_LABEL_FONT;
        statusLabel.tag = STATUS_LABEL_TAG;
        
        [statusContainer addSubview:statusLabel];
        self.statusLabel = (UILabel*)[statusContainer viewWithTag:STATUS_LABEL_TAG];
        
        [scrollView addSubview:statusContainer];
        self.statusContainer = [scrollView viewWithTag:STATUS_CONTAINER_TAG];
        
        /*
            Alarm container and button!
        */
        UIView *alarmContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        alarmContainer.tag = ALARM_CONTAINER_TAG;
        
        UIImageView *alarmImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule"]];
        alarmImage.tag = ALARM_IMAGE_TAG;
        alarmImage.highlightedImage = [UIImage imageNamed:@"schedule-highlighted"];
        alarmImage.frame = CGRectSetPos(alarmImage.frame, (LABEL_X-alarmImage.frame.size.width)/2, (alarmContainer.frame.size.height-alarmImage.frame.size.height)/2);
        [alarmContainer addSubview:alarmImage];
        self.alarmImage = (UIImageView*)[alarmContainer viewWithTag:ALARM_IMAGE_TAG];
        
        UIButton *alarmButton = [[UIButton alloc] initWithFrame:alarmContainer.bounds];
        alarmButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [alarmButton addTarget:self action:@selector(pressedAlarm:) forControlEvents:UIControlEventTouchUpInside];
        [alarmContainer addSubview:alarmButton];
        
        UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X, alarmContainer.frame.size.height)];
        alarmLabel.backgroundColor = CLEAR;
        alarmLabel.textColor = TEXT_FIELD_COLOR;
        alarmLabel.font = TITLE_LABEL_FONT;
        alarmLabel.tag = ALARM_LABEL_TAG;
        
        [alarmContainer addSubview:alarmLabel];
        self.alarmLabel = (UILabel*)[alarmContainer viewWithTag:ALARM_LABEL_TAG];
        
        [scrollView addSubview:alarmContainer];
        self.alarmContainer = [scrollView viewWithTag:ALARM_CONTAINER_TAG];

        /*
            Tags Container with button!
        */
        UIView *tagsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 250, 320, 40)];
        tagsContainer.tag = TAGS_CONTAINER_TAG;
        UIImageView *tagsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagbutton"]];
        tagsImage.frame = CGRectSetPos(tagsImage.frame, (LABEL_X-tagsImage.frame.size.width)/2, (tagsContainer.frame.size.height-tagsImage.frame.size.height)/2);
        tagsImage.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        [tagsContainer addSubview:tagsImage];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:TAGS_LABEL_RECT];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 0;
        tagsLabel.font = TEXT_FIELD_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        tagsLabel.textColor = CELL_TAG_COLOR;
        [tagsContainer addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[tagsContainer viewWithTag:TAGS_LABEL_TAG];
        
        UIButton *tagsButton = [[UIButton alloc] initWithFrame:tagsContainer.bounds];
        tagsButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        [tagsButton addTarget:self action:@selector(pressedTags:) forControlEvents:UIControlEventTouchUpInside];
        [tagsContainer addSubview:tagsButton];
        
        [scrollView addSubview:tagsContainer];
        self.tagsContainerView = [scrollView viewWithTag:TAGS_CONTAINER_TAG];
        
        /*
         Notes view
        */
        UITextView *notesView = [[UITextView alloc] initWithFrame:CGRectMake(LABEL_X, 0, 320-LABEL_X-10, 500)];
        notesView.tag = NOTES_TEXT_VIEW_TAG;
        notesView.font = TEXT_FIELD_FONT;
        notesView.textColor = TEXT_FIELD_COLOR;
        notesView.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
        notesView.editable = NO;
        notesView.backgroundColor = CLEAR;
        UIButton *clickedNotesButton = [[UIButton alloc] initWithFrame:notesView.bounds];
        clickedNotesButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [clickedNotesButton addTarget:self action:@selector(pressedNotes:) forControlEvents:UIControlEventTouchUpInside];
        [notesView addSubview:clickedNotesButton];
    
        [notesView setText:@"sajsahjk fhdskjfh kjdshf kjdshf kjhdsfkj hdskhf kjdshf kjdhsfkj hdskfjh \n\ndskjfh dskjhf kjdhsfkjh dskjfh dsk\n\njfh dksjhf kjdshfjk dhsfkj\n\nh dskjfh jkdshfkj dsfkjh dsf"];
        [notesView sizeToFit];
        [scrollView addSubview:notesView];
        self.notesView = (UITextView*)[scrollView viewWithTag:NOTES_TEXT_VIEW_TAG];
        
        
        /* Adding scroll and content view */
        [contentView addSubview:scrollView];
        self.scrollView = (UIScrollView*)[contentView viewWithTag:SCROLL_VIEW_TAG];
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
    }
    return self;
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
    NSLog(@"test");
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
    [self.segmentedViewController updateBackground];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [TAGHANDLER updateTags:@[tag] remove:YES toDos:@[self.model]];
    [self updateTags];
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
    if(!self.model.notes || self.model.notes.length == 0) self.notesView.text = @"Add notes";
    else self.notesView.text = self.model.notes;
    
    CGRectSetHeight(self.notesView, self.notesView.contentSize.height);
}
-(void)updateStatus{
    UIImage *statusImage = [UIImage imageNamed:[TODOHANDLER coloredIconNameForCellType:[self.model cellTypeForTodo]]];
    self.statusLabel.text = [self.model readableTitleForStatus];
    CGFloat imageHeight = statusImage.size.height;
    CGFloat imageWidth = statusImage.size.width;
   
    self.statusImage.frame = CGRectMake( (LABEL_X-imageWidth)/2, (self.statusContainer.frame.size.height-imageHeight)/2, imageWidth, imageHeight);
    self.statusImage.image = statusImage;
}
-(void)updateTags{
    self.tagsLabel.frame = TAGS_LABEL_RECT;
    NSString *tagsString = [self.model stringifyTags];
    if(!tagsString || tagsString.length == 0) tagsString = @"Set tags";
    self.tagsLabel.text = tagsString;
    [self.tagsLabel sizeToFit];

    CGFloat containerHeight = self.tagsLabel.frame.size.height + 2*TAGS_LABEL_PADDING;
    CGRectSetHeight(self.tagsContainerView, containerHeight);
}
-(void)updateAlarm{
    if(!self.model.alarm || [self.model.alarm isInPast]){
        self.alarmImage.highlighted = NO;
        self.alarmLabel.text = @"Remind me";
    }
    else{
        self.alarmImage.highlighted = YES;
        self.alarmLabel.text = [self.model readableTime:self.model.alarm showTime:YES];
    }
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
        self.editTitleTextView.text = model.title;
        [self updateStatus];
        [self updateTags];
        [self updateAlarm];
        [self updateNotes];
        [self layout];
    }
}
-(void)layout{
    CGFloat tempHeight = 0;
    CGRectSetY(self.statusContainer, tempHeight);
    tempHeight += self.statusContainer.frame.size.height;
    
    CGRectSetY(self.alarmContainer, tempHeight);
    tempHeight += self.alarmContainer.frame.size.height;
    
    CGRectSetY(self.tagsContainerView, tempHeight);
    tempHeight += self.tagsContainerView.frame.size.height;
    
    CGRectSetY(self.notesView, tempHeight);
    tempHeight += self.notesView.frame.size.height;
    
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
