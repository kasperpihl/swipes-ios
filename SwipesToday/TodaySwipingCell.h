//
//  TodaySwipeableTableViewCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotView.h"
@class TodaySwipingCell;
@protocol TodayCellDelegate <NSObject>
@optional
-(void)willCompleteCell:(TodaySwipingCell*)cell;
-(void)didCompleteCell:(TodaySwipingCell*)cell;
-(void)didTapCell:(TodaySwipingCell*)cell;
@end
@interface TodaySwipingCell : UITableViewCell
@property (nonatomic,weak) NSObject<TodayCellDelegate> *delegate;
-(void)resetAndSetTaskTitle:(NSString*)title;
@property (nonatomic) DotView *dotView;
@property (nonatomic) UIView *colorIndicatorView;
@end