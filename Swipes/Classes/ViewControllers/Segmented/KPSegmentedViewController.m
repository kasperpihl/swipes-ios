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
#import "UIViewController+KNSemiModal.h"
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

@interface KPSegmentedViewController () <AddPanelDelegate,KPControlHandlerDelegate,KPPickerViewDataSource,KPAddTagDelegate,KPTagDelegate>
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic,strong) KPControlHandler *controlHandler;
@property (nonatomic,weak) IBOutlet UIView *presentedPanel;

@property (nonatomic) NSInteger currentSelectedIndex;

@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) BOOL hidden;

@end

@implementation KPSegmentedViewController
#pragma mark - KPPickerView
-(NSInteger)numberOfItemsInPickerView:(KPPickerView *)pickerView{
    return 5;
}
-(NSString *)pickerView:(KPPickerView *)pickerView titleForItem:(NSInteger)item{
    return @"No project";
}
#pragma mark - KPControlViewDelegate
#pragma mark - KPAddTagDelegate
-(void)closeAddPanel:(AddPanelView *)addPanel{
    [self dismissSemiModalView];
}
-(void)closeTagPanel:(KPAddTagPanel *)tagPanel{
    [self dismissSemiModalView];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel createdTag:(NSString *)tag{
    [TAGHANDLER addTag:tag];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel changedSize:(CGSize)size{
    NSLog(@"resized");
    [self resizeSemiView:size animated:NO];
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
    [self updateBackground];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    NSArray *selectedItems = [[self currentViewController] selectedItems];
    [TAGHANDLER updateTags:@[tag] remove:YES toDos:selectedItems];
    [[self currentViewController] didUpdateItemHandler:nil];
    [self updateBackground];
}
#pragma mark - AddPanelDelegate
-(void)pressedAdd:(id)sender{
    [self show:NO controlsAnimated:YES];
    [self changeToIndex:1];
    //[[self currentViewController].itemHandler clearAll];
    AddPanelView *addPanel = [[AddPanelView alloc] initWithFrame:self.navigationController.view.bounds];
    addPanel.addDelegate = self;
    self.presentedPanel = addPanel;
    
    CGFloat timerToShow = 0.25f+0.25f*(((addPanel.frame.size.height)-216)/216);
    [self presentSemiView:addPanel withOptions:@{KNSemiModalOptionKeys.animationDuration:[NSNumber numberWithFloat: timerToShow]}];
    [addPanel show:YES];
    /*
    [self.navigationController.view addSubview:addPanel];
    [addPanel show:YES];
    //[panelView.textField becomeFirstResponder];
    [self changeToIndex:1];*/
    //[self.menuViewController.segmentedControl setSelectedSegmentIndex:1];
}
-(void)pressedTag:(id)sender{
    [self show:NO controlsAnimated:YES];
    
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, 450) andTags:[TAGHANDLER allTags] andMaxHeight:320];
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    self.presentedPanel = tagView;
    [self presentSemiView:tagView withOptions:@{KNSemiModalOptionKeys.animationDuration:@0.25f,KNSemiModalOptionKeys.shadowOpacity:@0.0f} completion:^{
        [tagView scrollIfNessecary];
    }];
    //[self.navigationController.view addSubview:tagView];
    //[tagView show:YES];
}
-(void)dismissSemiModalView {
    if(self.presentedPanel.class == [KPAddTagPanel class]){
        KPAddTagPanel *panel = (KPAddTagPanel*)self.presentedPanel;
        if(panel.isShowingKeyboard){
            [panel.textField resignFirstResponder];
            [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(reallyDismiss) userInfo:nil repeats:NO];
        }
        else{
            [self reallyDismiss];
        }
    }
    else if(self.presentedPanel.class == [AddPanelView class]){
        AddPanelView *panel = (AddPanelView*)self.presentedPanel;
        [panel show:NO];
        [self reallyDismiss];
    }
    else [self reallyDismiss];
	/*[self dismissSemiModalViewWithCompletion:^{
        self.currentState = KPControlCurrentStateAdd;
        [[self currentViewController] deselectAllRows:self];
    }];*/
}
-(void)reallyDismiss{
    [self dismissSemiModalViewWithCompletion:^{
        self.currentState = KPControlCurrentStateAdd;
        [[self currentViewController] deselectAllRows:self];
        [[self currentViewController].itemHandler refresh];
        [[self currentViewController] didUpdateCells];
     }];
}
-(void)pressedDelete:(id)sender{
    [KPAlert confirmInView:self.navigationController.view title:@"Delete items" message:@"Are you sure?" block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            ToDoListViewController *viewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
            [viewController deleteSelectedItems:self];
            [self setCurrentState:KPControlCurrentStateAdd];
        }
    }];
}
-(void)didAddItem:(NSString *)item{
    [[self currentViewController].itemHandler addItem:item];
    [self updateBackground];
}
- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
	return _viewControllers;
}

