//
//  SectionHeaderExtraView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionHeaderView : UIView

- (id)initWithColor:(UIColor *)color font:(UIFont *)font title:(NSString *)title width:(CGFloat)width;

@property (nonatomic) UIColor *color;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIFont *font;
@property (nonatomic) NSString *title;
@property (nonatomic) CGFloat lineThickness;

@property (nonatomic) BOOL progress;
@property (nonatomic) CGFloat progressPercentage;

@end
