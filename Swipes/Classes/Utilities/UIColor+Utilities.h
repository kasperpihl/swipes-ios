//
//  UIColor+Utilities.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)
-(UIColor*)saturatedWithPercentage:(CGFloat)percentage;
-(UIColor*)brightenedWithPercentage:(CGFloat)percentage;
-(UIColor *)inverse;
-(UIColor *)darker;
-(UIColor *)lighter;
-(UIImage*)image;
-(UIColor *)colorToColor:(UIColor *)toColor percent:(float)percent;
@end