- (NSMutableArray *)titles {
	if (!_titles)
		_titles = [NSMutableArray array];
	return _titles;
}

- (AKSegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
		//_segmentedControl = [[UISegmentedControl alloc] initWithItems:self.titles];
        AKSegmentedControl *segmentedControl = [[AKSegmentedControl alloc] initWithFrame:INTERESTED_SEGMENT_RECT];
        [segmentedControl setBackgroundImage:[UtilityClass imageWithColor:SEGMENT_BORDER_COLOR]];
        [segmentedControl setSelectedIndex: DEFAULT_SELECTED_INDEX];
        segmentedControl.layer.cornerRadius = SEGMENT_BORDER_RADIUS;
        segmentedControl.layer.masksToBounds = YES;
        segmentedControl.layer.borderColor = SEGMENT_BORDER_COLOR.CGColor;
        segmentedControl.layer.borderWidth = SEGMENT_BORDER_WIDTH;
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
    [button setBackgroundImage:[UtilityClass imageWithColor:SEGMENT_BACKGROUND] forState:UIControlStateNormal];
    [button setBackgroundImage:[UtilityClass imageWithColor:SEGMENT_SELECTED] forState:UIControlStateSelected];
    [button setBackgroundImage:[UtilityClass imageWithColor:SEGMENT_SELECTED] forState:UIControlStateHighlighted];
    button.adjustsImageWhenHighlighted = NO;
    UIImage *normalImage;
    CGFloat imageInset = SEGMENT_BORDER_RADIUS-COLOR_SEPERATOR_HEIGHT;
    
    UIColor *thisColor;
    UIImage *highlightedImage;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            thisColor = SCHEDULE_COLOR;
            normalImage = [UIImage imageNamed:@"schedule.png"];
            highlightedImage = [UIImage imageNamed:@"schedule-highlighted"];
            break;
        case KPSegmentButtonToday:
            thisColor = TODAY_COLOR;
            imageInset += TODAY_EXTRA_INSET;
            normalImage = [UIImage imageNamed:@"today"];
            highlightedImage = [UIImage imageNamed:@"today-highlighted"];
            break;
        case KPSegmentButtonDone:
            thisColor = DONE_COLOR;
            normalImage = [UIImage imageNamed:@"done"];
            highlightedImage = [UIImage imageNamed:@"done-highlighted"];
            break;
    }
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-3, button.frame.size.width, 3)];
    
    colorView.backgroundColor = SEGMENT_SELECTED;//thisColor;
    colorView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin);
    [button addSubview:colorView];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, COLOR_SEPERATOR_HEIGHT, 0);
    [button setImage:normalImage forState:UIControlStateNormal];
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
				[self.titles addObject:titles[index]];
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
-(void)setLock:(BOOL)lock{
    if(_lock != lock){
        _lock = lock;
        self.controlHandler.lock = lock;
    }
}
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated{
    if(show){
        [self.controlHandler setState:[self handlerStateForCurrent:self.currentState] animated:YES];
    }
    else{
        [self.controlHandler setState:KPControlHandlerStateNone animated:YES];
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
        //[oldViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    self.segmentedControl.userInteractionEnabled = NO;
	[oldViewController willMoveToParentViewController:nil];
	
	ToDoListViewController *newViewController = (ToDoListViewController*)self.viewControllers[selectedIndex];
    newViewController.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(newViewController.tableView.tableHeaderView.bounds));
	[self addChildViewController:newViewController];
	newViewController.view.frame = CGRectSetPos(self.contentView.frame, delta, 0);
    CGFloat duration = animated ? 0.4 : 0.0;
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
								if (finished) {
									
									[newViewController didMoveToParentViewController:self];
									
									self.currentSelectedIndex = selectedIndex;
								}
							}];
}
-(ToDoListViewController*)currentViewController{
    ToDoListViewController *currentViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    return currentViewController;
}
- (void)changeViewController:(AKSegmentedControl *)segmentedControl{
    [self changeViewControllerAnimated:YES];
    //[self highlightButton:KPSegmentButtonSchedule];
	
	
}
@end
