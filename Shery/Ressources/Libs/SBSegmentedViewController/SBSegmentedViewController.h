//
//  SBSegmentedViewController.h
//  SBSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SBSegmentedViewControllerControlPosition) {
	SBSegmentedViewControllerControlPositionNavigationBar,
	SBSegmentedViewControllerControlPositionToolbar
};

@interface SBSegmentedViewController : UIViewController

@property (nonatomic, readonly, strong) UISegmentedControl *segmentedControl;
@property (nonatomic) SBSegmentedViewControllerControlPosition position;

// NSArray of UIViewController subclasses
- (id)initWithViewControllers:(NSArray *)viewControllers;

// Takes segmented control item titles separately from the view controllers
- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

@end
