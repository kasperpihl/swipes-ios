//
//  KPSegentedViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSegmentedViewController.h"
#import "KPControlHandler.h"

#import "AddPanelView.h"
#import "ToDoListViewController.h"
#import "KPToDo.h"
#import "KPTag.h"
#import "UtilityClass.h"
#import "AKSegmentedControl.h"
#import "KPAddTagPanel.h"
#import "KPAlert.h"
#import <QuartzCore/QuartzCore.h>
#import "ThemeHandler.h"
#import "UIColor+Utilities.h"
#import "KPBlurry.h"
#import "PlusAlertView.h"
#import "RootViewController.h"
#import "AnalyticsHandler.h"

#import "UIImage+Blur.h"
#import "SlowHighlightIcon.h"
#import "SettingsHandler.h"

#import "OnboardingTopMenu.h"
#import "SearchTopMenu.h"
#import "SelectionTopMenu.h"
#import "FilterTopMenu.h"

#import "HintHandler.h"
#import "UIView+Utilities.h"
#import "M13BadgeView.h"

#import "AudioHandler.h"
#import "NotificationHandler.h"

#import "UserHandler.h"
#define DEFAULT_SELECTED_INDEX 1
#define ADD_BUTTON_SIZE 90
#define ADD_BUTTON_MARGIN_BOTTOM 0
#define SEGMENT_BORDER_RADIUS 0
#define SEGMENT_BUTTON_WIDTH 52
#define TODAY_EXTRA_INSET 3
#define SEGMENT_BORDER_WIDTH 0
#define SEGMENT_HEIGHT 52
#define TOP_Y 20
#define TOP_HEIGHT (TOP_Y+SEGMENT_HEIGHT)
#define INTERESTED_SEGMENT_RECT CGRectMake(0,TOP_Y,(3*SEGMENT_BUTTON_WIDTH)+(8*SEPERATOR_WIDTH),SEGMENT_HEIGHT)
#define CONTROL_VIEW_X (self.view.frame.size.width/2)-(ADD_BUTTON_SIZE/2)
#define CONTROL_VIEW_Y (self.view.frame.size.height-CONTROL_VIEW_HEIGHT)


@interface KPSegmentedViewController () <AddPanelDelegate,KPControlHandlerDelegate,KPAddTagDelegate,KPTagDelegate,KPTagListDataSource ,SelectionTopMenuDelegate,SearchTopMenuDelegate,FilterTopMenuDelegate,TopMenuDelegate,KPTagListAddDelegate,OnboardingTopMenuDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) KPControlHandler *controlHandler;
@property (nonatomic, strong) UIButton *_settingsButton;
@property (nonatomic, strong) UIButton *_accountButton;
@property (nonatomic, assign) BOOL tableIsShrinked;
@property (nonatomic, assign) NSInteger currentSelectedIndex;
@property (nonatomic, strong) UIView *ios7BackgroundView;
@property (nonatomic, assign) BOOL hasAppeared;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic) M13BadgeView *badgeView;
@property (nonatomic) UIButton *badgeButton;
@property (nonatomic) NSInteger currentBadgeNumber;
@property (nonatomic, strong) NSArray *selectedItems;
@property (nonatomic) TopMenu *topOverlay;
@property (nonatomic) BOOL isEditingTags;
@property (nonatomic) NSMutableArray *hintsToComplete;
@property (nonatomic) NSTimer *hintsTimer;
@end

@implementation KPSegmentedViewController

-(NSMutableArray *)hintsToComplete{
    if(!_hintsToComplete)
        _hintsToComplete = [NSMutableArray array];
    return _hintsToComplete;
}
-(void)receivedLocalNotification:(UILocalNotification *)notification
{
    [[self currentViewController] update];
}


#pragma mark - KPControlViewDelegate
#pragma mark - KPAddTagDelegate
-(void)closeAddPanel:(AddPanelView *)addPanel{
    [BLURRY dismissAnimated:YES];
}
-(void)closeTagPanel:(KPAddTagPanel *)tagPanel{
    [[self currentViewController] update];
}


