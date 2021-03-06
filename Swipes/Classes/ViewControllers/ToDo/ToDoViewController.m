//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define CONTENT_VIEW_TAG 9
#define SHOW_ITEM_TAG 5432
#define EVERNOTE_ITEM_BUTTON_TAG 5433


#define TOOLBAR_HEIGHT 52
#define DEFAULT_ROW_HEIGHT 60
#define SCHEDULE_ROW_HEIGHTS 46
#define LABEL_X CELL_LABEL_X

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 18
#define TITLE_BOTTOM_MARGIN (3)
#define CONTAINER_INIT_HEIGHT (TITLE_HEIGHT + TITLE_TOP_MARGIN + TITLE_BOTTOM_MARGIN)


#define NOTES_PADDING 8
#define kRepeatPickerHeight 70

#define kTopSubtaskTarget 140
#define kBottomSubtaskExtraHeight 150

#define kBottomSubtaskHeight (kDragableHeight+kBottomSubtaskExtraHeight)


#import "StyleHandler.h"

#import "ToDoListViewController.h"
#import "KPSegmentedViewController.h"
#import "HPGrowingTextView.h"
#import "NotesView.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
#import "KPToolbar.h"
#import "KPBlurry.h"
#import "KPRepeatPicker.h"
#import "HintHandler.h"
//#import "UIButton+PassTouch.h
#import "AnalyticsHandler.h"
#import "UserHandler.h"
#import "RootViewController.h"

#import "KPTimePicker.h"
#import "DotView.h"
#import "EvernoteView.h"
#import "DropboxView.h"
#import "AttachmentEditView.h"
//#import "MCSwipeTableViewCell.h"

#import "SectionHeaderView.h"

#import "SchedulePopup.h"
#import "UIView+Utilities.h"
#import "ToDoViewController+ViewHelpers.h"

#import "SubtaskController.h"
#import "UIGestureRecognizer+UIBreak.h"
#import "UIView+Utilities.h"
#import "UIImage+Blur.h"
#import "KPAttachment.h"
#import "AudioHandler.h"

#import "SyncLabel.h"
#import "EvernoteIntegration.h"
#import "GmailIntegration.h"

#import "ToDoViewController.h"

typedef NS_ENUM(NSUInteger, KPEditMode){
    KPEditModeNone = 0,
    KPEditModeTitle,
    KPEditModeActionSteps,
    KPEditModeRepeat,
    KPEditModeTags,
    KPEditModeAlarm,
    KPEditModeNotes,
    KPEditModeEvernote,
    KPEditModeDropbox
};



@interface ToDoViewController () <HPGrowingTextViewDelegate, NotesViewDelegate,EvernoteViewDelegate, ToolbarDelegate,KPRepeatPickerDelegate,KPTimePickerDelegate,MCSwipeTableViewCellDelegate, DropboxViewDelegate, SubtaskControllerDelegate, AttachmentEditViewDelegate, UITextViewDelegate>
@property (nonatomic) KPEditMode activeEditMode;
@property (nonatomic) CellType cellType;
@property (nonatomic) NSString *objectId;
@property (nonatomic) CGFloat kbdHeight;
@property (nonatomic,strong) KPTimePicker *timePicker;


@property (nonatomic) KPToolbar *toolbarEditView;
@property (nonatomic) SectionHeaderView *sectionHeader;


@property (nonatomic) MCSwipeTableViewCell *cell;
@property (nonatomic) UIScrollView *scrollView;


@property (nonatomic) UIView *titleContainerView;
@property (nonatomic) DotView *dotView;
@property (nonatomic) UIView *dotSeperator;
@property (nonatomic) HPGrowingTextView *textView;

@property (nonatomic) UIView *subtasksContainer;
@property (nonatomic) UIView *tagsContainerView;
@property (nonatomic) UIView *alarmContainer;
@property (nonatomic) UIView *notesContainer;
@property (nonatomic) UIView *repeatedContainer;

@property (nonatomic) IBOutletCollection(AttachmentEditView) NSArray *attachmentViews;

@property (nonatomic) KPRepeatPicker *repeatPicker;
@property (nonatomic) UILabel *subtaskLabel;
@property (nonatomic) UILabel *alarmLabel;
@property (nonatomic) UILabel *tagsLabel;
@property (nonatomic) UITextView *notesView;
@property (nonatomic) UILabel *repeatedLabel;
@property (nonatomic) SyncLabel *syncLabel;

@property (nonatomic) UILabel *scheduleImageIcon;

@property (nonatomic) SubtaskController *subtasksController;
@property (nonatomic) UIImageView *subtaskOverlay;
@property (nonatomic) CGPoint startPoint;


@property (nonatomic) CGRect editingFrame;
@property (nonatomic) BOOL fireHint;

@end

@implementation ToDoViewController

