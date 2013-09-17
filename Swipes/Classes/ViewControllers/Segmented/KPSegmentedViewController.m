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
#import "ToDoHandler.h"
#import "TagHandler.h"
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
#define DEFAULT_SELECTED_INDEX 1
#define ADD_BUTTON_TAG 1337
#define ADD_BUTTON_SIZE 90
#define ADD_BUTTON_MARGIN_BOTTOM 0
#define CONTENT_VIEW_TAG 1000
#define CONTROLS_VIEW_TAG 1001
#define SEGMENT_BORDER_RADIUS 0
#define TODAY_EXTRA_INSET 3
#define SEGMENT_BORDER_WIDTH 0
#define SEGMENT_HEIGHT 44
#define INTERESTED_SEGMENT_RECT CGRectMake(0,0,(3*SEGMENT_BUTTON_WIDTH)+(8*SEPERATOR_WIDTH),SEGMENT_HEIGHT)
#define CONTROL_VIEW_X (self.view.frame.size.width/2)-(ADD_BUTTON_SIZE/2)
#define CONTROL_VIEW_Y (self.view.frame.size.height-CONTROL_VIEW_HEIGHT)

@interface KPSegmentedViewController () <AddPanelDelegate,KPControlHandlerDelegate,KPAddTagDelegate,KPTagDelegate>
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic,strong) KPControlHandler *controlHandler;
@property (nonatomic,weak) IBOutlet UIView *presentedPanel;
@property (nonatomic) BOOL tableIsShrinked;
@property (nonatomic) NSInteger currentSelectedIndex;
@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) BOOL hidden;

@end

