//
//  UIImage+Utilities.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)
+ (UIImage *)maskedImageNamed:(NSString *)name color:(UIColor *)color
{
	UIImage *image = [UIImage imageNamed:name];
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef c = UIGraphicsGetCurrentContext();
	[image drawInRect:rect];
	CGContextSetFillColorWithColor(c, [color CGColor]);
	CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
	CGContextFillRect(c, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}
@end
