//
//  WalkthroughCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#define LABEL_X 0.13125
#define TABLE_WIDTH GLOBAL_WT_TABLE_WIDTH
#define DOT_OUTLINE_SIZE    (GLOBAL_DOT_OUTLINE_SIZE/320)
#define DOT_SIZE            (GLOBAL_DOT_SIZE/320)
#define CELL_HEIGHT         (GLOBAL_CELL_HEIGHT/320)



@interface WalkthroughCell : MCSwipeTableViewCell
@property (nonatomic,strong) UIImageView *helpingImage;
-(void)setActivated:(BOOL)activated animated:(BOOL)animated;
-(void)setDotColor:(UIColor*)color;
-(void)setTitle:(NSString*)title;
@end