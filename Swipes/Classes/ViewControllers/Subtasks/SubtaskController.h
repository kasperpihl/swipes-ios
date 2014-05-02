//
//  SubtaskController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 29/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPToDo.h"
#import "KPReorderTableView.h"
#define kSubtaskHeight 38
@class SubtaskController;
@protocol SubtaskControllerDelegate <NSObject>
@optional
- (void)subtaskController: (SubtaskController *)controller changedToSize: ( CGSize )size;
- (void)subtaskController: (SubtaskController *)controller editingCellWithFrame:( CGRect )frame;
- (void)didChangeSubtaskController:(SubtaskController *)controller;
@end

@interface SubtaskController : NSObject
@property (nonatomic,weak) NSObject<SubtaskControllerDelegate> *delegate;
@property (nonatomic) KPToDo *model;
@property KPReorderTableView *tableView;
@end
