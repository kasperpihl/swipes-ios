//
//  KPSegentedViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSegmentedViewController.h"
#import "KPControlHandler.h"
#import "KxMenu.h"
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

#import "SearchTopMenu.h"
#import "SelectionTopMenu.h"

#import "HintHandler.h"
#import "UIView+Utilities.h"

#import "NotificationHandler.h"

#import "UserHandler.h"
#define DEFAULT_SELECTED_INDEX 1
#define ADD_BUTTON_TAG 1337
#define ADD_BUTTON_SIZE 90
#define ADD_BUTTON_MARGIN_BOTTOM 0
#define CONTENT_VIEW_TAG 1000
#define CONTROLS_VIEW_TAG 1001
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

typedef enum {
    TopMenuDefault,
    TopMenuSelect,
    TopMenuFilter,
    TopMenuSearch
} TopMenuState;
@interface KPSegmentedViewController () <AddPanelDelegate,KPControlHandlerDelegate,KPAddTagDelegate,KPTagDelegate,SelectionTopMenuDelegate,SearchTopMenuDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) KPControlHandler *controlHandler;
@property (nonatomic, weak) UIView *presentedPanel;
@property (nonatomic, strong) UIButton *_settingsButton;
@property (nonatomic, strong) UIButton *_accountButton;
@property (nonatomic, assign) BOOL tableIsShrinked;
@property (nonatomic, assign) NSInteger currentSelectedIndex;
@property (nonatomic, strong) UIView *ios7BackgroundView;
@property (nonatomic, assign) BOOL hasAppeared;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) NSArray *selectedItems;
@property (nonatomic) TopMenu *topOverlay;
@property (nonatomic) TopMenuState currentTopMenu;

@end

@implementation KPSegmentedViewController



-(void)receivedLocalNotification:(UILocalNotification *)notification
{
    [[self currentViewController] update];
}

#pragma mark - KPControlViewDelegate
#pragma mark - KPAddTagDelegate
-(void)closeAddPanel:(AddPanelView *)addPanel{
    [BLURRY dismissAnimated:YES];
    if(!kUserHandler.isLoggedIn){
        [kHints triggerHint:HintAccount];
    }
}
-(void)closeTagPanel:(KPAddTagPanel *)tagPanel{
    [[self currentViewController] update];
}

-(void)tagPanel:(KPAddTagPanel *)tagPanel createdTag:(NSString *)tag{
    [KPTag addTagWithString:tag save:YES];
}

