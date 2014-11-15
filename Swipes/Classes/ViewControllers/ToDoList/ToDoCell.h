//
//  ToDoCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "DotView.h"
#import "MCSwipeTableViewCell.h"
#define CELL_HEIGHT 60
@class KPToDo, ToDoCell;

@protocol ToDoCellDelegate <NSObject>

-(void)pressedActionStepsButtonCell:(ToDoCell*)cell;

@end

@interface ToDoCell : MCSwipeTableViewCell
@property (nonatomic) CellType cellType;

@property (nonatomic, weak) DotView *dotView;
@property (nonatomic, strong) UIButton *actionStepsButton;

@property (nonatomic, weak) NSObject<ToDoCellDelegate> *actionDelegate;
@property (nonatomic) BOOL priority;
-(void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags;
//-(void)showTimeline:(BOOL)show;
-(void)setDotColor:(CellType)cellType;
+(CGFloat)heightWithText:(NSString*)text hasSubtask:(BOOL)hasSubtask;
@end
