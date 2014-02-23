//
//  SubtaskCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
@protocol SubtaskCellDelegate <NSObject>
-(void)addedSubtask:(NSString*)subtask;
@end
@interface SubtaskCell : MCSwipeTableViewCell
@property (nonatomic,weak) NSObject<SubtaskCellDelegate> *subtaskDelegate;
-(void)setTitle:(NSString*)title;
-(void)setAddMode:(BOOL)addMode animated:(BOOL)animated;
-(void)setDotColor:(UIColor*)color;
@end
