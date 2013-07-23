//
//  RNGridMenu.h
//  RNGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPBlurry;


@protocol RNGridMenuDelegate <NSObject>
@optional
- (void)gridMenuWillDismiss:(KPBlurry *)gridMenu;
@end


@interface KPBlurry : UIViewController

+ (instancetype)visibleGridMenu;
@property (nonatomic, readonly) UIView *menuView;


// An optional delegate to receive information about what items were selected
@property (nonatomic, weak) id<RNGridMenuDelegate> delegate;

// The level of blur for the background image. Range is 0.0 to 1.0
// default 0.3
@property (nonatomic, assign) CGFloat blurLevel;
// defaults to nil ( == the whole background gets blurred)
@property (nonatomic, strong) UIBezierPath *blurExclusionPath;

// The time in seconds for the show and dismiss animation
// default 0.25f
@property (nonatomic, assign) CGFloat animationDuration;

// An optional block that gets executed before the gridMenu gets dismissed
@property (nonatomic, copy) dispatch_block_t dismissAction;

// Determine whether or not to bounce in the animation
// default YES
@property (nonatomic, assign) BOOL bounces;

// Initialize the menu with a list of menu items.
// Note: this changes the view to style RNGridMenuStyleList if no images are supplied
- (instancetype)initWithView:(UIView*)modalView;

// Show the menu
- (void)showInViewController:(UIViewController *)parentViewController center:(CGPoint)center;

// Dismiss the menu
// This is called when the window is tapped. If tapped inside the view an item will be selected.
// If tapped outside the view, the menu is simply dismissed.
- (void)dismissAnimated:(BOOL)animated;

@end