#pragma mark - Getters and Setters
-(void)setCellType:(CellType)cellType{
    if(_cellType != cellType){
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
-(void)setModel:(KPToDo *)model{
    [self.subtasksController setModel:model];
    if(_model != model){
        _model = model;
    }
    [self update];
}
-(void)setActiveEditMode:(KPEditMode)activeEditMode{
    if(activeEditMode != _activeEditMode){
        KPEditMode oldState = _activeEditMode;
        _activeEditMode = activeEditMode;
        [self clearActiveEditMode:oldState];
    }
}

#pragma mark TimePicker
-(void)openTimePicker{
    if(self.timePicker) return;
    NSDate *date = self.model.schedule;
    if(!date) return;
    ROOT_CONTROLLER.lockSettings = YES;
    self.timePicker = [[KPTimePicker alloc] initWithFrame:self.view.bounds];
    self.timePicker.delegate = self;
    self.timePicker.pickingDate = date;
    self.timePicker.minimumDate = [date dateAtStartOfDay];
    //if([date isToday]) self.timePicker.minimumDate = [[NSDate date] dateByAddingMinutes:5];
    self.timePicker.maximumDate = [[[date dateByAddingDays:1] dateAtStartOfDay] dateBySubtractingMinutes:5];
    self.timePicker.alpha = 0;
    [self.view addSubview:self.timePicker];
    [UIView animateWithDuration:0.2f animations:^{
        self.timePicker.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark - UIGestureRecognizerDelegate
-(void)longPressRecognized:(UIGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self openTimePicker];
    }
}
#pragma mark - KPTimePickerDelegate
-(void)timePicker:(KPTimePicker *)timePicker selectedDate:(NSDate *)date{
    [UIView animateWithDuration:0.2f animations:^{
        timePicker.alpha = 0;
    } completion:^(BOOL finished) {
        ROOT_CONTROLLER.lockSettings = NO;
        if(finished){
            [timePicker removeFromSuperview];
            self.timePicker = nil;
            if(date)
                [KPToDo scheduleToDos:@[self.model] forDate:date save:YES from:@"Time picker"];
            [self update];
        }
    }];
}


#pragma mark Notification
- (void)updateFromSync:(NSNotification *)notification
{
    NSDictionary *changeEvent = [notification userInfo];
    NSSet *updatedObjects = [changeEvent objectForKey:@"updated"];
    NSSet *deletedObjects = [changeEvent objectForKey:@"deleted"];
    if(deletedObjects && [deletedObjects containsObject:self.objectId]){
        [self pressedBack:nil];
    }else if(updatedObjects && [updatedObjects containsObject:self.model.objectId]){
        [self update];
    }
}



-(void)clearActiveEditMode:(KPEditMode)state{
    switch (state) {
        case KPEditModeTitle:{
            [self.textView resignFirstResponder];
            break;
        }
        case KPEditModeActionSteps:{
            [self.subtasksController resign];
            break;
        }
        case KPEditModeRepeat:
            [self updateRepeated];
            [self layoutWithDuration:0];
            break;
        case KPEditModeTags:
        case KPEditModeAlarm:
        case KPEditModeNotes:
        case KPEditModeEvernote:
        case KPEditModeDropbox:
        case KPEditModeNone:
            break;
    }
}




#pragma mark KPRepeatPickerDelegate
-(void)repeatPicker:(KPRepeatPicker *)repeatPicker selectedOption:(RepeatOptions)option{
    self.activeEditMode = KPEditModeNone;
    if(option != self.model.repeatOptionValue){
        [self.model setRepeatOption:option save:YES];
    }
    [self updateRepeated];
    [self layoutWithDuration:0];
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if([[UIApplication sharedApplication] canOpenURL:URL]){
        return YES;
    }
    return NO;
}


#pragma mark MCSwipeTableViewCellDelegate
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    __block CellType targetCellType = [StyleHandler cellTypeForCell:self.cellType state:state];
    switch (targetCellType) {
        case CellTypeSchedule:{
            //SchedulePopup *popup = [[SchedulePopup alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
            SchedulePopup *popup = [SchedulePopup popupWithFrame:self.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate, CLPlacemark *chosenLocation, GeoFenceType type) {
                [BLURRY dismissAnimated:YES];
                if(button == KPScheduleButtonCancel){
                }
                else if(button == KPScheduleButtonLocation){
                    [KPToDo notifyToDos:@[self.model] onLocation:chosenLocation type:type save:YES];
                }
                else{
                    [KPToDo scheduleToDos:@[self.model] forDate:chosenDate save:YES from:@"Swipe"];
                }
                [self update];
            }];
            popup.calendarDate = self.model.schedule;
            popup.numberOfItems = 1;
            BLURRY.blurryTopColor = alpha(tcolorF(TextColor,ThemeDark),0.1);
            BLURRY.dismissAction = ^{
                [cell bounceToOrigin];
            };
            [BLURRY showView:popup inViewController:self];
            return;
        }
        case CellTypeToday:
            [KPToDo scheduleToDos:@[self.model] forDate:[NSDate date] save:YES from:@"Swipe"];
            break;
        case CellTypeDone:
            [KPToDo completeToDos:@[self.model] save:YES context:nil from:@"Swipe"];
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
        if(self.model){
            self.model.title = growingTextView.text;
            [KPToDo saveToSync];
        }
    }
    else{
        if(self.model){
            growingTextView.text = self.model.title;
        }
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
    [self layoutWithDuration:0];
    //CGRectSetY(self.scrollView, CGRectGetMaxY(self.titleContainerView.frame));
    //CGRectSetHeight(self.scrollView, self.contentView.frame.size.height-CGRectGetMaxY(self.titleContainerView.frame)-TOOLBAR_HEIGHT);
}

#pragma mark - NotesViewDelegate

-(void)savedNotesView:(NotesView *)notesView text:(NSString *)text{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
    self.model.notes = text;
    [KPToDo saveToSync];
    [ANALYTICS trackEvent:@"Update Notes" options:@{ @"Length": @(text.length) }];
    [ANALYTICS trackCategory:@"Tasks" action:@"Note" label:nil value:@(text.length)];
    [self updateNotes];
    [self layoutWithDuration:0];
}

-(void)pressedCancelNotesView:(NotesView *)notesView{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
}

#pragma mark - EvernoteViewDelegate

- (void)selectedEvernoteInView:(EvernoteView *)EvernoteView noteRef:(ENNoteRef *)noteRef title:(NSString *)title sync:(BOOL)sync
{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
    [self.model attachService:EVERNOTE_SERVICE title:title identifier:[EvernoteIntegration ENNoteRefToNSString:noteRef] inContext:nil sync:sync from:@"manual"];
    [KPToDo saveToSync];
    [self updateAttachments];
    [self layoutWithDuration:0];
}

- (void)closeEvernoteView:(EvernoteView *)evernoteView
{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
    [self layoutWithDuration:0];
}

#pragma mark - DropboxViewDelegate

- (void)selectedFileInView:(DropboxView *)DropboxView path:(NSString *)path
{
    DLog(@"selected dropbox file with path: %@", path);
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
    [self.model attachService:DROPBOX_SERVICE title:[path lastPathComponent] identifier:path inContext:nil sync:NO from:@"manual"];
    [KPToDo saveToSync];
    [self updateAttachments];
    [self layoutWithDuration:0];
}

- (void)closeDropboxView:(DropboxView *)DropboxView
{
    self.activeEditMode = KPEditModeNone;
    [BLURRY dismissAnimated:YES];
}

#pragma mark - Update UI for model

- (void)update
{
    // Save objectId - if deleted from sync we know it here
    if (self.model.objectId)
        self.objectId = self.model.objectId;
    if( self.activeEditMode != KPEditModeTitle && ![self.textView.text isEqualToString:self.model.title]){
        self.textView.text = self.model.title;
        
    }
    self.cellType = [self.model cellTypeForTodo];
    [self updateTags];
    [self updateSchedule];
    [self updateNotes];
    [self updateDot];
    [self updateRepeated];
    [self updateAttachments];
    [self updateSectionHeader];
    [self.subtasksController fullReload];
    [self layoutWithDuration:0];
    
}


-(void)updateTags{
    self.tagsLabel.frame = CGRectMake(LABEL_X, 0, self.view.frame.size.width - LABEL_X - 10, 500);
    NSString *tagsString = self.model.tagString;
    if(!tagsString || tagsString.length == 0){
        tagsString = NSLocalizedString(@"Add tags", nil);
    }
    CGSize basicSize = sizeWithFont(tagsString,self.tagsLabel.font);
    CGFloat padding = (SCHEDULE_ROW_HEIGHTS - basicSize.height)/2;
    self.tagsLabel.text = tagsString;
    [self.tagsLabel sizeToFit];
    CGRectSetWidth(self.tagsLabel, self.view.frame.size.width - LABEL_X - 10);
    
    CGFloat containerHeight = self.tagsLabel.frame.size.height + 2*padding;
    CGRectSetHeight(self.tagsContainerView, containerHeight);
    CGRectSetCenterY(self.tagsLabel,containerHeight/2);
}

- (void)updateSchedule
{
    BOOL isLocation = NO;
    if (!self.model.schedule) { // || [self.model.schedule isInPast]){
        if (self.model.location) {
            isLocation = YES;
            NSArray *location = [self.model.location componentsSeparatedByString:kLocationSplitStr];
            NSString *name = [location objectAtIndex:1];
            //NSString *prestring = [[location objectAtIndex:4] isEqualToString:@"OUT"] ? @"Leave: " : @"Arrive: ";
            //self.alarmLabel.text = [prestring stringByAppendingString:name];
            self.alarmLabel.text = name;
        }
        else {
            self.alarmLabel.text = NSLocalizedString(@"Unspecified", nil);
            if (self.model.completionDate) {
                self.alarmLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Completed", nil),[UtilityClass readableTime:self.model.completionDate showTime:YES]];
            }
        }
    }
    else {
        self.alarmLabel.text = [NSString stringWithFormat:@"%@",[UtilityClass readableTime:self.model.schedule showTime:YES]];
    }
    [self.scheduleImageIcon setText:isLocation ? iconString(@"editLocation") : iconString(@"later")];
}

- (void)updateNotes
{
    
    NSDictionary *defaultAttributes = @{
                                        NSForegroundColorAttributeName: tcolor(TextColor),
                                        NSFontAttributeName: EDIT_TASK_TEXT_FONT
                                        };
    if(!self.model.notes || self.model.notes.length == 0){
        self.notesView.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Add notes", nil) attributes:defaultAttributes];
    }
    else{
        self.notesView.attributedText = [[NSAttributedString alloc] initWithString:self.model.notes attributes:defaultAttributes];
    }
   
    CGRectSetSize(self.notesView, self.view.frame.size.width-LABEL_X-10, 1500);
    //CGSize contentSize = [self.notesView sizeThatFits:CGSizeMake(self.notesView.frame.size.width, 500)];
    [self.notesView sizeToFit];
    CGRectSetWidth(self.notesView, self.view.frame.size.width-LABEL_X-10);
    //    DLogFrame(self.notesView);
    
    CGRectSetHeight(self.notesView,self.notesView.frame.size.height);
    
    CGRectSetHeight(self.notesContainer, self.notesView.frame.size.height+2*NOTES_PADDING);
}

-(void)updateDot{
    UIColor *newDotColor = [StyleHandler colorForCellType:[self.model cellTypeForTodo]];
    self.dotView.dotColor = newDotColor;
    self.dotView.priority = (self.model.priorityValue == 1);
    self.dotSeperator.backgroundColor = alpha(newDotColor,kLineAlpha);
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
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"en_US", nil)]];
    BOOL addTime = YES;
    if (self.activeEditMode == KPEditModeRepeat) {
        labelText = NSLocalizedString(@"Repeat every...", nil);
    }
    else {
        switch (self.model.repeatOptionValue) {
            case RepeatEveryDay:{
                labelText = NSLocalizedString(@"Every day", nil);
                break;
            }
            case RepeatEveryMonFriOrSatSun:{
                if(self.model.repeatedDate.isTypicallyWeekend) labelText = NSLocalizedString(@"Every Saturday and Sunday", nil);
                else labelText = NSLocalizedString(@"Every Monday to Friday", nil);
                break;
            }
            case RepeatEveryWeek:{
                [dateFormatter setDateFormat:@"EEEE"];
                NSString *weekday = [dateFormatter stringFromDate:self.model.repeatedDate];
                labelText = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Every", nil),weekday];
                break;
            }
            case RepeatEveryMonth:{
                NSString *dateOfMonth = [UtilityClass dayOfMonthForDate:self.model.repeatedDate];
                labelText = [NSString stringWithFormat:NSLocalizedString(@"Every month the %@", nil),dateOfMonth];
                break;
            }
            case RepeatEveryYear:{
                NSString *dateOfMonth = [UtilityClass dayOfMonthForDate:self.model.repeatedDate];
                [dateFormatter setDateFormat:@"MMMM"];
                NSString *month = [dateFormatter stringFromDate:self.model.repeatedDate];
                labelText = [NSString stringWithFormat:NSLocalizedString(@"Every year %@ %@", nil),month,dateOfMonth];
                break;
            }
            default:
                addTime = NO;
                labelText = NSLocalizedString(@"Never repeat", nil);
                break;
        }
        if(addTime) labelText = [labelText stringByAppendingFormat:NSLocalizedString(@" at %@", nil),timeInString];
    }
    self.repeatedLabel.text = labelText;
}


