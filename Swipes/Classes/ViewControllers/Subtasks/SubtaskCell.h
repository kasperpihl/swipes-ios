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
- ( void )addedSubtask: (NSString *)subtask;
- ( void )subtaskCell: (SubtaskCell *)cell editedSubtask: (NSString *)subtask;
- ( void )startedEditingSubtaskCell: (SubtaskCell *)cell;
- ( void )startedAddingSubtaskInCell: (SubtaskCell *)cell;
@end
@class KPToDo;
@interface SubtaskCell : MCSwipeTableViewCell
@property (nonatomic,weak) NSObject<SubtaskCellDelegate> *subtaskDelegate;
@property (nonatomic) KPToDo *model;
@property (nonatomic) BOOL addModeForCell;
@property (nonatomic) UITextField *titleField;
@property (nonatomic) BOOL strikeThrough;
@property (nonatomic) NSString *title;

-(void)setDotColor:(UIColor*)color;
@end