#pragma mark - KPTagDataSource
-(NSArray *)selectedTagsForTagList:(KPTagList *)tagList{

    NSArray *selectedTags;
    
    if(self.isEditingTags)
        selectedTags = [KPToDo selectedTagsForToDos:self.selectedItems];
    else
        selectedTags = [kFilter.selectedTags copy];
    
    return selectedTags;
}
-(NSArray *)tagsForTagList:(KPTagList *)tagList{
    NSArray *allTags = [[KPTag allTagsAsStrings] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return allTags;
}


#define KPTagDelegate
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    if(self.isEditingTags){
        NSString *fromString = @"Select Tasks";
        if(self.currentTopMenu != TopMenuSelect)
            fromString = @"Edit Task";
        [KPToDo updateTags:@[tag] forToDos:self.selectedItems remove:NO save:YES from:fromString];
        [[self currentViewController] didUpdateItemHandler:nil];
    }
    else{
        [kFilter selectTag:tag];
    }
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    if(self.isEditingTags){
        
        NSString *fromString = @"Select Tasks";
        
        if(self.currentTopMenu != TopMenuSelect)
            fromString = @"Edit Task";
        
        [KPToDo updateTags:@[tag] forToDos:self.selectedItems remove:YES save:YES from:fromString];
        
        [[self currentViewController] didUpdateItemHandler:nil];
    
    }
    else{
        [kFilter deselectTag:tag];
    }
}
-(void)tagList:(KPTagList *)tagList deletedTag:(NSString *)tag{
    NSString *fromString = @"Edit Task";
    if(self.currentTopMenu == TopMenuSelect)
        fromString = @"Select Tasks";
    else if(self.currentTopMenu == TopMenuFilter)
        fromString = @"Filter";
    [KPTag deleteTagWithString:tag save:YES from:fromString];
    [kFilter deselectTag:tag];
    [[self currentViewController] didUpdateItemHandler:nil];
}


#pragma mark - KPControlHandlerDelegate
-(void)pressedAdd:(id)sender{
    self.currentIndex = 1;
    //[[self currentViewController].itemHandler clearAll];
    
    AddPanelView *addPanel = [[AddPanelView alloc] initWithFrame:self.view.bounds];
    addPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    addPanel.addDelegate = self;
    [addPanel setTags:[KPTag allTagsAsStrings] selected:[kFilter.selectedTags copy]];
    
    
    BLURRY.showPosition = PositionBottom;
    BLURRY.blurryTopColor = alpha(tcolorF(TextColor,ThemeDark), 0.3);
    [BLURRY showView:addPanel inViewController:self];
}
-(void)pressedTag:(id)sender{
    [self tagItems:[[self currentViewController] selectedItems] inViewController:self withDismissAction:^{
        //[[self currentViewController] deselectAllRows:self];
    }];
}
-(void)pressedShare:(id)sender{
    [ROOT_CONTROLLER shareTasks:[[self currentViewController] selectedItems]];
}
-(void)pressedDelete:(id)sender{
    NSInteger numberOfTasks = [self currentViewController].selectedItems.count;
    [self deleteNumberOfItems:numberOfTasks inView:self completion:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            ToDoListViewController *viewController = [self currentViewController];
            [viewController deleteSelectedItems:self];
            [self setCurrentState:KPControlCurrentStateAdd];
        }
    }];
}



-(void)tagItems:(NSArray *)items inViewController:(UIViewController*)viewController withDismissAction:(voidBlock)block{
    self.selectedItems = items;
    self.isEditingTags = YES;
    //[self show:NO controlsAnimated:YES];
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:viewController.view.bounds andTags:[KPTag allTagsAsStrings]];
    tagView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tagView.tagView.addTagButton = YES;
    tagView.tagView.addDelegate = self;
    tagView.delegate = self;
    
    tagView.tagView.tagDataSource = self;
    tagView.tagView.tagDelegate = self;
    
    //[tagView.tagView setTags: andSelectedTags:nil];
    BLURRY.showPosition = PositionBottom;
    BLURRY.blurryTopColor = alpha(tcolor(BackgroundColor), 0.3);
    if(block) BLURRY.dismissAction = ^{
        //self.selectedItems = nil;
        self.isEditingTags = NO;
        block();
    };
    
    [BLURRY showView:tagView inViewController:viewController];
}
-(void)deleteNumberOfItems:(NSInteger)numberOfItems inView:(UIViewController*)viewController completion:(SuccessfulBlock)block{
    NSString *endString = (numberOfItems > 1) ? LOCALIZE_STRING(@"tasks") : LOCALIZE_STRING(@"task");
    NSString *titleString = [NSString stringWithFormat:LOCALIZE_STRING(@"Delete %li %@"),(long)numberOfItems,endString];
    NSString *thisTheseString = (numberOfItems > 1) ? LOCALIZE_STRING(@"these") : LOCALIZE_STRING(@"this");
    NSString *messageString = [NSString stringWithFormat:LOCALIZE_STRING(@"Are you sure you want to permanently delete %@ %@?"),thisTheseString,endString];
    
    [UTILITY confirmBoxWithTitle:titleString andMessage:messageString block:^(BOOL succeeded, NSError *error) {
         block(succeeded,error);
    }];
}

#pragma mark - AddPanelDelegate
-(void)didAddItem:(NSString *)item priority:(BOOL)priority tags:(NSArray *)tags{
    [[self currentViewController].itemHandler addItem:item priority:priority tags:tags];
    [kHints triggerHint:HintAddTask];
}
-(void)addPanel:(AddPanelView *)addPanel createdTag:(NSString *)tag{
    [KPTag addTagWithString:tag save:YES from:@"Add Task"];
}

- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
	return _viewControllers;
}
- (AKSegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
        AKSegmentedControl *segmentedControl = [[AKSegmentedControl alloc] initWithFrame:INTERESTED_SEGMENT_RECT];
        CGRectSetCenterX(segmentedControl, self.view.frame.size.width/2);
        [segmentedControl setSelectedIndex: DEFAULT_SELECTED_INDEX];
        [segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
        UIButton *buttonSchedule = [self buttonForSegment:KPSegmentButtonSchedule];
        UIButton *buttonToday = [self buttonForSegment:KPSegmentButtonToday];
        UIButton *buttonDone = [self buttonForSegment:KPSegmentButtonDone];
        
        [segmentedControl setButtonsArray:@[buttonSchedule, buttonToday, buttonDone]];
        _segmentedControl = segmentedControl;
        
	}
	return _segmentedControl;
}
-(UIButton*)buttonForSegment:(KPSegmentButtons)controlButton{
    UIButton *button = [[SlowHighlightIcon alloc] init];
    CGRectSetSize(button, SEGMENT_BUTTON_WIDTH, SEGMENT_HEIGHT);
    button.adjustsImageWhenHighlighted = NO;
    NSString *textString;
    UIColor *highlightColor;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            textString = iconString(@"later");
            highlightColor = tcolor(LaterColor);
            break;
        case KPSegmentButtonToday:
            textString = iconString(@"today");
            highlightColor = tcolor(TasksColor);
            break;
        case KPSegmentButtonDone:
            textString = iconString(@"done");
            highlightColor = tcolor(DoneColor);
            break;
    }

    button.titleLabel.font = iconFont(20);
    if(controlButton == KPSegmentButtonToday)
        button.titleLabel.font = iconFont(22);
    [button setTitle:textString forState:UIControlStateNormal];
    [button setTitleColor:alpha(tcolor(TextColor), 0.8) forState:UIControlStateNormal];
    [button setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [button setTitleColor:highlightColor forState:UIControlStateSelected];
    [button setTitleColor:highlightColor forState:UIControlStateSelected | UIControlStateHighlighted];
    return button;
}
-(void)timerFired:(NSTimer*)sender{
    NSDictionary *userInfo = [sender userInfo];
    NSInteger index = [[userInfo objectForKey:@"button"] integerValue];
    UIButton *button = [[self.segmentedControl buttonsArray] objectAtIndex:index];
    [button setTitleColor:alpha(tcolor(TextColor), 0.8) forState:UIControlStateNormal];
}
-(void)highlightButton:(KPSegmentButtons)controlButton{
    UIColor *highlightColor = tcolor(TasksColor);
    if(controlButton == KPSegmentButtonDone)
        highlightColor = tcolor(DoneColor);
    else if(controlButton == KPSegmentButtonSchedule)
        highlightColor = tcolor(LaterColor);
    
    UIButton *button = [[self.segmentedControl buttonsArray] objectAtIndex:controlButton];
    [button setTitleColor:highlightColor forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:@{@"button": [NSNumber numberWithInteger:controlButton]} repeats:NO];
}
- (id)initWithViewControllers:(NSArray *)viewControllers {
	return [self initWithViewControllers:viewControllers titles:[viewControllers valueForKeyPath:@"@unionOfObjects.title"]];
}
-(void)pressedAccount{
    [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
}
-(void)pressedSettings{
    [ROOT_CONTROLLER.drawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        [ANALYTICS pushView:@"Settings"];
    }];
}



#pragma mark TopMenuDelegate
-(void)topMenu:(TopMenu *)topMenu changedSize:(CGSize)size{
    BOOL bottom = (topMenu.position == TopMenuBottom);
    CGFloat contentHeight = self.view.bounds.size.height - size.height;
    if(bottom)
        contentHeight -= 20;
    CGRectSetSize(self.contentView, self.view.bounds.size.width, contentHeight);
//    CGRect contentFrame = CGRectMake(0, bottom ? 20 : size.height, self.view.bounds.size.width, contentHeight);
    
    //self.currentViewController.view.frame = contentFrame;
  //  self.contentView.frame = contentFrame;
    //if(bottom)
      //  CGRectSetY(topMenu, CGRectGetMaxY(self.contentView.frame));
    
}

#pragma mark AwesomeMenuDelegate
-(void)pressedAwesomeMenuIndex:(NSInteger)index{
    if(index == 0){
        [self pressedSettings];
    }
    if(index == 1){
        [self pressedSearch:self];
    }
    if(index == 2){
        [self pressedFilter:self];
    }
    if(index == 3){
        [self pressedSelect:self];
    }
    if(self.currentTopMenu == TopMenuDefault)
        [self.controlHandler setState:KPControlHandlerStateAdd animated:YES];
}