-(void)updateAttachments{
    NSSortDescriptor *firstDesc = [NSSortDescriptor sortDescriptorWithKey:@"service" ascending:YES];
    NSSortDescriptor *secondDesc = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSSortDescriptor *thirdDesc = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    NSArray *attachments = [[self.model attachments] sortedArrayUsingDescriptors:@[firstDesc,secondDesc,thirdDesc]];
    BOOL addViews = NO;
    if(attachments.count != self.attachmentViews.count)
        addViews = YES;
    if(!addViews){
        NSInteger counter = 0;
        for(AttachmentEditView *view in self.attachmentViews){
            KPAttachment *attachment = [attachments objectAtIndex:0];
            if(![attachment.service isEqualToString:view.service] || ![attachment.identifier isEqualToString:view.identifier])
                addViews = YES;
            counter++;
        }
    }
    
    if(addViews){
        for(AttachmentEditView *view in self.attachmentViews){
            [view removeFromSuperview];
        }
        
        NSMutableArray *attachmentViews = [NSMutableArray array];
        for (KPAttachment *attachment in attachments) {
            AttachmentEditView *attachmentEditView = [[AttachmentEditView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCHEDULE_ROW_HEIGHTS)];
            attachmentEditView.hidden = YES;
            attachmentEditView.identifier = attachment.identifier;
            attachmentEditView.service = attachment.service;
            attachmentEditView.delegate = self;
            BOOL shouldAdd = YES;
            if ([attachment.service isEqualToString:EVERNOTE_SERVICE]){
                [attachmentEditView setIconString:@"editEvernote"];
                
                CGRectSetHeight(attachmentEditView, SCHEDULE_ROW_HEIGHTS + 10);
                BOOL isSyncing = [attachment.sync boolValue];
                if (isSyncing)
                    [attachmentEditView setSyncString:[NSLocalizedString(@"Attached", nil) uppercaseString] iconString:nil];
                else
                    [attachmentEditView setSyncString:[NSLocalizedString(@"Deleted", nil) uppercaseString] iconString:@"actionDelete"];
                [attachmentEditView setTitleString:attachment.title];
            }
            else if ([attachment.service isEqualToString:URL_SERVICE]) {
                [attachmentEditView setIconString:@"editURL"];
                NSString *title = attachment.identifier;
                [attachmentEditView setTitleString:title];
            }
            else if ([attachment.service isEqualToString:GMAIL_SERVICE]) {
                NSString *title = [kGmInt NSStringToEmail:attachment.identifier];
                if (nil == title) {
                    // for some reason attachment is broken
                    shouldAdd = NO;
                }
                else {
                    [attachmentEditView setIconString:@"editMail"];
                    [attachmentEditView setTitleString:title];
                    if (![attachment.sync boolValue]) {
                        [attachmentEditView setSyncString:[NSLocalizedString(@"Archived", nil) uppercaseString] iconString:@"done"];
                        CGRectSetHeight(attachmentEditView, SCHEDULE_ROW_HEIGHTS + 10);
                    }
                    else {
                        [kGmInt checkArchievedThread:[kGmInt NSStringToThreadId:attachment.identifier] block:^(BOOL isArchived, NSError *error) {
                            if ([attachment.sync boolValue] == isArchived) {
                                // we have difference in our knowledge about is this task archieved
                                if (isArchived) {
                                    attachment.sync = @(NO);
                                    [KPToDo saveToSync];
                                }
                                NSString* objectId = attachment.todo.objectId;
                                if (objectId) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated sync" object:nil userInfo:@{ @"updated" : @[objectId] }];
                                }
                            }
                        }];
                    }
                }
            }
            else
                shouldAdd = NO;
            
            if (shouldAdd) {
                [self.scrollView addSubview:attachmentEditView];
                [attachmentViews addObject:attachmentEditView];
            }
        }
        self.attachmentViews = attachmentViews;
    }
}

