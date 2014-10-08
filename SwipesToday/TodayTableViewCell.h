//
//  TodaySwipeableTableViewCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TodayTableViewCell;
@protocol TodayCellDelegate <NSObject>
@optional
-(void)willCompleteCell:(TodayTableViewCell*)cell;
-(void)didCompleteCell:(TodayTableViewCell*)cell;
-(void)didTapCell:(TodayTableViewCell*)cell;
@end
@interface TodayTableViewCell : UITableViewCell
@property (nonatomic,weak) NSObject<TodayCellDelegate> *delegate;
-(void)resetAndSetTaskTitle:(NSString*)title;
@property (nonatomic) UIView *colorIndicatorView;
@end