#pragma mark SelectionTopMenuDelegate
-(void)didPressAllInSelectionTopMenu:(SelectionTopMenu *)topMenu{
    BOOL select = [topMenu.allButton.titleLabel.text isEqualToString:LOCALIZE_STRING(@"All")];
    if(select){
        [kAudio playSoundWithName:@"Succesful action.m4a"];
        [self.currentViewController selectAllRows];
        [topMenu.allButton setTitle:LOCALIZE_STRING(@"None") forState:UIControlStateNormal];
    }
    else{
        [kAudio playSoundWithName:@"New state - scheduled.m4a"];
        [self.currentViewController deselectAllRows:self];
        [topMenu.allButton setTitle:LOCALIZE_STRING(@"All") forState:UIControlStateNormal];
    }
}
-(void)didPressHelpLabelInSelectionTopMenu:(SelectionTopMenu *)topMenu{
    [UTILITY alertWithTitle:LOCALIZE_STRING(@"Select Tasks") andMessage:LOCALIZE_STRING(@"Tap your tasks to select them and swipe them all together.")];
}
-(void)didPressCloseInSelectionTopMenu:(SelectionTopMenu *)topMenu{
    [self setTopMenu:nil state:TopMenuDefault animated:YES];
}
-(void)didPressCloseInOnboardingTopMenu:(OnboardingTopMenu *)topMenu{
    [self setTopMenu:nil state:TopMenuDefault animated:YES];
}


#pragma mark FilterTopMenuDelegate
-(void)didPressFilterTopMenu:(FilterTopMenu *)topMenu{
    [self setTopMenu:nil state:TopMenuDefault animated:YES];
}
-(void)didPressHelpInFilterTopMenu:(FilterTopMenu *)topMenu{
    [UTILITY alertWithTitle:LOCALIZE_STRING(@"Workspaces") andMessage:LOCALIZE_STRING(@"Set your workspace, select tags and stay focused.")];
}
-(void)filterMenu:(FilterTopMenu *)filterMenu selectedTag:(NSString *)tag{
    [kFilter selectTag:tag];
    [ANALYTICS trackEvent:@"Filter Tasks" options:@{@"Number of Tags": @(kFilter.selectedTags.count)}];
}
-(void)filterMenu:(FilterTopMenu *)filterMenu deselectedTag:(NSString *)tag{
    [kFilter deselectTag:tag];
}
-(void)didClearFilterTopMenu:(FilterTopMenu *)topMenu{
    [kFilter clearAll];
    [self setTopMenu:nil state:TopMenuDefault animated:YES];
}
-(void)filterMenu:(FilterTopMenu *)filterMenu updatedPriority:(BOOL)priority{
    kFilter.priorityFilter = priority ? FilterSettingOn : FilterSettingNone;
}
-(void)filterMenu:(FilterTopMenu *)filterMenu updatedNotes:(BOOL)notes{
    kFilter.notesFilter = notes ? FilterSettingOn : FilterSettingNone;
}
-(void)filterMenu:(FilterTopMenu *)filterMenu updatedRecurring:(BOOL)recurring{
    kFilter.recurringFilter = recurring ? FilterSettingOn : FilterSettingNone;
}




#pragma mark KPFilterDelegate
-(void)filterActiveChanged{
    [self updateContentViewState];
}

#pragma mark SearchTopMenuDelegate
-(void)searchTopMenu:(SearchTopMenu *)topMenu didSearchForString:(NSString *)searchString{
    [kFilter searchForString:searchString];
}
-(void)didClearSearchTopMenu:(SearchTopMenu *)topMenu{
    [kFilter searchForString:nil];
    [topMenu.searchField resignFirstResponder];
    //[self setTopMenu:nil state:TopMenuDefault animated:YES];
}
-(void)didCloseSearchFieldTopMenu:(SearchTopMenu *)topMenu{
    [topMenu.searchField resignFirstResponder];
    //[self setTopMenu:nil state:TopMenuDefault animated:YES];
}


