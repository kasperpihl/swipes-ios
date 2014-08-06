//
//  SubtaskController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 29/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SubtaskCell.h"
#import <Foundation/Foundation.h>
#import "KPToDo.h"
#import "KPReorderTableView.h"
#define kSubtaskHeight 40
@class SubtaskController;
@protocol SubtaskControllerDelegate <NSObject>
@optional
- (void)subtaskController: (SubtaskController *)controller changedToSize: ( CGSize )size;
- (void)subtaskController: (SubtaskController *)controller editingCellWithFrame:( CGRect )frame;
- (void)didChangeSubtaskController:(SubtaskController *)controller;
- (void)subtaskController: (SubtaskController *)controller changedExpanded:(BOOL)expanded;
@end

@interface SubtaskController : NSObject
@property (nonatomic,weak) id<SubtaskControllerDelegate> delegate;
@property (nonatomic) KPToDo *model;
@property (nonatomic) BOOL expanded;
@property KPReorderTableView *tableView;
@property (nonatomic) NSArray *subtasks;

-(void)fullReload;
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated;
-(void)resign;
@end
