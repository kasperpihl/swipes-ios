//
//  KPSegentedViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKSegmentedControl;
@interface KPSegmentedViewController : UIViewController
@property (nonatomic, readonly, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic) KPControlCurrentState currentState;
// NSArray of UIViewController subclasses
- (id)initWithViewControllers:(NSArray *)viewControllers;
-(void)highlightButton:(KPSegmentButtons)controlButton;
// Takes segmented control item titles separately from the view controllers
- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated;
@end
