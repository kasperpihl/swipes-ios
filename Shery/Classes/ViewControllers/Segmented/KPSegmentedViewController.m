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
#import "ToDoListTableViewController.h"
#import "KPToDo.h"
#define DEFAULT_SELECTED_INDEX 0
#define ADD_BUTTON_TAG 1337
#define ADD_BUTTON_SIZE 90
#define ADD_BUTTON_MARGIN_BOTTOM 0
#define CONTENT_VIEW_TAG 1000
#define CONTROLS_VIEW_TAG 1001
#define CONTROL_VIEW_X (self.view.frame.size.width/2)-(ADD_BUTTON_SIZE/2)
#define CONTROL_VIEW_Y (self.view.frame.size.height-CONTROL_VIEW_HEIGHT)

@interface KPSegmentedViewController () <AddPanelDelegate,KPControlHandlerDelegate>
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic,strong) KPControlHandler *controlHandler;
@property (nonatomic,strong) AddPanelView *addPanel;

@property (nonatomic) NSInteger currentSelectedIndex;

@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL lock;
@end

@implementation KPSegmentedViewController
-(AddPanelView *)addPanel{
    if(!_addPanel){
        _addPanel = [[AddPanelView alloc] initWithFrame:self.navigationController.view.bounds];
        _addPanel.addDelegate = self;
        [self.navigationController.view addSubview:_addPanel];
    }
    return _addPanel;
}
#pragma mark - KPControlViewDelegate

#pragma mark - AddPanelDelegate
-(void)closedAddPanel:(AddPanelView *)addPanel{
    [self.controlHandler setState:KPControlViewStateAdd animated:YES];
}
-(void)didAddItem:(NSString *)item{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.state = @"today";
    NSNumber *count = [KPToDo MR_numberOfEntities];
    newToDo.order = count;
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updated" object:self];
}
-(void)pressedAdd:(id)sender{
    [self.controlHandler setState:KPControlViewStateNone animated:YES];
    //[panelView.textField becomeFirstResponder];
    [self changeToIndex:1];
    [self.addPanel show:YES];
    //[self.menuViewController.segmentedControl setSelectedSegmentIndex:1];
    
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

- (UISegmentedControl *)segmentedControl {
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:self.titles];
		_segmentedControl.selectedSegmentIndex = DEFAULT_SELECTED_INDEX;
		
		[_segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
	}
	return _segmentedControl;
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
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated{
    if(show) [self.controlHandler setState:KPControlViewStateAdd animated:YES];
    else [self.controlHandler setState:KPControlViewStateNone animated:YES];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (!self.hasAppeared) {
        self.hasAppeared = YES;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        contentView.tag = CONTENT_VIEW_TAG;
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
        self.controlHandler = [KPControlHandler instanceInView:self.view];
        self.controlHandler.delegate = self;
        
        
        UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
        [self addChildViewController:currentViewController];
        
        currentViewController.view.frame = self.view.frame;
        [self.contentView addSubview:currentViewController.view];
        
        [currentViewController didMoveToParentViewController:self];
    }
}

-(void)changeToIndex:(NSInteger)index{
    self.segmentedControl.selectedSegmentIndex = index;
    [self changeViewController:self.segmentedControl];
}
- (void)changeViewController:(UISegmentedControl *)segmentedControl {
    NSLog(@"fired");

    
	CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat delta = (self.currentSelectedIndex < segmentedControl.selectedSegmentIndex) ? width : -width;
	ToDoListTableViewController *oldViewController = (ToDoListTableViewController*)self.viewControllers[self.currentSelectedIndex];
    if(segmentedControl.selectedSegmentIndex == self.currentSelectedIndex){
        [oldViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    segmentedControl.userInteractionEnabled = NO;
	[oldViewController willMoveToParentViewController:nil];
	
	ToDoListTableViewController *newViewController = (ToDoListTableViewController*)self.viewControllers[segmentedControl.selectedSegmentIndex];
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
									
									self.currentSelectedIndex = segmentedControl.selectedSegmentIndex;
								}
							}];
	
}
@end