-(void)updateSectionHeader
{
    [self.sectionHeader setColor:[StyleHandler colorForCellType:self.cellType]];
    NSInteger numberOfSubtasks = [self.model getSubtasks].count;
    self.sectionHeader.progress = (numberOfSubtasks > 0);
    if(numberOfSubtasks > 0){
        CGRectSetHeight(self.sectionHeader, 6);
        NSPredicate *completedPredicate = [NSPredicate predicateWithFormat:@"completionDate != nil"];
        NSInteger numberOfCompletedSubtasks = [[self.model getSubtasks] filteredSetUsingPredicate:completedPredicate].count;
        CGFloat percentage = (CGFloat)numberOfCompletedSubtasks / numberOfSubtasks;
        self.sectionHeader.progressPercentage = percentage;
        
        NSString *title = (numberOfCompletedSubtasks != numberOfSubtasks) ? [NSString stringWithFormat:NSLocalizedString(@"%li / %li STEPS", nil),(long)numberOfCompletedSubtasks,(long)numberOfSubtasks] : [NSLocalizedString(@"All Done", nil) uppercaseString];
        
        [self.sectionHeader setTitle:title];
    }
    else{
        [self.sectionHeader setTitle:[[self.model readableTitleForStatus] uppercaseString]];
        CGRectSetHeight(self.sectionHeader, 1.5);
    }
}

