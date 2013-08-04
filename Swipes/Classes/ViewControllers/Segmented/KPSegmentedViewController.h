//
//  KPSegentedViewController.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKSegmentedControl,ToDoListViewController;

@interface KPSegmentedViewController : UIViewController
@property (nonatomic, readonly, strong) AKSegmentedControl *segmentedControl;
@property (nonatomic) KPControlCurrentState currentState;
@property (nonatomic) BOOL lock;
-(void)setLock:(BOOL)lock animated:(BOOL)animated;
- (id)initWithViewControllers:(NSArray *)viewControllers;
-(void)highlightButton:(KPSegmentButtons)controlButton;

-(void)show:(BOOL)show controlsAnimated:(BOOL)animated;
-(void)receivedLocalNotification:(UILocalNotification*)notification;
-(ToDoListViewController*)currentViewController;
-(void)tagViewWithDismissAction:(voidBlock)block;
-(void)pressedDelete:(id)sender;
@end
