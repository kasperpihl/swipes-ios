//
//  UIColor+Utilities.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)
-(UIColor*)getColorSaturatedWithPercentage:(CGFloat)percentage;
-(UIColor*)getColorBrightenedWithPercentage:(CGFloat)percentage;
@end
