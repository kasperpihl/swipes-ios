//
//  KPSegentedViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSegmentedViewController.h"

#define DEFAULT_SELECTED_INDEX 0

@interface KPSegmentedViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic) NSInteger currentSelectedIndex;

@property (nonatomic) BOOL hasAppeared;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (!self.hasAppeared) {
        self.hasAppeared = YES;
        UIViewController *currentViewController = self.viewControllers[DEFAULT_SELECTED_INDEX];
        [self addChildViewController:currentViewController];
        
        currentViewController.view.frame = self.view.frame;
        [self.view addSubview:currentViewController.view];
        
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
	CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat delta = (self.currentSelectedIndex < segmentedControl.selectedSegmentIndex) ? width : -width;
	UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
	[oldViewController willMoveToParentViewController:nil];
	
	UIViewController *newViewController = self.viewControllers[segmentedControl.selectedSegmentIndex];
	[self addChildViewController:newViewController];
	newViewController.view.frame = CGRectSetPos(self.view.frame, delta, 0);
	[self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:0.4
							   options:UIViewAnimationOptionTransitionNone
							animations:^(void) {
                                oldViewController.view.frame = CGRectMake(0 - delta, 0, width, height);
                                newViewController.view.frame = CGRectMake(0, 0, width, height);
                            }
							completion:^(BOOL finished) {
								if (finished) {
									
									[newViewController didMoveToParentViewController:self];
									
									self.currentSelectedIndex = segmentedControl.selectedSegmentIndex;
									
									if (self.position == KPSegmentedViewControllerControlPositionToolbar)
										self.title = newViewController.title;
								}
							}];
	
}
@end
