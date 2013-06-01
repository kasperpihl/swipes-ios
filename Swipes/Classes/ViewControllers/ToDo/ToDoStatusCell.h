//
//  ToDoStatusCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define STATUS_CELL_HEIGHT 60

#import "MCSwipeTableViewCell.h"

@interface ToDoStatusCell : MCSwipeTableViewCell
@property (nonatomic) CellType cellType;
-(void)setTitleString:(NSString*)titleString;
@end
