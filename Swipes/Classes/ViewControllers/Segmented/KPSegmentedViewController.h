//
//  KPSegentedViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKSegmentedControl.h"
#import "KPFilter.h"

@class ToDoListViewController, KPToDo;

@interface KPSegmentedViewController : UIViewController
@property (nonatomic, readonly, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic, assign) KPControlCurrentState currentState;
@property (nonatomic, assign) BOOL lock;
@property (nonatomic, assign) BOOL backgroundMode;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) NSUInteger totalViewControllers;

- (id)initWithViewControllers:(NSArray *)viewControllers;
-(void)highlightButton:(KPSegmentButtons)controlButton;
//-(void)show:(BOOL)show controlsAnimated:(BOOL)animated;
-(void)receivedLocalNotification:(UILocalNotification*)notification;
-(ToDoListViewController*)currentViewController;
-(void)pressedDelete:(id)sender;
-(void)pressedShare:(id)sender;
-(void)pressedAdd:(id)sender;

-(void)tagItems:(NSArray *)items inViewController:(UIViewController*)viewController withDismissAction:(voidBlock)block;
-(void)deleteNumberOfItems:(NSInteger)numberOfItems inView:(UIViewController*)viewController completion:(SuccessfulBlock)block;

@end