-(void)updateContentViewState{
    if(self.currentTopMenu == TopMenuFilter || self.currentTopMenu == TopMenuSearch){
        self.contentView.alpha = (kFilter.isActive) ? 1 : 0.5;
        self.contentView.userInteractionEnabled = (kFilter.isActive);
    }
    else{
        self.contentView.alpha = 1;
        self.contentView.userInteractionEnabled = YES;
    }
}
-(void)setCurrentTopMenu:(TopMenuState)currentTopMenu{
    [self setTopMenu:nil state:currentTopMenu animated:NO];
}
-(void)setCurrentTopMenu:(TopMenuState)currentTopMenu animated:(BOOL)animated{
    [self setTopMenu:nil state:currentTopMenu animated:animated];
}
-(void)setTopMenu:(TopMenu*)overlay state:(TopMenuState)topMenuState animated:(BOOL)animated{
    if(topMenuState != _currentTopMenu){
        if(topMenuState == TopMenuDefault){
            self.controlHandler.bottomPadding = 0;
            [self topMenu:self.topOverlay changedSize:self.ios7BackgroundView.frame.size];
        }
        // Handling search / cleanup and shift to
        if(_currentTopMenu == TopMenuSelect || topMenuState == TopMenuSelect){
            [self.currentViewController setSelectionMode:(topMenuState == TopMenuSelect)];
            [self.controlHandler setState:((topMenuState == TopMenuSelect) ? KPControlHandlerStateNone : KPControlHandlerStateAdd) animated:YES];
        }
        
        
        self.ios7BackgroundView.hidden = (topMenuState != TopMenuDefault);
        
        _currentTopMenu = topMenuState;
        [self updateContentViewState];
    }
    
    BOOL present = (TopMenuDefault != topMenuState);
    if(!present && !overlay)
        overlay = self.topOverlay;
    
    voidBlock beforeBlock = ^{
        if(present){
            if(self.topOverlay){
                [self.topOverlay removeFromSuperview];
            }
            CGRectSetY(overlay, (overlay.position == TopMenuBottom) ? self.view.frame.size.height : -overlay.frame.size.height);
        }
        if(present)
            [self.view addSubview:overlay];
    };
    voidBlock animationBlock = ^{
        //self.ios7BackgroundView.alpha = present ? 0 : 1;
        //self.awesomeMenu.alpha = present ? 0 : 1;
        if(present){
            if(overlay.position == TopMenuBottom)
                CGRectSetY(self.contentView, 20);
            CGRectSetY(overlay, (overlay.position == TopMenuBottom) ? self.view.frame.size.height-overlay.frame.size.height : 0);
        }
        else{
            if(overlay.position == TopMenuBottom)
                CGRectSetY(self.contentView, CGRectGetMaxY(self.ios7BackgroundView.frame));
            CGRectSetY(overlay, (overlay.position == TopMenuBottom) ? self.view.frame.size.height : -overlay.frame.size.height);
        }
    };
    voidBlock completionBlock = ^{
        if(present){
            CGRectSetHeight(self.contentView, self.view.frame.size.height - overlay.frame.size.height - (overlay.position == TopMenuBottom ? 20 : 0));
            self.topOverlay = overlay;
            if(overlay.position == TopMenuBottom)
                self.controlHandler.bottomPadding = overlay.frame.size.height;
        }
        else{
            [self.topOverlay removeFromSuperview];
            self.topOverlay = nil;
            CGRectSetHeight(self.contentView, self.view.frame.size.height - self.ios7BackgroundView.frame.size.height);
        }
        if([overlay isKindOfClass:[OnboardingTopMenu class]]){
            [self completeHints];
        }
    };
    
    if(!animated){
        beforeBlock();
        animationBlock();
        completionBlock();
    }
    else{
        beforeBlock();
        [UIView animateWithDuration:0.3 animations:animationBlock completion:^(BOOL finished) {
            completionBlock();
        }];
    }
}
-(void)completeNextHint{
    if(self.hintsToComplete.count > 0){
        NSArray *currentHints = [kHints getCurrentHints];
        NSNumber *hintNumber = [self.hintsToComplete firstObject];
        NSInteger index = [currentHints indexOfObject:hintNumber];
        if(index != NSNotFound){
            OnboardingTopMenu *topMenu = (OnboardingTopMenu*)self.topOverlay;
            if(topMenu){
                [topMenu setDone:YES animated:YES itemIndex:index];
            }
        }
        [self.hintsToComplete removeObjectAtIndex:0];
    }
    else{
        [self.hintsTimer invalidate];
        self.hintsTimer = nil;
    }
}
-(void)completeHints{
    [self.hintsToComplete sortUsingSelector:@selector(compare:)];
    if(self.hintsToComplete.count > 0){
        self.hintsTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(completeNextHint) userInfo:nil repeats:YES];
    }
}


-(void)pressedAddButtonForTagList:(KPTagList *)tagList{
    NSString *fromString = @"Edit Task";
    if(self.currentTopMenu == TopMenuSelect)
        fromString = @"Select Tasks";
    else if(self.currentTopMenu == TopMenuFilter)
        fromString = @"Filter";
    
    [UTILITY inputAlertWithTitle:LOCALIZE_STRING(@"Add new tag") message:LOCALIZE_STRING(@"Type the name of your tag (ex. work, project or school)") placeholder:LOCALIZE_STRING(@"Add new tag") cancel:[LOCALIZE_STRING(@"cancel") capitalizedString] confirm:[LOCALIZE_STRING(@"add") capitalizedString] block:^(NSString *string, NSError *error) {
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmedString && trimmedString.length > 0){
            [KPTag addTagWithString:trimmedString save:YES from:fromString];
            [tagList addTag:trimmedString selected:YES];
        }
    }];
}