-(void)layoutWithDuration:(CGFloat)duration{
    if(duration > 0){
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:duration];
    }
    CGFloat tempHeight = 0;
    
    
    CGRectSetY(self.titleContainerView, tempHeight);
    tempHeight += self.titleContainerView.frame.size.height;
    
    
    CGRectSetY(self.subtasksContainer, tempHeight);
    tempHeight += self.subtasksContainer.frame.size.height + 20;
    
    CGFloat targetAlpha = self.subtasksController.expanded ? 0 : 1;
    self.alarmContainer.alpha = self.repeatedContainer.alpha = self.tagsContainerView.alpha = self.notesContainer.alpha = targetAlpha;
    for( AttachmentEditView *view in self.attachmentViews)
        view.alpha = targetAlpha;
    
    CGFloat heightWithSubtasks = tempHeight;
    
    if(!self.subtasksController.expanded){
        
        
        CGRectSetY(self.alarmContainer, tempHeight);
        tempHeight += self.alarmContainer.frame.size.height;
        
        
        self.repeatedContainer.hidden = !self.model.schedule;
        if (self.model.completionDate)
            self.repeatedContainer.hidden = YES;
        
        if (!self.repeatedContainer.hidden){
            CGFloat repeatHeight = (self.activeEditMode == KPEditModeRepeat) ? SCHEDULE_ROW_HEIGHTS+kRepeatPickerHeight : SCHEDULE_ROW_HEIGHTS;
            CGRectSetHeight(self.repeatedContainer, repeatHeight);
            CGRectSetY(self.repeatedContainer, tempHeight);
            tempHeight += self.repeatedContainer.frame.size.height;
        }
        
        
        CGRectSetY(self.tagsContainerView, tempHeight);
        tempHeight += self.tagsContainerView.frame.size.height;
        
        for( AttachmentEditView *attachment in self.attachmentViews){
            
            CGRectSetY(attachment, tempHeight);
            tempHeight += attachment.frame.size.height;
            attachment.hidden = NO;
        }
        
        
        
        CGRectSetY(self.notesContainer, tempHeight);
        tempHeight += self.notesContainer.frame.size.height;
    }
    CGFloat targetHeight = self.subtasksController.expanded ? heightWithSubtasks : tempHeight;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat width = isPortrait ? self.scrollView.frame.size.width : self.scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(width,targetHeight);
    
    CGRectSetHeight(self.cell,self.view.bounds.size.height-self.cell.frame.origin.y);
    if(duration > 0){
        [UIView commitAnimations];
    }
}

#pragma mark - Toolbar button handlers

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
    if(item == 2){
        [self.segmentedViewController deleteNumberOfItems:1 inView:self completion:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [KPToDo deleteToDos:@[self.model] inContext:nil save:YES force:NO];
                [self pressedBack:nil];
            }
        }];
    }
    else if(item == 1){
        CGRect frame = ((UIButton *)toolbar.barButtons[item]).frame;
        frame.origin.x += toolbar.frame.origin.x;
        frame.origin.y += toolbar.frame.origin.y;
        [ROOT_CONTROLLER shareTasks:@[self.model] withFrame:frame];
        /*NSArray *tasks = [[self.menuViewController currentViewController] selectedItems];
         [self.segmentedViewController pressedShare:self];*/
    }
    else if (item == 0 ){
        [self pressedEvernote:toolbar];
    }
}

#pragma mark - Click handlers

-(void)pressedPriority{
    
    [self.model switchPriority];
    if([self.model.priority boolValue])
        [kAudio playSoundWithName:@"Succesful action.m4a"];
    else
        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
    
    [self updateDot];
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
    [self layoutWithDuration:0];
}

-(void)pressedDone:(id)sender
{
    [self.delegate didPressCloseToDoViewController:self];
}

-(void)pressedSchedule:(id)sender
{
    self.activeEditMode = KPEditModeAlarm;
    SchedulePopup *popup = [SchedulePopup popupWithFrame:self.view.bounds block:^(KPScheduleButtons button, NSDate *chosenDate, CLPlacemark *chosenLocation, GeoFenceType type) {
        [BLURRY dismissAnimated:YES];
        if (button == KPScheduleButtonCancel)
            return;
        else if(button == KPScheduleButtonLocation && chosenLocation){
            [KPToDo notifyToDos:@[self.model] onLocation:chosenLocation type:type save:YES];
        }
        else {
            // TODO: Fix the edit mode
            [KPToDo scheduleToDos:@[self.model] forDate:chosenDate save:YES from:@"Schedule button"];
            //[KPToDo scheduleToDos:@[self.parent.showingModel] forDate:chosenDate save:YES];
            [self.model setRepeatOption:self.model.repeatOptionValue save:YES];
        }
        [self update];
    }];
    popup.calendarDate = self.model.schedule;
    popup.numberOfItems = 1;
    BLURRY.blurryTopColor = alpha(tcolorF(TextColor,ThemeDark),0.1);
    [BLURRY showView:popup inViewController:self];
    /*if([self.delegate respondsToSelector:@selector(scheduleToDoViewController:)]) [self.delegate scheduleToDoViewController:self];*/
}

-(void)pressedNotes:(id)sender
{
    self.activeEditMode = KPEditModeNotes;
    CGFloat extra = [GlobalApp statusBarHeight];
    NotesView *notesView = [[NotesView alloc] initWithFrame:CGRectMake(0, extra, self.view.frame.size.width, self.view.frame.size.height - extra)];
    notesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
        [self layoutWithDuration:0];
    }];
}

-(void)clickedAttachment:(AttachmentEditView *)attachmentView
{
    if([attachmentView.service isEqualToString:EVERNOTE_SERVICE])
        [self pressedEvernote:attachmentView];
    else if([attachmentView.service isEqualToString:URL_SERVICE])
        [self pressedURL:attachmentView];
    else if([attachmentView.service isEqualToString:GMAIL_SERVICE])
        [self pressedGmail:attachmentView];
}

- (void)pressedGmail:(AttachmentEditView*)attachmentView
{
    [kGmInt openMail:attachmentView.identifier];
}

