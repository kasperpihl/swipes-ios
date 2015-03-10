//
//  OnboardingTableViewCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingTableViewCell : UITableViewCell
@property (nonatomic) BOOL done;
-(void)setNumber:(NSInteger)number text:(NSString*)text;
-(void)setDone:(BOOL)done animated:(BOOL)animated;
@end