-(void)pressedSelect:(id)sender{
    SelectionTopMenu *selectionTopMenu = [[SelectionTopMenu alloc] initWithFrame:CGRectMake(0, 0, self.ios7BackgroundView.frame.size.width, self.ios7BackgroundView.frame.size.height-16)];
    selectionTopMenu.position = TopMenuBottom;
    selectionTopMenu.selectionDelegate = self;
    
    [self setTopMenu:selectionTopMenu state:TopMenuSelect animated:YES];
}
-(void)pressedFilter:(id)sender{
    FilterTopMenu *filterTopMenu = [[FilterTopMenu alloc] initWithFrame:self.ios7BackgroundView.bounds];
    filterTopMenu.position = TopMenuBottom;
    [filterTopMenu setPriority:(kFilter.priorityFilter == FilterSettingOn) notes:(kFilter.notesFilter == FilterSettingOn) recurring:(kFilter.recurringFilter == FilterSettingOn)];
    filterTopMenu.filterDelegate = self;
    filterTopMenu.tagListView.addDelegate = self;
    filterTopMenu.tagListView.addTagButton = YES;
    filterTopMenu.topMenuDelegate = self;
    filterTopMenu.tagListView.tagDataSource = self;
    
    [self setTopMenu:filterTopMenu state:TopMenuFilter animated:YES];
}
-(void)pressedSearch:(id)sender{
    SearchTopMenu *searchTopMenu = [[SearchTopMenu alloc] initWithFrame:CGRectMake(0, 0, self.ios7BackgroundView.frame.size.width, self.ios7BackgroundView.frame.size.height-16)];
    searchTopMenu.searchDelegate = self;
    searchTopMenu.position = TopMenuBottom;
    searchTopMenu.searchField.text = kFilter.searchString;
    [self setTopMenu:searchTopMenu state:TopMenuSearch animated:NO];
    
    [searchTopMenu.searchField becomeFirstResponder];
}


-(KPControlHandlerState)handlerStateForCurrent:(KPControlCurrentState)state{
    if(state == KPControlCurrentStateAdd){
        if(self.currentTopMenu == TopMenuSelect)
            return KPControlHandlerStateNone;
        return KPControlHandlerStateAdd;
    }
    else return KPControlHandlerStateEdit;
}
-(void)setCurrentState:(KPControlCurrentState)currentState{
    if(currentState != _currentState){
        _currentState = currentState;
    }
    [self.controlHandler setState:[self handlerStateForCurrent:currentState] animated:YES];
}







- (void)updateFromSync:(NSNotification *)notification
{
    
    //NSDictionary *changeEvent = [notification userInfo];
    //NSArray *updatedObjects = [changeEvent objectForKey:@"updated"];
    //NSArray *deletedObjects = [changeEvent objectForKey:@"deleted"];
    [NOTIHANDLER updateLocalNotifications];
    [self.currentViewController update];
}

- (NSUInteger)currentIndex
{
    return self.segmentedControl.selectedIndexes.firstIndex;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    [self.segmentedControl setSelectedIndex:currentIndex];
    [self changeViewControllerAnimated:NO];
}

