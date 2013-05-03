//
//  ToDoCell.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 19/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#define CELL_HEIGHT 65
@class KPToDo;
@interface ToDoCell : MCSwipeTableViewCell
@property (nonatomic) CellType cellType;
-(void)changeToDo:(KPToDo *)toDo withSelectedTags:(NSArray*)selectedTags;
@end
