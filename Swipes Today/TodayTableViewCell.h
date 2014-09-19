//
//  TodaySwipeableTableViewCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 18/09/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TodayCellDelegate <NSObject>
@end
@interface TodayTableViewCell : UITableViewCell
@property (nonatomic,weak) NSObject<TodayCellDelegate> *delegate;
-(void)resetAndSetTaskTitle:(NSString*)title;
@end