-(void)changeViewControllerAnimated:(BOOL)animated{
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    NSInteger selectedIndex = [[self.segmentedControl selectedIndexes] firstIndex];
    //CGFloat delta = (self.currentSelectedIndex < selectedIndex) ? width : -width;
	ToDoListViewController *oldViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    
    if(selectedIndex == self.currentSelectedIndex){
        return;
    }
    /*NSString *sound = @"New state - completed.m4a";
    switch (selectedIndex) {
        case 0:
            sound = @"New state - scheduled.m4a";
            break;
        case 1:
            sound = @"New state - current.m4a";
            break;
        case 2:
            break;
    }
    if(animated){
        [kAudio playSoundWithName:sound];
    }*/
    self.segmentedControl.userInteractionEnabled = NO;
	[oldViewController willMoveToParentViewController:nil];
	
	ToDoListViewController *newViewController = (ToDoListViewController*)self.viewControllers[selectedIndex];
    newViewController.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(newViewController.tableView.tableHeaderView.bounds));
    kFilter.delegate = [newViewController itemHandler];
	[self addChildViewController:newViewController];
	newViewController.view.frame = CGRectSetPos(self.contentView.frame, 0, 0);
    oldViewController.view.hidden = YES;
    CGFloat duration = animated ?  0.0f : 0.0;
    [self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:duration
							   options:UIViewAnimationOptionCurveEaseOut
							animations:^(void) {
                                oldViewController.view.frame = CGRectMake(0, 0, width, height);
                                newViewController.view.frame = CGRectMake(0, 0, width, height);
                            }
							completion:^(BOOL finished) {
                                self.segmentedControl.userInteractionEnabled = YES;
                                [newViewController didMoveToParentViewController:self];
                                oldViewController.view.hidden = NO;
                                self.currentSelectedIndex = selectedIndex;
							}];
}
-(ToDoListViewController*)currentViewController{
    ToDoListViewController *currentViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    return currentViewController;
}
- (void)changeViewController:(AKSegmentedControl *)segmentedControl{
    [self changeViewControllerAnimated:YES];
    
}
-(void)setCurrentBadgeNumber:(NSInteger)currentBadgeNumber{
    if(currentBadgeNumber != _currentBadgeNumber){
        [self updateBadgeWithNumber:currentBadgeNumber animated:YES];
        _currentBadgeNumber = currentBadgeNumber;
    }
}
-(void)updateBadgeWithNumber:(NSInteger)number animated:(BOOL)animated{
    BOOL isComplete = (number == 0);
    voidBlock beforeBlock = ^{
        self.badgeView.font = isComplete ? iconFont(11) : KP_REGULAR(11);
        if(isComplete){
            
        }
        else{
            self.badgeView.badgeBackgroundColor = tcolor(LaterColor);
        }
    };
    voidBlock showBlock = ^{
        if(!isComplete){
            self.badgeView.text = [NSString stringWithFormat:@"%i",number];
        }
        else{
            self.badgeView.text = @"done";
            self.badgeView.badgeBackgroundColor = tcolor(DoneColor);
        }
    };
    
    beforeBlock();
    if(!animated){
        showBlock();
    }
    else{
        [UIView animateWithDuration:0.7 animations:showBlock];
    }
}
-(void)hintHandlerTriggeredHint:(NSNotification*)notification{
    NSNumber *hintNumber = [notification.userInfo objectForKey:@"Hint"];
    if(hintNumber){
        [self.hintsToComplete addObject:hintNumber];
    }
    NSInteger currentBadgeNumber = [kHints hintLeftForCurrentHints];
    self.currentBadgeNumber = currentBadgeNumber;
    
    if(self.currentTopMenu == TopMenuOnboarding){
        NSArray *currentHints = [kHints getCurrentHints];
        NSInteger index = [currentHints indexOfObject:hintNumber];
        if(index != NSNotFound)
            [self completeNextHint];
    }
}
-(NSString*)titleForHint:(Hints)hint{
    NSString *title;
    switch (hint) {
        case HintWelcomeVideo:
            title = @"Get Started Video";
            break;
        case HintAddTask:
            title = @"Add new a task";
            break;
        case HintCompleted:
            title = @"Complete a task";
            break;
        case HintScheduled:
            title = @"Snooze a task";
            break;
        case HintAllDone:
            title = @"Get All Done for Today";
            break;
        default:
            break;
    }
    return title;
}
-(NSArray *)itemsForTopMenu:(OnboardingTopMenu *)topMenu{
    NSArray *currentHints = [kHints getCurrentHints];
    NSMutableArray *hintStrings = [NSMutableArray array];
    for (NSNumber *hintNumber in currentHints) {
        Hints hint = [hintNumber integerValue];
        NSString *title = [self titleForHint:hint];
        if(title){
            [hintStrings addObject:title];
        }
    }
    return [hintStrings copy];
}
-(void)topMenu:(OnboardingTopMenu *)topMenu didSelectItem:(NSInteger)itemIndex{
    NSArray *currentHints = [kHints getCurrentHints];
    Hints hint = [[currentHints objectAtIndex:itemIndex] integerValue];
    if(hint == HintWelcomeVideo){
        [ROOT_CONTROLLER playVideoWithIdentifier:@"tweOSZdPmO0"];
    }
}
-(BOOL)topMenu:(OnboardingTopMenu *)topMenu hasCompletedItem:(NSInteger)itemIndex{
    NSArray *currentHints = [kHints getCurrentHints];
    Hints hint = [[currentHints objectAtIndex:itemIndex] integerValue];
    if (![self.hintsToComplete containsObject:@(hint)] && [kHints hasCompletedHint:hint]) {
        return YES;
    }
    else return NO;
}
-(void)pressedHelp:(UIButton*)sender{
    //
    OnboardingTopMenu *onboardingTopMenu = [[OnboardingTopMenu alloc] initWithFrame:self.ios7BackgroundView.bounds];
    onboardingTopMenu.position = TopMenuBottom;
    onboardingTopMenu.topMenuDelegate = self;
    onboardingTopMenu.delegate = self;
    [self setTopMenu:onboardingTopMenu state:TopMenuOnboarding animated:YES];
}

- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        _totalViewControllers = viewControllers.count;
        [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
            if ([obj isKindOfClass:[UIViewController class]]) {
                UIViewController *viewController = obj;
                
                [self.viewControllers addObject:viewController];
            }
        }];
        self.view.layer.masksToBounds = YES;
        
        self.ios7BackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, TOP_HEIGHT)];
        self.ios7BackgroundView.backgroundColor = CLEAR;
        [self.ios7BackgroundView addSubview:self.segmentedControl];
        self.ios7BackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIButton *accountButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(self.view.frame.size.width-CELL_LABEL_X, TOP_Y, CELL_LABEL_X, SEGMENT_HEIGHT)];
        accountButton.titleLabel.font = iconFont(23);
        [accountButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [accountButton setTitle:iconString(@"settingsAccount") forState:UIControlStateNormal];
        [accountButton setTitle:iconString(@"settingsAccountFull") forState:UIControlStateHighlighted];
        [accountButton addTarget:self action:@selector(pressedAccount) forControlEvents:UIControlEventTouchUpInside];
        accountButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        CGFloat topSpace = 0;
        CGFloat buttonSize = SEGMENT_HEIGHT-2*topSpace;
        UIButton *helpButton = [[UIButton alloc] initWithFrame:CGRectMake(topSpace, TOP_Y+topSpace, CELL_LABEL_X , buttonSize)];
        [helpButton setTitle:@"" forState:UIControlStateNormal];
        [helpButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        helpButton.titleLabel.font = KP_SEMIBOLD(18);
        helpButton.layer.borderColor = tcolor(TextColor).CGColor;
        //helpButton.layer.borderWidth = 1;
        //helpButton.layer.cornerRadius = buttonSize/2;
        [helpButton addTarget:self action:@selector(pressedHelp:) forControlEvents:UIControlEventTouchUpInside];
        M13BadgeView *badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [helpButton addSubview:badgeView];
        badgeView.font = KP_REGULAR(11);
        badgeView.badgeBackgroundColor = tcolor(LaterColor);//tcolor(TextColor);
        badgeView.animateChanges = YES;
        badgeView.hidden = YES;
        badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentCenter;
        badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentMiddle;
        self.badgeButton = helpButton;
        self.badgeView = badgeView;
        [self.ios7BackgroundView addSubview:helpButton];
        [self.ios7BackgroundView addSubview:accountButton];
        self._accountButton = accountButton;
        [self setCurrentBadgeNumber:[kHints hintLeftForCurrentHints]];
        [self.view addSubview:self.ios7BackgroundView];
        //self.navigationItem.titleView = self.segmentedControl;
    }
    return self;
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    if(self.currentTopMenu != TopMenuDefault)
        return;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSUInteger selected = self.currentIndex;
        if (self.totalViewControllers > selected + 1) {
            self.currentIndex = selected + 1;
        }
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        NSUInteger selected = self.currentIndex;
        if (0 < selected) {
            self.currentIndex = selected - 1;
        }
        // go to settings on the next swipe 
//        else {
//            [ROOT_CONTROLLER.drawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//        }
    }
}



-(void)keyboardWillHide:(NSNotification*)notification{
    if(self.currentTopMenu != TopMenuSearch)
        return;
    [NSTimer scheduledTimerWithTimeInterval:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRectSetY(self.topOverlay, self.view.frame.size.height);
    [UIView commitAnimations];
}
-(void)removeOverlay{
    [self setTopMenu:nil state:TopMenuDefault animated:YES];
}
-(void)keyboardWillShow:(NSNotification*)notification{
    if(self.currentTopMenu != TopMenuSearch)
        return;
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbdHeight = keyboardFrame.size.height;
    if(OSVER == 7){
        kbdHeight = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? keyboardFrame.size.height : keyboardFrame.size.width;
    }
    CGFloat targetHeight = kbdHeight + self.topOverlay.frame.size.height;
    CGFloat currentHeight = self.view.frame.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRectSetY(self.topOverlay, currentHeight-targetHeight);
    CGRectSetHeight(self.contentView, currentHeight-targetHeight-self.contentView.frame.origin.y);
    [UIView commitAnimations];
    
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(self.currentTopMenu != TopMenuDefault)
        [self setTopMenu:nil state:TopMenuDefault animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willRotateToInterfaceOrientation" object:self userInfo:@{@"to":@(toInterfaceOrientation),@"duration":@(duration)}];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updated daily image", updatedDailyImage);
    notify(@"updated sync",updateFromSync:);
    notify(@"filter active state changed", filterActiveChanged);
    notify(HH_TriggeredHintListener, hintHandlerTriggeredHint:);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.view.backgroundColor = tcolor(BackgroundColor);
    
    
    
    /* Content view for ToDo list view controllers */
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height-TOP_HEIGHT)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    contentView.layer.masksToBounds = YES;
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    /* Control handler - Bottom toolbar for add/edit */
    self.controlHandler = [KPControlHandler instanceInView:self.view];
    self.controlHandler.delegate = self;
    
    
    
    UISwipeGestureRecognizer* gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:gesture];
    gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:gesture];
    
    /* Add start view controller */
    [self.view bringSubviewToFront:self.segmentedControl];
    UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
    kFilter.delegate = [(ToDoListViewController*)currentViewController itemHandler];
    self.currentSelectedIndex = DEFAULT_SELECTED_INDEX;
    [self addChildViewController:currentViewController];
    
    currentViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:currentViewController.view];
    [currentViewController didMoveToParentViewController:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self._accountButton.hidden = kUserHandler.isLoggedIn;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.currentTopMenu != TopMenuDefault)
        [self setTopMenu:nil state:TopMenuDefault animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)dealloc{
    clearNotify();
    self.contentView = nil;
    self.ios7BackgroundView = nil;
    self.topOverlay = nil;
    self.segmentedControl = nil;
}

// NEWCODE
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRectSetCenterX(self.segmentedControl, self.view.frame.size.width / 2);
}

@end
