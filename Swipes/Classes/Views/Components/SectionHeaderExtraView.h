//
//  SectionHeaderExtraView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionHeaderExtraView : UIView
-(id)initWithColor:(UIColor *)color font:(UIFont*)font title:(NSString*)title;
@property (nonatomic) UIColor *textColor;
@end
