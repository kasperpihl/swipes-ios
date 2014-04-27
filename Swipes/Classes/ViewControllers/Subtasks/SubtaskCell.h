//
//  SubtaskCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
@class SubtaskCell;
@protocol SubtaskCellDelegate <NSObject>
-(void)addedSubtask:(NSString*)subtask;
-(void)subtaskCell:(SubtaskCell*)cell editedSubtask:(NSString*)subtask;
@end
@class KPToDo;
@interface SubtaskCell : MCSwipeTableViewCell
@property (nonatomic,weak) NSObject<SubtaskCellDelegate> *subtaskDelegate;
@property (nonatomic) KPToDo *model;
@property (nonatomic) BOOL addMode;
-(void)setTitle:(NSString*)title;

-(void)setDotColor:(UIColor*)color;
@end