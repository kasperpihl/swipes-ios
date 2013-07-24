//
//  RNGridMenu.h
//  RNGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BLURRY [KPBlurry sharedInstance]
@class KPBlurry;


@protocol KPBlurryDelegate <NSObject>
@optional
-(BOOL)blurryShouldClose:(KPBlurry*)blurry;
-(void)blurryWillShow:(KPBlurry *)blurry;
-(void)blurryDidShow:(KPBlurry *)blurry;
-(void)blurryWillHide:(KPBlurry *)blurry;
-(void)blurryDidHide:(KPBlurry *)blurry;
@end
typedef enum {
    PositionCenter,
    PositionTop,
    PositionBottom
} DisplayPosition;

@interface KPBlurry : UIViewController

+ (instancetype)visibleGridMenu;

+(KPBlurry*)sharedInstance;
// An optional delegate to receive information about what items were selected
@property (nonatomic, weak) id<KPBlurryDelegate> delegate;

// The level of blur for the background image. Range is 0.0 to 1.0
// default 0.3
@property (nonatomic) DisplayPosition showPosition;
@property (nonatomic, assign) CGFloat blurLevel;
// defaults to nil ( == the whole background gets blurred)
@property (nonatomic, strong) UIBezierPath *blurExclusionPath;
@property (nonatomic) UIColor *blurryTopColor;
// The time in seconds for the show and dismiss animation
// default 0.25f
@property (nonatomic, assign) CGFloat animationDuration;

// An optional block that gets executed before the gridMenu gets dismissed
@property (nonatomic, copy) dispatch_block_t dismissAction;


// Show the menu
- (void)showView:(UIView*)view inViewController:(UIViewController *)parentViewController;

// Dismiss the menu
// This is called when the window is tapped. If tapped inside the view an item will be selected.
// If tapped outside the view, the menu is simply dismissed.
- (void)dismissAnimated:(BOOL)animated;

@end
