//
//  KPSegentedViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSegmentedViewController.h"
#import "RootViewController.h"
#define DEFAULT_SELECTED_INDEX 0
#define ADD_BUTTON_TAG 1337
#define ADD_BUTTON_SIZE 90
#define ADD_BUTTON_MARGIN_BOTTOM 0
#define CONTENT_VIEW_TAG 1000
#define CONTROLS_VIEW_TAG 1001
#define CONTROL_VIEW_X (self.contentView.frame.size.width/2)-(ADD_BUTTON_SIZE/2)
#define CONTROL_VIEW_Y (self.contentView.frame.size.height-ADD_BUTTON_SIZE-ADD_BUTTON_MARGIN_BOTTOM)

@interface KPSegmentedViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) IBOutlet UIView *controlView;

@property (nonatomic) NSInteger currentSelectedIndex;

@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL lock;
@end

@implementation KPSegmentedViewController

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

- (void)setPosition:(KPSegmentedViewControllerControlPosition)position {
	_position = position;
	[self moveControlToPosition:position];
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
	}
	
	return self;
}
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated{
    if(show && self.hidden){
        self.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^
         {
             self.controlView.frame = CGRectSetPos(self.controlView.frame, CONTROL_VIEW_X, CONTROL_VIEW_Y);
             
             /*CGRect naviFrame = self.navigationController.view.frame;
             self.navigationController.navigationBar.frame = CGRectSetPos(self.navigationController.navigationBar.frame, 0, 0);
             */
             
         } completion:^(BOOL finished)
         {
             
         }];
        
    }
    else if(!show && !self.hidden){
        self.hidden = YES;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction  animations:^
         {
             self.controlView.frame = CGRectSetPos(self.controlView.frame, CONTROL_VIEW_X, self.contentView.frame.size.height);
            /* CGRect naviFrame = self.navigationController.view.frame;
             self.navigationController.navigationBar.frame = CGRectSetPos(self.navigationController.navigationBar.frame, 0, -44);
             self.contentView.frame = CGRectSetPos(self.contentView.frame, 0, -44);*/
             
         } completion:^(BOOL finished)
         {
             
         }];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (!self.hasAppeared) {
        self.hasAppeared = YES;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        contentView.tag = CONTENT_VIEW_TAG;
        [self.view addSubview:contentView];
        self.contentView = [self.view viewWithTag:CONTENT_VIEW_TAG];
        
        
        UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(CONTROL_VIEW_X, CONTROL_VIEW_Y,ADD_BUTTON_SIZE,ADD_BUTTON_SIZE+ADD_BUTTON_MARGIN_BOTTOM)];
        controlView.tag = CONTROLS_VIEW_TAG;
        controlView.opaque = NO;
        controlView.userInteractionEnabled = YES;
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(0,0,ADD_BUTTON_SIZE,ADD_BUTTON_SIZE);
        [addButton addTarget:ROOT_CONTROLLER action:@selector(pressedAdd:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:[UIImage imageNamed:@"addbutton"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"addbutton-highlighted"] forState:UIControlStateHighlighted];
        [controlView addSubview:addButton];
        [self.view addSubview:controlView];
        self.controlView = [self.view viewWithTag:CONTROLS_VIEW_TAG];
        UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
        [self addChildViewController:currentViewController];
        
        currentViewController.view.frame = self.view.frame;
        [self.contentView addSubview:currentViewController.view];
        
        [currentViewController didMoveToParentViewController:self];
    }
}

- (void)moveControlToPosition:(KPSegmentedViewControllerControlPosition)newPosition {
	
	switch (newPosition) {
		case KPSegmentedViewControllerControlPositionNavigationBar:
			self.navigationItem.titleView = self.segmentedControl;
			break;
		case KPSegmentedViewControllerControlPositionToolbar: {
			
			UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];
			UIBarButtonItem *control = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
			
			self.toolbarItems = @[flexible, control, flexible];
			
			UIViewController *currentViewController = self.viewControllers[self.currentSelectedIndex];
			self.title = currentViewController.title;
			break;
		}
	}
}

- (void)changeViewController:(UISegmentedControl *)segmentedControl {
    segmentedControl.userInteractionEnabled = NO;
	CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat delta = (self.currentSelectedIndex < segmentedControl.selectedSegmentIndex) ? width : -width;
	UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
	[oldViewController willMoveToParentViewController:nil];
	
	UIViewController *newViewController = self.viewControllers[segmentedControl.selectedSegmentIndex];
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
									
									if (self.position == KPSegmentedViewControllerControlPositionToolbar)
										self.title = newViewController.title;
								}
							}];
	
}
@end