-(void)pressedURL:(AttachmentEditView*)attachmentView
{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Open Link", nil) andMessage:NSLocalizedString(@"Do you want to open the link?", nil) block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:attachmentView.identifier]];
        }
    }];
}

-(void)pressedEvernote:(UIView*)sender
{
    if(!kUserHandler.isLoggedIn){
        [ROOT_CONTROLLER accountAlertWithMessage:NSLocalizedString(@"Register an account to backup your data and keep your Evernotes in sync with Swipes", nil)];
        return;
    }
    voidBlock setNewEvernote = ^{
        if ([EvernoteIntegration isAPILimitReached]) {
            [UTILITY alertWithTitle:nil andMessage:[EvernoteIntegration APILimitReachedMessage]];
        }
        else {
            self.activeEditMode = KPEditModeEvernote;
            EvernoteView *evernoteView = [[EvernoteView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
            evernoteView.delegate = self;
            evernoteView.caller = self.segmentedViewController;
            BLURRY.showPosition = PositionBottom;
            [BLURRY showView:evernoteView inViewController:self];
        }
    };
    
    if([sender isKindOfClass:[AttachmentEditView class]]){
        NSArray *buttons = @[[NSLocalizedString(@"cancel", nil) capitalizedString], NSLocalizedString(@"Remove note", nil)];
        AttachmentEditView *evernoteEditView = (AttachmentEditView*)sender;
        if( [GlobalApp isEvernoteInstalled] ){
            buttons = @[[NSLocalizedString(@"cancel", nil) capitalizedString],NSLocalizedString(@"Remove note", nil),NSLocalizedString(@"Open note", nil)];
        }
        [UTILITY alertWithTitle:NSLocalizedString(@"Evernote", nil) andMessage:NSLocalizedString(@"What do you want to do?", nil) buttonTitles:buttons block:^(NSInteger number, NSError *error) {
            //DLog(@"%li",(long)number);
            KPAttachment *attachment = [self.model attachmentForService:EVERNOTE_SERVICE identifier:evernoteEditView.identifier];
            if(number == 1){
                [self.model removeAllAttachmentsForService:EVERNOTE_SERVICE identifier:evernoteEditView.identifier inContext:nil];
                [self update];
            }
            else if(number == 2){
                if([GlobalApp isEvernoteInstalled]){
                    //DLog(@"attachment %@",attachment.identifier);
                    [[ENSession sharedSession] viewNoteInEvernote:[EvernoteIntegration NSStringToENNoteRef:attachment.identifier]];
                    [ANALYTICS trackEvent:@"Open In Evernote" options:nil];
                    [ANALYTICS trackCategory:@"Actions" action:@"Open In Evernote" label:nil value:nil];
                    //[ENSession
//                    EDAMNote *note = [[EDAMNote alloc] init];
//                    note.guid = attachment.identifier;
                }
                else{
                    
                }
            }
        }];
    }
    else
        setNewEvernote();
}

-(void)pressedDropbox:(id)sender
{
    self.activeEditMode = KPEditModeDropbox;
    DropboxView *view = [[DropboxView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    view.delegate = self;
    view.caller = self.segmentedViewController;
    view.useThumbnails = YES;
    BLURRY.showPosition = PositionBottom;
    [BLURRY showView:view inViewController:self];
}

- ( void )pressedExpand: ( UIButton* )sender{
    [self.subtasksController setExpanded:!self.subtasksController.expanded animated:YES];
}
-(void)subtaskController:(SubtaskController *)controller changedExpanded:(BOOL)expanded{
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.25f];
    //self.expandButton.alpha = expanded ? 0 : 1;
    //self.expandButton.transform = expanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}

#pragma mark - UIViewController stuff

-(id)init{
    self = [super init];
    if (self){
        self.view.tag = SHOW_ITEM_TAG;
        self.view.backgroundColor = tcolor(BackgroundColor);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        NSInteger startY = [GlobalApp statusBarHeight];
        NSInteger toolbarWidth = 135;
        NSInteger leftPadding = 45;
        self.toolbarEditView = [[KPToolbar alloc] initWithFrame:CGRectMake(self.view.frame.size.width - toolbarWidth - leftPadding, startY, toolbarWidth, TOOLBAR_HEIGHT) items:nil delegate:self];
        self.toolbarEditView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.toolbarEditView.font = iconFont(23);
        self.toolbarEditView.titleColor = tcolor(TextColor);
        self.toolbarEditView.titleHighlightString = @"Full";
        self.toolbarEditView.items = @[@"integrationEvernote",@"actionShare",@"actionDelete"];
        [self.view addSubview:self.toolbarEditView];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, startY, TOOLBAR_HEIGHT, TOOLBAR_HEIGHT)];
        [backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
        backButton.titleLabel.font = iconFont(23);
        [backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [self.view addSubview:backButton];
        
        self.cell = [[MCSwipeTableViewCell alloc] init];
        self.cell.contentView.backgroundColor = tcolor(TasksColor);
        self.cell.frame = CGRectMake(0, CGRectGetMaxY(self.toolbarEditView.frame), self.view.frame.size.width,
                                     self.view.bounds.size.height - CGRectGetMaxY(self.toolbarEditView.frame));
        self.cell.autoresizingMask = (UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight);
        self.cell.contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight);
        self.cell.shouldRegret = YES;
        self.cell.delegate = self;
        self.cell.bounceAmplitude = 0;
        self.cell.mode = MCSwipeTableViewCellModeExit;
        UIView *contentView = self.cell.contentView;
        /*
         contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
         contentView.backgroundColor = tcolor(DoneColor);
         contentView.tag = CONTENT_VIEW_TAG;*/
        
        self.titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cell.frame.size.width, CONTAINER_INIT_HEIGHT)];
        self.titleContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.titleContainerView.backgroundColor = tcolor(BackgroundColor);
        
        CGFloat buttonWidth = BUTTON_HEIGHT;
        
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(CELL_LABEL_X, TITLE_TOP_MARGIN, self.titleContainerView.frame.size.width - buttonWidth - CELL_LABEL_X, TITLE_HEIGHT)];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textView.contentInset = UIEdgeInsetsMake(0, -8, 0, -8);
        self.textView.minNumberOfLines = 1;
        self.textView.backgroundColor = CLEAR;
        self.textView.maxNumberOfLines = 6;
        self.textView.returnKeyType = UIReturnKeyDone; //just as an example
        self.textView.font = TITLE_LABEL_FONT;
        self.textView.delegate = self;
        self.textView.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        self.textView.textColor = tcolor(TextColor);
        [self.titleContainerView addSubview:self.textView];
        
        
        CGFloat dotWidth = CELL_LABEL_X;
        DotView *dotView = [[DotView alloc] init];
        dotView.dotColor = tcolor(TasksColor);
        UIButton *priorityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, dotWidth, CONTAINER_INIT_HEIGHT)];
        priorityButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [priorityButton addTarget:self action:@selector(pressedPriority) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetCenter(dotView, dotWidth/2, self.textView.frame.size.height / 2 + TITLE_TOP_MARGIN);
        dotView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin);
        [priorityButton addSubview:dotView];
        [self.titleContainerView addSubview:priorityButton];
        self.dotView = dotView;
        
        
        CGFloat sepHeight = CGRectGetHeight(priorityButton.frame) - CGRectGetMaxY(self.dotView.frame) - 2;
        
        CGFloat sepWidth = 1;
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(CELL_LABEL_X/2-sepWidth/2, priorityButton.frame.size.height-sepHeight, sepWidth, sepHeight)];
        seperator.backgroundColor = alpha(tcolor(TasksColor),kLineAlpha);
        seperator.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        [self.titleContainerView addSubview:seperator];
        self.dotSeperator = seperator;
        
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, contentView.frame.size.height)];
        self.scrollView.autoresizingMask = 0;// UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.backgroundColor = tcolor(BackgroundColor);
        self.scrollView.alwaysBounceVertical = YES;
        
        [self.scrollView addSubview:self.titleContainerView];
        
        /*
         Alarm container and button!
         */
        self.alarmContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCHEDULE_ROW_HEIGHTS)];
        self.alarmContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.scheduleImageIcon = [self addAndGetImage:@"later"  inView:self.alarmContainer];
        self.alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, self.view.frame.size.width - LABEL_X, self.alarmContainer.frame.size.height)];
        self.alarmLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.alarmLabel.backgroundColor = CLEAR;
        [self setColorsFor:self.alarmLabel];
        self.alarmLabel.font = EDIT_TASK_TEXT_FONT;
        [self.alarmContainer addSubview:self.alarmLabel];
        UIButton *alarmButton = [self addClickButtonToView:self.alarmContainer action:@selector(pressedSchedule:)];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
        longPressGestureRecognizer.allowableMovement = 44.0f;
        longPressGestureRecognizer.minimumPressDuration = 0.7f;
        [alarmButton addGestureRecognizer:longPressGestureRecognizer];
        [self.scrollView addSubview:self.alarmContainer];
        
        /*
         Repeats!
         */
        self.repeatedContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCHEDULE_ROW_HEIGHTS)];
        self.repeatedContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.repeatedContainer.userInteractionEnabled = YES;
        self.repeatedContainer.layer.masksToBounds = YES;
        
        self.repeatPicker = [[KPRepeatPicker alloc] initWithWidth:self.view.frame.size.width height:50 selectedDate:[NSDate date] option:RepeatNever];
        self.repeatPicker.delegate = self;
        CGRectSetY(self.repeatPicker, self.repeatedContainer.frame.size.height + (kRepeatPickerHeight - 50) / 2);
        [self.repeatedContainer addSubview:self.repeatPicker];
        
        
        [self addAndGetImage:@"editRepeat" inView:self.repeatedContainer];
        self.repeatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, self.view.frame.size.width - LABEL_X, self.repeatedContainer.frame.size.height)];
        self.repeatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.repeatedLabel.backgroundColor = CLEAR;
        [self setColorsFor:self.repeatedLabel];
        self.repeatedLabel.font = EDIT_TASK_TEXT_FONT;
        [self.repeatedContainer addSubview:self.repeatedLabel];
        UIButton *clickButton = [self addClickButtonToView:self.repeatedContainer action:@selector(pressedRepeat:)];
        clickButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:self.repeatedContainer];
        
        /*
         Tags Container with button!
         */
        self.tagsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCHEDULE_ROW_HEIGHTS)];
        self.tagsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //[self addSeperatorToView:self.tagsContainerView];
        [self addAndGetImage:@"editTags" inView:self.tagsContainerView];
        
        self.tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 0, self.view.frame.size.width - LABEL_X - 10, 500)];
        self.tagsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tagsLabel.numberOfLines = 0;
        self.tagsLabel.font = EDIT_TASK_TEXT_FONT;
        
        self.tagsLabel.backgroundColor = [UIColor clearColor];
        
        [self setColorsFor:self.tagsLabel];
        [self.tagsContainerView addSubview:self.tagsLabel];
        
        [self addClickButtonToView:self.tagsContainerView action:@selector(pressedTags:)];
        
        [self.scrollView addSubview:self.tagsContainerView];
        
        
        
        //Notes view
        
        self.notesContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCHEDULE_ROW_HEIGHTS)];
        self.notesContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.notesContainer.userInteractionEnabled = YES;
        [self addAndGetImage:@"editNotes" inView:self.notesContainer];
        self.notesView = [[UITextView alloc] initWithFrame:CGRectMake(LABEL_X, NOTES_PADDING, self.view.frame.size.width - LABEL_X - 200, 500)];
        self.notesView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.notesView.contentInset = UIEdgeInsetsMake(0,-5,0,0);
        self.notesView.editable = NO;
        self.notesView.userInteractionEnabled = YES;
        self.notesView.dataDetectorTypes = UIDataDetectorTypeAll;
        self.notesView.backgroundColor = CLEAR;
        UITapGestureRecognizer *tapRegocnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedNotes:)];
        [self.notesView addGestureRecognizer:tapRegocnizer];
        self.notesView.delegate = self;
        [self.notesContainer addSubview:self.notesView];
        
        UIButton *notesClickButton = [self addClickButtonToView:self.notesContainer action:@selector(pressedNotes:)];
        CGRectSetWidth(notesClickButton, LABEL_X);
        [self.scrollView addSubview:self.notesContainer];
        
        /* Adding scroll and content view */
        [contentView addSubview:self.scrollView];
        
        
        [self.view addSubview:self.cell];
        
        self.sectionHeader = [[SectionHeaderView alloc] initWithColor:[UIColor greenColor] font:SECTION_HEADER_FONT title:@"Test" width:self.view.frame.size.width];
        CGRectSetHeight(self.sectionHeader, 5);
        self.sectionHeader.fillColor = tcolor(BackgroundColor);
        CGRectSetY(self.sectionHeader, CGRectGetMaxY(self.toolbarEditView.frame));
        [self.view addSubview:self.sectionHeader];
        //self.sectionHeader.progress = YES;
        //self.sectionHeader.progressPercentage = 0.3;
        
        
        
        
        //[self.view addSubview:self.subtaskOverlay];
        
        //[self.view addSubview:subtasks.view];
        self.subtasksController = [[SubtaskController alloc] init];
        self.subtasksController.delegate = self;
        
        self.subtasksController.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGRectSetWidth(self.subtasksController.tableView, self.view.frame.size.width);
        self.subtasksContainer = self.subtasksController.tableView;
        //CGRectSetX(self.subtasksContainer, 10);
        [self.scrollView addSubview:self.subtasksContainer];
        
        
        
        UIPanGestureRecognizer *panning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        
        UIView *panningView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 10, self.view.bounds.size.height)];
        panningView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [panningView addGestureRecognizer:panning];
        [self.view addSubview:panningView];
        
        notify(@"updated sync",updateFromSync:);
