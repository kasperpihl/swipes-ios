//
//  KPSegentedViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSegmentedViewController.h"
#import "RootViewController.h"
#import "KPControlHandler.h"
#import "AddPanelView.h"
#import "ToDoListViewController.h"
#import "ToDoHandler.h"
#import "TagHandler.h"
#import "UtilityClass.h"
#import "AKSegmentedControl.h"
#import "KPAddTagPanel.h"

#import "UIViewController+KNSemiModal.h"
#define DEFAULT_SELECTED_INDEX 1
#define ADD_BUTTON_TAG 1337
#define ADD_BUTTON_SIZE 90
#define ADD_BUTTON_MARGIN_BOTTOM 0
#define CONTENT_VIEW_TAG 1000
#define CONTROLS_VIEW_TAG 1001
#define INTERESTED_SEGMENT_RECT CGRectMake(0,0,148,44)
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
@property (nonatomic) BOOL lock;
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
-(void)tagPanel:(KPAddTagPanel *)tagPanel closedWithSelectedTags:(NSArray *)selectedTags{
    /*NSArray *selectedItems = [[self currentViewController] selectedItems];
    NSArray *currentSelectedTags = [TAGHANDLER selectedTagsForToDos:selectedItems];
    NSMutableArray *removedTags = [NSMutableArray array];

    for(NSString *tag in currentSelectedTags){
        if(![selectedTags containsObject:tag]){
            [removedTags addObject:tag];
        }
    }
    [TAGHANDLER addTags:selectedTags andRemoveTags:removedTags fromToDos:selectedItems];*/
    self.currentState = KPControlCurrentStateAdd;
    [[self currentViewController] deselectAllRows:self];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel createdTag:(NSString *)tag{
    [TAGHANDLER addTag:tag];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel changedSize:(CGSize)size{
    NSLog(@"resized");
    [self resizeSemiView:size];
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
    [TAGHANDLER addTags:@[tag] andRemoveTags:nil fromToDos:selectedItems];
    [[self currentViewController] updateWithoutLoading];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    NSArray *selectedItems = [[self currentViewController] selectedItems];
    [TAGHANDLER addTags:nil andRemoveTags:@[tag] fromToDos:selectedItems];
    [[self currentViewController] updateWithoutLoading];
}
#pragma mark - AddPanelDelegate
-(void)pressedAdd:(id)sender{
    [self show:NO controlsAnimated:YES];
    AddPanelView *addPanel = [[AddPanelView alloc] initWithFrame:self.navigationController.view.bounds];
    addPanel.addDelegate = self;
    self.presentedPanel = addPanel;
    
    CGFloat timerToShow = 0.25f+0.25f*(((addPanel.frame.size.height)-216)/216);
    NSLog(@"timerToShow:%f",timerToShow);
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
    
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, 450) andTags:[TAGHANDLER allTags]];
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    self.presentedPanel = tagView;
    [self presentSemiView:tagView withOptions:@{KNSemiModalOptionKeys.animationDuration:@0.30f}];
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
    else{
        AddPanelView *panel = (AddPanelView*)self.presentedPanel;
        [panel show:NO];
        [self reallyDismiss];
    }
	/*[self dismissSemiModalViewWithCompletion:^{
        self.currentState = KPControlCurrentStateAdd;
        [[self currentViewController] deselectAllRows:self];
    }];*/
}
-(void)reallyDismiss{
    [self dismissSemiModalViewWithCompletion:^{
        self.currentState = KPControlCurrentStateAdd;
        [[self currentViewController] deselectAllRows:self];
     }];
}
-(void)pressedDelete:(id)sender{
    [UTILITY confirmBoxWithTitle:@"Delete items" andMessage:@"Are you sure?" block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            ToDoListViewController *viewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
            [viewController deleteSelectedItems:self];
            [self setCurrentState:KPControlCurrentStateAdd];
        }
    }];
}
-(void)closedAddPanel:(AddPanelView *)addPanel{
    [self show:YES controlsAnimated:YES];
}
-(void)didAddItem:(NSString *)item{
    [TODOHANDLER addItem:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated" object:self];
    [self updateBackground];
}
-(void)didAddTag:(NSString*)tag{
    
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
        UIImage *backgroundImage = [UIImage imageNamed:@"segmented_bg"];
        [segmentedControl setBackgroundImage:backgroundImage];
        [segmentedControl setSelectedIndex: DEFAULT_SELECTED_INDEX];
        [segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        [segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
        [segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
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
    UIImage *normalImage;
    UIImage *selectedImage;
    UIImage *highlightedImage;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            normalImage = [UIImage imageNamed:@"schedule.png"];
            selectedImage = [UIImage imageNamed:@"schedule-selected"];
            highlightedImage = [UIImage imageNamed:@"schedule-highlighted"];
            break;
        case KPSegmentButtonToday:
            normalImage = [UIImage imageNamed:@"today"];
            selectedImage = [UIImage imageNamed:@"today-selected"];
            highlightedImage = [UIImage imageNamed:@"today-highlighted"];
            break;
        case KPSegmentButtonDone:
            normalImage = [UIImage imageNamed:@"done"];
            selectedImage = [UIImage imageNamed:@"done-selected"];
            highlightedImage = [UIImage imageNamed:@"done-highlighted"];
            break;
    }
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button setImage:selectedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [button setImage:normalImage forState:UIControlStateNormal];
    button.imageView.animationDuration = 0.8;
    if(highlightedImage) button.imageView.animationImages = @[highlightedImage];
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
        self.navigationItem.titleView = self.segmentedControl;
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
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (!self.hasAppeared) {
        self.hasAppeared = YES;
        UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        contentView.tag = CONTENT_VIEW_TAG;
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
        self.controlHandler = [KPControlHandler instanceInView:self.view];
        self.controlHandler.delegate = self;
        
        
        UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
        self.currentSelectedIndex = DEFAULT_SELECTED_INDEX;
        [self addChildViewController:currentViewController];
        
        currentViewController.view.frame = self.view.frame;
        [self.contentView addSubview:currentViewController.view];
        [currentViewController didMoveToParentViewController:self];
    }
}
-(void)changeToIndex:(NSInteger)index{
    [self.segmentedControl setSelectedIndex:index];
    [self changeViewController:self.segmentedControl];
}
-(ToDoListViewController*)currentViewController{
    ToDoListViewController *currentViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    return currentViewController;
}
- (void)changeViewController:(AKSegmentedControl *)segmentedControl{
    //[self highlightButton:KPSegmentButtonSchedule];
	CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    NSInteger selectedIndex = [[segmentedControl selectedIndexes] firstIndex];
    CGFloat delta = (self.currentSelectedIndex < selectedIndex) ? width : -width;
	ToDoListViewController *oldViewController = (ToDoListViewController*)self.viewControllers[self.currentSelectedIndex];
    if(selectedIndex == self.currentSelectedIndex){
        [oldViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    segmentedControl.userInteractionEnabled = NO;
	[oldViewController willMoveToParentViewController:nil];
	
	ToDoListViewController *newViewController = (ToDoListViewController*)self.viewControllers[selectedIndex];
    [newViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
	[self addChildViewController:newViewController];
	newViewController.view.frame = CGRectSetPos(self.contentView.frame, delta, 0);
	[self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:0.4
							   options:UIViewAnimationOptionTransitionNone
							animations:^(void) {
                                oldViewController.view.frame = CGRectMake(0 - delta, 0, width, height);
                                newViewController.view.frame = CGRectMake(0, 0, width, height);
                            }
							completion:^(BOOL finished) {
                                segmentedControl.userInteractionEnabled = YES;
								if (finished) {
									
									[newViewController didMoveToParentViewController:self];
									
									self.currentSelectedIndex = selectedIndex;
								}
							}];
	
}
@end
