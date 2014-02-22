//
//  SubtaskCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
@interface SubtaskCell : MCSwipeTableViewCell
-(void)setTitle:(NSString*)title;
-(void)setAddMode:(BOOL)addMode animated:(BOOL)animated;
@end
