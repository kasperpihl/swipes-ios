//
//  StyleHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSwipeTableViewCell.h"
@interface StyleHandler : NSObject
+(MCSwipeTableViewCellActivatedDirection)directionForCellType:(CellType)type;
+(CellType)cellTypeForCell:(CellType)type state:(MCSwipeTableViewCellState)state;
+(NSString*)stateForCellType:(CellType)type;
+(UIColor*)colorForCellType:(CellType)type;
+(UIColor*)strongColorForCellType:(CellType)type;
+(NSString*)iconNameForCellType:(CellType)type;
@end
