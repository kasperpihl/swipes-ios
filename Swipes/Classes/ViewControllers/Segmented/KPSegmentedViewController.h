//
//  KPSegentedViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKSegmentedControl,ToDoListViewController, KPToDo;

@interface KPSegmentedViewController : UIViewController
@property (nonatomic, readonly, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic) KPControlCurrentState currentState;
@property (nonatomic) BOOL lock;
@property (nonatomic) BOOL backgroundMode;
-(void)setLock:(BOOL)lock animated:(BOOL)animated;
- (id)initWithViewControllers:(NSArray *)viewControllers;
-(void)highlightButton:(KPSegmentButtons)controlButton;
-(void)show:(BOOL)show controlsAnimated:(BOOL)animated;
-(void)receivedLocalNotification:(UILocalNotification*)notification;
-(ToDoListViewController*)currentViewController;
-(void)pressedDelete:(id)sender;
-(void)pressedShare:(id)sender;
-(void)changeToIndex:(NSInteger)index;


-(void)tagItems:(NSArray *)items inViewController:(UIViewController*)viewController withDismissAction:(voidBlock)block;
-(void)deleteNumberOfItems:(NSInteger)numberOfItems inView:(UIViewController*)viewController completion:(SuccessfulBlock)block;


@end
