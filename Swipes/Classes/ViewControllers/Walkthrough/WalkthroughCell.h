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

#define W_TIMELINE              gray(204,1)
#define W_CELL                  gray(230,1)

#define W_TIMELINE_ACTIVATED    gray(128,1)
#define W_CELL_ACTIVATED        gray(153,1)

#define W_TITLE_ACTIVATED       gray(255,1)

@interface WalkthroughCell : MCSwipeTableViewCell
@property (nonatomic,strong) UIImageView *helpingImage;
-(void)setActivated:(BOOL)activated animated:(BOOL)animated;
-(void)setDotColor:(UIColor*)color;

@end