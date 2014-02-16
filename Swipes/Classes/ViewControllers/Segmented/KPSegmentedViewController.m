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
#import "AppDelegate.h"
#import "UIImage+Blur.h"
#import "SlowHighlightIcon.h"
#import "SettingsHandler.h"

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
#define TOP_Y ((OSVER >= 7) ? 20 : 0)
#define TOP_HEIGHT ((OSVER >= 7) ? (TOP_Y+SEGMENT_HEIGHT) : SEGMENT_HEIGHT)
#define INTERESTED_SEGMENT_RECT CGRectMake(0,TOP_Y,(3*SEGMENT_BUTTON_WIDTH)+(8*SEPERATOR_WIDTH),SEGMENT_HEIGHT)
#define CONTROL_VIEW_X (self.view.frame.size.width/2)-(ADD_BUTTON_SIZE/2)
#define CONTROL_VIEW_Y (self.view.frame.size.height-CONTROL_VIEW_HEIGHT)

@interface KPSegmentedViewController () <AddPanelDelegate,KPControlHandlerDelegate,KPAddTagDelegate,KPTagDelegate>
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic,strong) KPControlHandler *controlHandler;
@property (nonatomic,weak) IBOutlet UIView *presentedPanel;
@property (nonatomic) UIButton *_settingsButton;
@property (nonatomic) BOOL tableIsShrinked;
@property (nonatomic) NSInteger currentSelectedIndex;
@property (nonatomic) UIView *ios7BackgroundView;
@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) BOOL hidden;
@property (nonatomic) UIImageView *backgroundImage;
@property (nonatomic) NSArray *selectedItems;

@end

@implementation KPSegmentedViewController
-(void)receivedLocalNotification:(UILocalNotification *)notification{
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
    addPanel.addDelegate = self;
    BLURRY.showPosition = PositionBottom;
    BLURRY.blurryTopColor = alpha(tcolorF(TextColor,ThemeDark), 0.3);
    [BLURRY showView:addPanel inViewController:self];
}
-(void)pressedEdit:(id)sender{
    [[self currentViewController] pressedEdit];
}
-(void)pressedTag:(id)sender{
    [self tagItems:[[self currentViewController] selectedItems] inViewController:self withDismissAction:^{
        [[self currentViewController] deselectAllRows:self];
    }];
}
-(void)pressedShare:(id)sender{
    [ROOT_CONTROLLER shareTasks];
}
-(void)tagItems:(NSArray *)items inViewController:(UIViewController*)viewController withDismissAction:(voidBlock)block{
    self.selectedItems = items;
    //[self show:NO controlsAnimated:YES];
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:viewController.view.bounds andTags:[KPTag allTagsAsStrings]];
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    BLURRY.showPosition = PositionBottom;
    BLURRY.blurryTopColor = alpha(tcolorF(TextColor,ThemeDark), 0.3);
    if(block) BLURRY.dismissAction = ^{
        self.selectedItems = nil;
        block();
    };
    [BLURRY showView:tagView inViewController:viewController];
}
-(void)deleteNumberOfItems:(NSInteger)numberOfItems inView:(UIViewController*)viewController completion:(SuccessfulBlock)block{
    NSString *endString = (numberOfItems > 1) ? @"tasks" : @"task";
    NSString *titleString = [NSString stringWithFormat:@"Delete %i %@",numberOfItems,endString];
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
-(void)didAddItem:(NSString *)item priority:(BOOL)priority{
    [[self currentViewController].itemHandler addItem:item priority:priority];
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
    NSString *imageString;
    NSString *baseString;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            baseString = @"schedule";
            
            break;
        case KPSegmentButtonToday:
            baseString = @"today";
            break;
        case KPSegmentButtonDone:
            baseString = @"done";
            break;
    }
    imageString = timageString(baseString, @"-white", @"-black");
    UIImage *normalImage = [UIImage imageNamed:imageString];
    UIImage *selectedImage = [UIImage imageNamed:[imageString stringByAppendingString:@"-high"]];
    UIImage *highlightedImage = [UIImage imageNamed:[baseString stringByAppendingString:@"-highlighted"]];;
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateSelected];
    [button setImage:highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    button.imageView.animationImages = @[highlightedImage];
    button.imageView.animationDuration = 0.8;    
    return button;
}
-(void)timerFired:(NSTimer*)sender{
    NSDictionary *userInfo = [sender userInfo];
    NSInteger index = [[userInfo objectForKey:@"button"] integerValue];
    UIButton *button = [[self.segmentedControl buttonsArray] objectAtIndex:index];
    [button.imageView stopAnimating];
}
-(void)highlightButton:(KPSegmentButtons)controlButton{
    UIButton *button = [[self.segmentedControl buttonsArray] objectAtIndex:controlButton];
    [button.imageView startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:@{@"button": [NSNumber numberWithInteger:controlButton]} repeats:NO];
}
- (id)initWithViewControllers:(NSArray *)viewControllers {
	return [self initWithViewControllers:viewControllers titles:[viewControllers valueForKeyPath:@"@unionOfObjects.title"]];
}
-(void)pressedSettings{
    [ROOT_CONTROLLER.sideMenu showForce:YES];
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
        
        self.ios7BackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, TOP_HEIGHT)];
        self.ios7BackgroundView.backgroundColor = CLEAR;
        [self.ios7BackgroundView addSubview:self.segmentedControl];
        UIButton *settingsButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, TOP_Y, CELL_LABEL_X, SEGMENT_HEIGHT)];
        //CGRectSetX(settingsButton, -settingsButton.frame.size.width/2);
        [settingsButton setImage:[UIImage imageNamed:timageStringBW(@"settings_icon")] forState:UIControlStateNormal];
        [settingsButton setImage:[UIImage imageNamed:timageString(@"settings_icon",@"_white-high",@"_black-high")] forState:UIControlStateHighlighted];
        [settingsButton addTarget:self action:@selector(pressedSettings) forControlEvents:UIControlEventTouchUpInside];
        [self.ios7BackgroundView addSubview:settingsButton];
        self._settingsButton = settingsButton;
        [self.view addSubview:self.ios7BackgroundView];
        
        //self.navigationItem.titleView = self.segmentedControl;
	}
	return self;
}
-(KPControlHandlerState)handlerStateForCurrent:(KPControlCurrentState)state{
    if(state == KPControlCurrentStateAdd) return KPControlHandlerStateAdd;
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
-(void)showBackground:(BOOL)show animated:(BOOL)animated{
    CGFloat targetAlpha = show ? 1.0f : 0.0f;
    CGFloat duration = show ? 2.5f : 0.25f;
    [UIView animateWithDuration:duration animations:^{
        self.backgroundImage.alpha = targetAlpha;
    } completion:^(BOOL finished) {
        if(finished){
        }
    }];
}
-(void)updatedDailyImage{
    UIImage *newDailyImage = [[kSettings getDailyImage] rn_boxblurImageWithBlur:0.5f exclusionPath:nil];
    if(self.backgroundImage.alpha == 0) [self.backgroundImage setImage:newDailyImage];
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
-(void)viewDidLoad{
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
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_HEIGHT, 320, self.view.bounds.size.height-TOP_HEIGHT)];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
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
    notify(@"changed theme", changedTheme);
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
-(void)changedTheme{
    
}
-(ToDoListViewController*)currentViewController{
    ToDoListViewController *currentViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    return currentViewController;
}
- (void)changeViewController:(AKSegmentedControl *)segmentedControl{
    [self changeViewControllerAnimated:YES];
}
-(void)dealloc{
    clearNotify();
}
@end
