//
//  ToDoViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToDoViewController;
@class KPSegmentedViewController;
@protocol ToDoVCDelegate <NSObject>
-(void)didPressCloseToDoViewController:(ToDoViewController*)viewController;
-(void)scheduleToDoViewController:(ToDoViewController*)viewController;
@end
@class KPToDo;
@class ToDoCell;
@interface ToDoViewController : UIViewController
@property (nonatomic,weak) NSObject<ToDoVCDelegate> *delegate;
@property (nonatomic,strong) KPToDo *model;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,weak) KPSegmentedViewController *segmentedViewController;
-(void)injectInCell:(UITableViewCell*)cell;
-(void)update;
@end
