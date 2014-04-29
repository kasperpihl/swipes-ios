//
//  SubtasksViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPReorderTableView.h"
@class KPToDo;
#define kDragableHeight 60
@interface SubtasksViewController : UIViewController

@property (nonatomic) UIButton *dragableTop;
@property (nonatomic) UILabel *notification;
@property (nonatomic) KPToDo *model;
@property (nonatomic) BOOL opened;

@property (nonatomic) KPReorderTableView *tableView;
-(void)setContentInset:(UIEdgeInsets)insets;
-(void)startedSliding;
-(void)willStartOpening:(BOOL)opening;
-(void)finishedOpening:(BOOL)opened;
@end