//        notify(NH_UpdateLocalNotifications, update);
    }
    return self;
}

-(void)subtaskController:(SubtaskController *)controller changedToSize:(CGSize)size{
    //self.expandButton.hidden = ([self.model getSubtasks].count <= 1);
    [self layoutWithDuration:0];
    //NSLog(@"%f + %f + %f = %f",self.subtasksContainer.frame.size.height, self.subtasksContainer.frame.origin.y, self.cell.frame.origin.y, superFrame.origin.y);
    if(self.kbdHeight){
        CGRect newEdit = self.editingFrame;
        newEdit.origin.y =  self.subtasksContainer.frame.origin.y + size.height - self.editingFrame.size.height;
        self.editingFrame = newEdit;
        
        CGFloat visibleHeight = self.view.bounds.size.height - self.kbdHeight - self.cell.frame.origin.y;
        CGFloat newY = CGRectGetMaxY(self.editingFrame) - visibleHeight;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        if(newY >= 0)
            self.scrollView.contentOffset = CGPointMake(0, newY);
        
        [UIView commitAnimations];
    }
    [self updateSectionHeader];
}

-(void)didChangeSubtaskController:(SubtaskController *)controller{
    [self updateSectionHeader];
}

-(void)subtaskController:(SubtaskController *)controller editingCellWithFrame:(CGRect)frame{
    self.activeEditMode = KPEditModeActionSteps;
    CGRect superFrame = frame;
    superFrame.origin.y = frame.origin.y + self.subtasksContainer.frame.origin.y;
    self.editingFrame = superFrame;
}