#pragma mark - KPTagDelegate
-(NSArray *)selectedTagsForTagList:(KPTagList *)tagList{
    NSArray *selectedTags = [KPToDo selectedTagsForToDos:self.selectedItems];
    return selectedTags;
}
-(NSArray *)tagsForTagList:(KPTagList *)tagList{
    NSArray *allTags = [KPTag allTagsAsStrings];
    return allTags;
}
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    [KPToDo updateTags:@[tag] forToDos:self.selectedItems remove:NO save:YES];
    [[self currentViewController] didUpdateItemHandler:nil];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [KPToDo updateTags:@[tag] forToDos:self.selectedItems remove:YES save:YES];
    [[self currentViewController] didUpdateItemHandler:nil];
}
-(void)tagList:(KPTagList *)tagList deletedTag:(NSString *)tag{
    [[self currentViewController].itemHandler deselectTag:tag];
    [KPTag deleteTagWithString:tag save:YES];
    [[self currentViewController] didUpdateItemHandler:nil];
}
#pragma mark - KPControlHandlerDelegate
-(void)pressedAdd:(id)sender{
    [self changeToIndex:1];
    //[[self currentViewController].itemHandler clearAll];
    
    AddPanelView *addPanel = [[AddPanelView alloc] initWithFrame:self.view.bounds];
    addPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    addPanel.addDelegate = self;
    addPanel.tags = [KPTag allTagsAsStrings];
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
-(void)tagItems:(NSArray *)items inViewController:(UIViewController*)viewController withDismissAction:(voidBlock)block{
    self.selectedItems = items;
    //[self show:NO controlsAnimated:YES];
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:viewController.view.bounds andTags:[KPTag allTagsAsStrings]];
    tagView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    BLURRY.showPosition = PositionBottom;
    BLURRY.blurryTopColor = alpha(tcolor(BackgroundColor), 0.3);
    if(block) BLURRY.dismissAction = ^{
        //self.selectedItems = nil;
        block();
    };
    [BLURRY showView:tagView inViewController:viewController];
}
-(void)deleteNumberOfItems:(NSInteger)numberOfItems inView:(UIViewController*)viewController completion:(SuccessfulBlock)block{
    NSString *endString = (numberOfItems > 1) ? @"tasks" : @"task";
    NSString *titleString = [NSString stringWithFormat:@"Delete %li %@",(long)numberOfItems,endString];
    NSString *thisTheseString = (numberOfItems > 1) ? @"these" : @"this";
    NSString *messageString = [NSString stringWithFormat:@"Are you sure you want to permanently delete %@ %@?",thisTheseString,endString];
    KPAlert *alert = [KPAlert alertWithFrame:viewController.view.bounds title:titleString message:messageString block:^(BOOL succeeded, NSError *error) {
        [BLURRY dismissAnimated:YES];
        block(succeeded,error);
    }];
    BLURRY.blurryTopColor = alpha(tcolor(TextColor),0.2);
    [BLURRY showView:alert inViewController:viewController];
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
#pragma mark - AddPanelDelegate
-(void)didAddItem:(NSString *)item priority:(BOOL)priority tags:(NSArray *)tags{
    [[self currentViewController].itemHandler addItem:item priority:priority tags:tags];
}
-(void)addPanel:(AddPanelView *)addPanel createdTag:(NSString *)tag{
    [KPTag addTagWithString:tag save:YES];
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

    button.titleLabel.font = iconFont(23);
    [button setTitle:textString forState:UIControlStateNormal];
    [button setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [button setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [button setTitleColor:highlightColor forState:UIControlStateSelected];
    [button setTitleColor:highlightColor forState:UIControlStateSelected | UIControlStateHighlighted];
    return button;
}
-(void)timerFired:(NSTimer*)sender{
    NSDictionary *userInfo = [sender userInfo];
    NSInteger index = [[userInfo objectForKey:@"button"] integerValue];
    UIButton *button = [[self.segmentedControl buttonsArray] objectAtIndex:index];
    [button setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
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
-(void)pressedSettings{
    [ROOT_CONTROLLER.drawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)didPressAllInSelectionTopMenu:(SelectionTopMenu *)topMenu{
    BOOL select = [topMenu.allButton.titleLabel.text isEqualToString:@"All"];
    if(select){
        [self.currentViewController selectAllRows];
        [topMenu.allButton setTitle:@"None" forState:UIControlStateNormal];
    }
    else{
        [self.currentViewController deselectAllRows:self];
        [topMenu.allButton setTitle:@"All" forState:UIControlStateNormal];
    }
}
-(void)didPressHelpLabelInSelectionTopMenu:(SelectionTopMenu *)topMenu{
    [UTILITY alertWithTitle:@"Select tasks" andMessage:@"Tap your tasks to select them and swipe them all together."];
}
-(void)didPressCloseInSelectionTopMenu:(SelectionTopMenu *)topMenu{
    self.currentTopMenu = TopMenuDefault;
}



#pragma mark SearchTopMenuDelegate
-(void)searchTopMenu:(SearchTopMenu *)topMenu didSearchForString:(NSString *)searchString{

}
-(void)didClearSearchTopMenu:(SearchTopMenu *)topMenu{
    self.currentTopMenu = TopMenuDefault;
}



-(void)setCurrentTopMenu:(TopMenuState)currentTopMenu{
    [self setCurrentTopMenu:currentTopMenu animated:NO];
}
-(void)setCurrentTopMenu:(TopMenuState)currentTopMenu animated:(BOOL)animated{
    if(currentTopMenu != _currentTopMenu){
        
        // Handling search / cleanup and shift to
        if(_currentTopMenu == TopMenuSelect || currentTopMenu == TopMenuSelect){
            [self.currentViewController setSelectionMode:(currentTopMenu == TopMenuSelect)];
            [self.controlHandler setState:((currentTopMenu == TopMenuSelect) ? KPControlHandlerStateNone : KPControlHandlerStateAdd) animated:YES];
        }
        
        if(currentTopMenu == TopMenuDefault){
            [self present:NO topOverlay:nil animated:animated];
        }
        _currentTopMenu = currentTopMenu;
    }
    
}
-(void)present:(BOOL)present topOverlay:(TopMenu*)overlay animated:(BOOL)animated{
    if(!present && !overlay)
        overlay = self.topOverlay;
    
    voidBlock beforeBlock = ^{
        overlay.alpha = present ? 0 : 1;
        if(present)
            [self.view addSubview:overlay];
    };
    voidBlock animationBlock = ^{
        overlay.alpha = present ? 1 : 0;
    };
    voidBlock completionBlock = ^{
        if(present)
            self.topOverlay = overlay;
        else{
            [self.topOverlay removeFromSuperview];
            self.topOverlay = nil;
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

-(void)pressedSelect:(id)sender{
    SelectionTopMenu *selectionTopMenu = [[SelectionTopMenu alloc] initWithFrame:self.ios7BackgroundView.bounds];
    selectionTopMenu.selectionDelegate = self;
    
    [self present:YES topOverlay:selectionTopMenu animated:YES];
    [self setCurrentTopMenu:TopMenuSelect];
}
-(void)pressedFilter:(id)sender{
    [self setCurrentTopMenu:TopMenuFilter animated:YES];
}
-(void)pressedSearch:(id)sender{
    SearchTopMenu *searchTopMenu = [[SearchTopMenu alloc] initWithFrame:self.ios7BackgroundView.bounds];
    searchTopMenu.searchDelegate = self;
    
    [self setCurrentTopMenu:TopMenuSearch animated:YES];
    [self present:YES topOverlay:searchTopMenu animated:YES];
    
    [searchTopMenu.searchField becomeFirstResponder];
}

-(void)pressedAccount{
    
    KxMenuItem *selectItem = [KxMenuItem menuItem:@"Select" image:nil target:self action:@selector(pressedSelect:)];
    KxMenuItem *filterItem = [KxMenuItem menuItem:@"Filter" image:nil target:self action:@selector(pressedSelect:)];
    KxMenuItem *searchItem = [KxMenuItem menuItem:@"Search" image:nil target:self action:@selector(pressedSearch:)];
    [KxMenu setBackColor:tcolor(TextColor)];
    [self._accountButton setSelected:YES];
    [KxMenu showMenuInView:self.view
                  fromRect:self._accountButton.frame
                 menuItems:@[selectItem,filterItem,searchItem]];
    return;
    [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
    return;
    
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
-(void)setBackgroundMode:(BOOL)backgroundMode{
    if(_backgroundMode != backgroundMode){
        _backgroundMode = backgroundMode;
        [self.controlHandler setLockGradient:backgroundMode];
        [self showBackground:backgroundMode animated:YES];
    }
}
-(void)showBackground:(BOOL)show animated:(BOOL)animated
{
    CGFloat targetAlpha = show ? 1.0f : 0.0f;
    CGFloat duration = show ? 2.5f : 0.25f;
    [UIView animateWithDuration:duration animations:^{
        self.backgroundImage.alpha = targetAlpha;
    } completion:^(BOOL finished) {
        if(finished){
        }
    }];
}

-(void)updatedDailyImage
{
    UIImage *newDailyImage = [[kSettings getDailyImage] rn_boxblurImageWithBlur:0.5f exclusionPath:nil];
    if (self.backgroundImage.alpha == 0) {
        [self.backgroundImage setImage:newDailyImage];
    }
    else{
        [UIView transitionWithView:self.view duration:2.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.backgroundImage setImage:newDailyImage];
        } completion:nil];
    }
}

- (void)updateFromSync:(NSNotification *)notification
{
    
    //NSDictionary *changeEvent = [notification userInfo];
    //NSArray *updatedObjects = [changeEvent objectForKey:@"updated"];
    //NSArray *deletedObjects = [changeEvent objectForKey:@"deleted"];
    [NOTIHANDLER updateLocalNotifications];
    [self.currentViewController update];
}

-(void)changeToIndex:(NSInteger)index{
    [self.segmentedControl setSelectedIndex:index];
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
    self.segmentedControl.userInteractionEnabled = NO;
	[oldViewController willMoveToParentViewController:nil];
	
	ToDoListViewController *newViewController = (ToDoListViewController*)self.viewControllers[selectedIndex];
    newViewController.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(newViewController.tableView.tableHeaderView.bounds));
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


- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
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
        [accountButton addTarget:self action:@selector(pressedAccount) forControlEvents:UIControlEventTouchUpInside];
        accountButton.titleLabel.font = iconFont(20);
        [accountButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        accountButton.transform = CGAffineTransformMakeRotation(radians(90));
        [accountButton setTitle:iconString(@"rightArrow") forState:UIControlStateNormal];
        [accountButton setTitle:iconString(@"rightArrowFull") forState:UIControlStateHighlighted];
        accountButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.ios7BackgroundView addSubview:accountButton];
        self._accountButton = accountButton;
        
        UIButton *settingsButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, TOP_Y, CELL_LABEL_X, SEGMENT_HEIGHT)];
        settingsButton.titleLabel.font = iconFont(23);
        [settingsButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [settingsButton setTitle:iconString(@"settings") forState:UIControlStateNormal];
        [settingsButton setTitle:iconString(@"settingsFull") forState:UIControlStateHighlighted];
        [settingsButton addTarget:self action:@selector(pressedSettings) forControlEvents:UIControlEventTouchUpInside];
        [self.ios7BackgroundView addSubview:settingsButton];
        self._settingsButton = settingsButton;
        [self.view addSubview:self.ios7BackgroundView];
        
        //self.navigationItem.titleView = self.segmentedControl;
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    notify(@"updated daily image", updatedDailyImage);
    notify(@"updated sync",updateFromSync:);
    self.view.backgroundColor = tcolor(BackgroundColor);
    
    /* Daily image background */
    self.backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [self.backgroundImage setImage:[[kSettings getDailyImage] rn_boxblurImageWithBlur:0.5f exclusionPath:nil]];
    self.backgroundImage.alpha = 0;
    UIView *overlay = [[UIView alloc] initWithFrame:self.backgroundImage.bounds];
    overlay.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    overlay.backgroundColor = gray(0,0.2);
    [self.backgroundImage addSubview:overlay];
    [self.view addSubview:self.backgroundImage];
    
    /* Content view for ToDo list view controllers */
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height-TOP_HEIGHT)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    contentView.layer.masksToBounds = YES;
    contentView.tag = CONTENT_VIEW_TAG;
    [self.view addSubview:contentView];
    self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
    
    /* Control handler - Bottom toolbar for add/edit */
    self.controlHandler = [KPControlHandler instanceInView:self.view];
    self.controlHandler.delegate = self;
    
    
    [self.view bringSubviewToFront:self.segmentedControl];
    UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
    self.currentSelectedIndex = DEFAULT_SELECTED_INDEX;
    [self addChildViewController:currentViewController];
    
    currentViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:currentViewController.view];
    [currentViewController didMoveToParentViewController:self];
    [self.view sendSubviewToBack:self.backgroundImage];
    //UIBarButtonItem *filter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pressedFilter:event:)];
    //self.navigationItem.rightBarButtonItem = filter;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self._accountButton.hidden = kUserHandler.isLoggedIn;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)dealloc{
    clearNotify();
}

// NEWCODE
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRectSetCenterX(self.segmentedControl, self.view.frame.size.width / 2);
}

@end
