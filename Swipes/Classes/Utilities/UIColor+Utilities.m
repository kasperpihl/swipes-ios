//
//  UIColor+Utilities.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)
-(UIColor*)getColorSaturatedWithPercentage:(CGFloat)percentage{
    CGFloat dividor = 1 + percentage;
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s * dividor brightness:b alpha:a];
    return nil;
}
-(UIColor*)getColorBrightenedWithPercentage:(CGFloat)percentage{
    CGFloat dividor = 1 + percentage;
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:b * dividor alpha:a];
    return nil;
}
@end