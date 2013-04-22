//
//  KPSegentedViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, KPSegmentedViewControllerControlPosition) {
	KPSegmentedViewControllerControlPositionNavigationBar,
	KPSegmentedViewControllerControlPositionToolbar
};

@interface KPSegmentedViewController : UIViewController

@property (nonatomic, readonly, strong) UISegmentedControl *segmentedControl;
@property (nonatomic) KPSegmentedViewControllerControlPosition position;

// NSArray of UIViewController subclasses
- (id)initWithViewControllers:(NSArray *)viewControllers;

// Takes segmented control item titles separately from the view controllers
- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated;
@end
