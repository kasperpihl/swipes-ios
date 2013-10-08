//
//  ToDoCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#define CELL_HEIGHT 70
#define CELL_LABEL_X 36
@class KPToDo;
@interface ToDoCell : MCSwipeTableViewCell
@property (nonatomic) CellType cellType;

-(void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags;
-(void)showTimeline:(BOOL)show;
-(void)setDotColor:(CellType)cellType;
-(void)hideContent:(BOOL)hide animated:(BOOL)animated;
@end