-(void)keyboardWillShow:(NSNotification*)notification{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbdHeight = keyboardFrame.size.height;
    if(OSVER == 7){
        kbdHeight = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? keyboardFrame.size.height : keyboardFrame.size.width;
    }
    self.kbdHeight = kbdHeight;
    self.subtasksController.tableView.reorderingEnabled = NO;
    
    CGFloat visibleHeight = self.view.bounds.size.height - self.kbdHeight - self.cell.frame.origin.y;
    CGFloat newY = CGRectGetMaxY(self.editingFrame) - visibleHeight + 5;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.kbdHeight, 0);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(newY >= 0)
        self.scrollView.contentOffset = CGPointMake(0, newY);
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    self.editingFrame = CGRectZero;
    self.subtasksController.tableView.reorderingEnabled = YES;
    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.y -= self.kbdHeight;
    if(currentOffset.y < 0)
        currentOffset.y = 0;
    self.kbdHeight = 0;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.scrollView.contentOffset = currentOffset;
    [UIView commitAnimations];
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    //[kSideMenu panGestureRecognized:sender];
    if([sender translationInView:sender.view].x > 25){
        [self pressedBack:nil];
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.sectionHeader setNeedsDisplay];
    [self update];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if( self.expandOnShow){
        [self.subtasksController setExpanded:YES animated:YES];
        self.expandOnShow = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([GlobalApp isEvernoteInstalled]){
        self.fireHint = YES;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.subtasksController resign];
    self.fireHint = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}
-(void)setColorsFor:(id)object{
    if([object respondsToSelector:@selector(setTextColor:)])
        [object setTextColor:tcolor(TextColor)];
    //if([object respondsToSelector:@selector(setHighlightedTextColor:)]) [object setHighlightedTextColor:EDIT_TASK_GRAYED_OUT_TEXT];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)dealloc
{
    self.timePicker = nil;
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
    self.scheduleImageIcon = nil;
    self.repeatedContainer = nil;
    self.repeatedLabel = nil;
    
    self.subtaskOverlay = nil;
    clearNotify();
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// NEWCODE
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRectSetWidth(self.repeatPicker, self.view.frame.size.width);
    CGRectSetWidth(self.scrollView, self.view.frame.size.width);
    CGRectSetHeight(self.scrollView, self.cell.frame.size.height);
    CGRectSetWidth(self.notesView, self.view.frame.size.width-LABEL_X-10);
    //    [self.view explainSubviews];
}

@end