@implementation KPSegmentedViewController
-(void)receivedLocalNotification:(UILocalNotification *)notification{
    [[self currentViewController] update];
}
#pragma mark - KPControlViewDelegate
#pragma mark - KPAddTagDelegate
-(void)closeAddPanel:(AddPanelView *)addPanel{
    [BLURRY dismissAnimated:YES];
    [self show:YES controlsAnimated:YES];
}
-(void)closeTagPanel:(KPAddTagPanel *)tagPanel{
    [[self currentViewController] update];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel createdTag:(NSString *)tag{
    [TAGHANDLER addTag:tag];
}

#pragma mark - KPTagDelegate
-(NSArray *)selectedTagsForTagList:(KPTagList *)tagList{
    NSArray *selectedItems = [[self currentViewController] selectedItems];
    NSArray *selectedTags = [TAGHANDLER selectedTagsForToDos:selectedItems];
    return selectedTags;
}
-(NSArray *)tagsForTagList:(KPTagList *)tagList{
    NSArray *allTags = [TAGHANDLER allTags];
    return allTags;
}
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    NSArray *selectedItems = [[self currentViewController] selectedItems];
    [TAGHANDLER updateTags:@[tag] remove:NO toDos:selectedItems];
    [[self currentViewController] didUpdateItemHandler:nil];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    NSArray *selectedItems = [[self currentViewController] selectedItems];
    [TAGHANDLER updateTags:@[tag] remove:YES toDos:selectedItems];
    [[self currentViewController] didUpdateItemHandler:nil];
}
-(void)tagList:(KPTagList *)tagList deletedTag:(NSString *)tag{
    [[self currentViewController].itemHandler deselectTag:tag];
    [TAGHANDLER deleteTag:tag];
    [[self currentViewController] didUpdateItemHandler:nil];
}
#pragma mark - KPControlHandlerDelegate
-(void)pressedAdd:(id)sender{
    [self show:NO controlsAnimated:YES];
    [self changeToIndex:1];
    //[[self currentViewController].itemHandler clearAll];
    
    AddPanelView *addPanel = [[AddPanelView alloc] initWithFrame:self.view.bounds];
    addPanel.addDelegate = self;
    BLURRY.showPosition = PositionBottom;
    [BLURRY showView:addPanel inViewController:self];
}
-(void)pressedEdit:(id)sender{
    [[self currentViewController] pressedEdit];
}
-(void)pressedTag:(id)sender{
    [self tagViewWithDismissAction:^{
        [[self currentViewController] deselectAllRows:self];
    }];
}
-(void)pressedShare:(id)sender{
    [ROOT_CONTROLLER shareTasks];
    return;
    [ANALYTICS pushView:@"Sharing plus popup"];
    
    [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Sharing"}];
    PlusAlertView *alert = [PlusAlertView alertWithFrame:self.view.bounds message:@"Sharing tasks is an upcoming feature in Swipes Plus. Check out the package." block:^(BOOL succeeded, NSError *error) {
        [ANALYTICS popView];
        [BLURRY dismissAnimated:YES];
        if(succeeded){
            [ROOT_CONTROLLER upgrade];
        }
    }];
    [BLURRY showView:alert inViewController:self];
}
-(void)tagViewWithDismissAction:(voidBlock)block{
    //[self show:NO controlsAnimated:YES];
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:self.view.bounds andTags:[TAGHANDLER allTags]];
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    BLURRY.showPosition = PositionBottom;
    if(block) BLURRY.dismissAction = block;
    [BLURRY showView:tagView inViewController:self];
}
-(void)pressedDelete:(id)sender{
    NSInteger numberOfTasks = [self currentViewController].selectedItems.count;
    NSString *endString = (numberOfTasks > 1) ? @"tasks" : @"task";
    NSString *titleString = [NSString stringWithFormat:@"Delete %i %@",numberOfTasks,endString];
    KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:titleString message:@"This can't be undone" block:^(BOOL succeeded, NSError *error) {
        [BLURRY dismissAnimated:YES];
        if(succeeded){
            ToDoListViewController *viewController = [self currentViewController];
            [viewController deleteSelectedItems:self];
            [self setCurrentState:KPControlCurrentStateAdd];
        }
    }];
    [BLURRY showView:alert inViewController:self];
}
#pragma mark - AddPanelDelegate
-(void)didAddItem:(NSString *)item{
    [[self currentViewController].itemHandler addItem:item];
}
- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
	return _viewControllers;
}
- (AKSegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
		//_segmentedControl = [[UISegmentedControl alloc] initWithItems:self.titles];
        AKSegmentedControl *segmentedControl = [[AKSegmentedControl alloc] initWithFrame:INTERESTED_SEGMENT_RECT];
        [segmentedControl setBackgroundImage:[tbackground(MenuSelectedBackground) image]];
        [segmentedControl setSelectedIndex: DEFAULT_SELECTED_INDEX];
        segmentedControl.layer.cornerRadius = SEGMENT_BORDER_RADIUS;
        segmentedControl.layer.masksToBounds = NO;
        segmentedControl.layer.shadowOffset = CGSizeMake(0, 0);
        segmentedControl.layer.shadowRadius = 5;
        segmentedControl.layer.shadowOpacity = 0.5;
        segmentedControl.layer.borderColor = tbackground(MenuSelectedBackground).CGColor;
        segmentedControl.layer.borderWidth = SEGMENT_BORDER_WIDTH;
        segmentedControl.layer.shadowPath = [UIBezierPath bezierPathWithRect:segmentedControl.bounds].CGPath;
        [segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
        //[segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
        UIButton *buttonSchedule = [self buttonForSegment:KPSegmentButtonSchedule];
        UIButton *buttonToday = [self buttonForSegment:KPSegmentButtonToday];
        UIButton *buttonDone = [self buttonForSegment:KPSegmentButtonDone];
        
        [segmentedControl setButtonsArray:@[buttonSchedule, buttonToday, buttonDone]];
        _segmentedControl = segmentedControl;
	}
	return _segmentedControl;
}
-(UIButton*)buttonForSegment:(KPSegmentButtons)controlButton{
    UIButton *button = [[UIButton alloc] init];
    CGRectSetSize(button, SEGMENT_BUTTON_WIDTH, SEGMENT_HEIGHT);
    [button setBackgroundImage:[tbackground(MenuBackground) image] forState:UIControlStateNormal];
    [button setBackgroundImage:[tbackground(MenuSelectedBackground) image] forState:UIControlStateSelected];
    [button setBackgroundImage:[tbackground(MenuSelectedBackground) image] forState:UIControlStateHighlighted | UIControlStateSelected];
    //[button setBackgroundImage:[UtilityClass imageWithColor:tbackground(MenuSelectedBackground)] forState:UIControlStateHighlighted];
    button.adjustsImageWhenHighlighted = NO;
    NSString *imageString;
    UIColor *thisColor;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            
            thisColor = tcolor(LaterColor);
            imageString = @"schedule";
            break;
        case KPSegmentButtonToday:
            thisColor = tcolor(TasksColor);
            imageString = @"today";
            break;
        case KPSegmentButtonDone:
            thisColor = tcolor(DoneColor);
            imageString = @"done";
            break;
    }
    UIImage *normalImage = [UIImage imageNamed:imageString];
    UIImage *selectedImage = [UIImage imageNamed:[imageString stringByAppendingString:@"-selected"]];
    UIImage *highlightedImage = [UIImage imageNamed:[imageString stringByAppendingString:@"-highlighted"]];;
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
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
        [self.view addSubview:self.segmentedControl];
        
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
    [self show:YES controlsAnimated:YES];
}
-(void)setLock:(BOOL)lock animated:(BOOL)animated{
    if(_lock != lock){
        _lock = lock;
        [self.controlHandler setLock:lock animated:animated];
    }
}
-(void)setLock:(BOOL)lock{
    [self setLock:lock animated:YES];
}
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated{
    if(show){
        [self.controlHandler setState:[self handlerStateForCurrent:self.currentState] shrinkingView:[self currentViewController].tableView animated:animated];
    }
    else{
        [self.controlHandler setState:KPControlHandlerStateNone shrinkingView:[self currentViewController].tableView animated:animated];
    }
    //[self.navigationController setNavigationBarHidden:!show animated:YES];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    //UIBarButtonItem *filter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pressedFilter:event:)];
    //self.navigationItem.rightBarButtonItem = filter;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (!self.hasAppeared) {
        self.hasAppeared = YES;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SEGMENT_HEIGHT, 320, self.view.bounds.size.height-SEGMENT_HEIGHT)];
        self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        contentView.tag = CONTENT_VIEW_TAG;
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
        self.controlHandler = [KPControlHandler instanceInView:self.view];
        self.controlHandler.delegate = self;
        
        [self.view bringSubviewToFront:self.segmentedControl];
        UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
        self.currentSelectedIndex = DEFAULT_SELECTED_INDEX;
        [self addChildViewController:currentViewController];
        
        currentViewController.view.frame = self.contentView.bounds;
        [self.contentView addSubview:currentViewController.view];
        [currentViewController didMoveToParentViewController:self];
    }
}
-(void)changeToIndex:(NSInteger)index{
    [self.segmentedControl setSelectedIndex:index];
    [self changeViewControllerAnimated:NO];
}
-(void)changeViewControllerAnimated:(BOOL)animated{
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    NSInteger selectedIndex = [[self.segmentedControl selectedIndexes] firstIndex];
    CGFloat delta = (self.currentSelectedIndex < selectedIndex) ? width : -width;
	ToDoListViewController *oldViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    if(selectedIndex == self.currentSelectedIndex){
        return;
    }
    self.segmentedControl.userInteractionEnabled = NO;
	[oldViewController willMoveToParentViewController:nil];
	
	ToDoListViewController *newViewController = (ToDoListViewController*)self.viewControllers[selectedIndex];
    newViewController.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(newViewController.tableView.tableHeaderView.bounds));
	[self addChildViewController:newViewController];
	newViewController.view.frame = CGRectSetPos(self.contentView.frame, delta, 0);
    CGFloat duration = animated ?  0.4 : 0.0;
    [self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:duration
							   options:UIViewAnimationOptionTransitionNone
							animations:^(void) {
                                oldViewController.view.frame = CGRectMake(0 - delta, 0, width, height);
                                newViewController.view.frame = CGRectMake(0, 0, width, height);
                            }
							completion:^(BOOL finished) {
                                self.segmentedControl.userInteractionEnabled = YES;
                                [newViewController didMoveToParentViewController:self];
                                
                                self.currentSelectedIndex = selectedIndex;
							}];
}
-(ToDoListViewController*)currentViewController{
    ToDoListViewController *currentViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    return currentViewController;
}
- (void)changeViewController:(AKSegmentedControl *)segmentedControl{
    self.showingModel = nil;
    UIButton *pressedButton = [[segmentedControl buttonsArray] objectAtIndex:[self.segmentedControl.selectedIndexes firstIndex]];
    
    /*[pressedButton.imageView stopAnimating];
    [pressedButton setHighlighted:NO];
    [pressedButton setSelected:YES];
    */
    [self changeViewControllerAnimated:YES];
    //[self highlightButton:KPSegmentButtonSchedule];
	
	
}
@end
