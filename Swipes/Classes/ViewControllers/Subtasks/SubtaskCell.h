//
//  SubtaskCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#define kSubDotSize 10
#define kDotMultiplier 1.5
#define kAddSize (kSubDotSize*kDotMultiplier)
#define kLineSize 1.5


/* The white space from the dot and out on subtasks */
#define kSubOutlineSpacing 4
/* The length to cut the line at the top and bottom of each cell */
#define kSubTopHack 3

#define kLineAlpha 0.35

#import "MCSwipeTableViewCell.h"
@class SubtaskCell;
@protocol SubtaskCellDelegate <NSObject>
- ( void )addedSubtask: (NSString *)subtask;
- ( void )subtaskCell: (SubtaskCell *)cell editedSubtask: (NSString *)subtask;
- ( void )startedEditingSubtaskCell: (SubtaskCell *)cell;
- ( void )startedAddingSubtaskInCell: (SubtaskCell *)cell;
- ( BOOL )shouldStartEditingSubtaskCell:(SubtaskCell *)cell;
- ( void )endedEditingCell: ( SubtaskCell* )cell;
@end
@class KPToDo;
@interface SubtaskCell : MCSwipeTableViewCell
@property (nonatomic,weak) NSObject<SubtaskCellDelegate> *subtaskDelegate;
@property (nonatomic) KPToDo *model;
@property (nonatomic) BOOL addModeForCell;
@property (nonatomic) UIView *seperator;
@property (nonatomic) UITextField *titleField;
@property (nonatomic) BOOL strikeThrough;
@property (nonatomic) NSString *title;

-(void)setDotColor:(UIColor*)color;
@end