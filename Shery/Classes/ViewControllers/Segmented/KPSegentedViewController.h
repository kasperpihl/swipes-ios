//
//  KPSegentedViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SBSegmentedViewControllerControlPosition) {
	SBSegmentedViewControllerControlPositionNavigationBar,
	SBSegmentedViewControllerControlPositionToolbar
};

@interface KPSegentedViewController : UIViewController

@property (nonatomic, readonly, strong) UISegmentedControl *segmentedControl;
@property (nonatomic) SBSegmentedViewControllerControlPosition position;

// NSArray of UIViewController subclasses
- (id)initWithViewControllers:(NSArray *)viewControllers;

// Takes segmented control item titles separately from the view controllers
- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

@end
