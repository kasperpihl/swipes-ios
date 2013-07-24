//
//  SectionHeaderExtraView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SectionHeaderExtraView.h"
@interface SectionHeaderExtraView ()
@property (nonatomic) UIColor *strongColor;
@end
@implementation SectionHeaderExtraView
-(id)initWithFrame:(CGRect)frame color:(UIColor *)color{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.strongColor = color;
        self.backgroundColor = CLEAR;
        CGRectSetSize(self, 43, 8);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(self.bounds.size.width, 0)];
    // 86 x 16 74
    // Draw the lines.
    CGFloat startingY = 0;
    CGFloat targetY = self.bounds.size.height;
    CGFloat startingX = self.bounds.size.width;
    [aPath addLineToPoint:CGPointMake(startingX, startingY+targetY)];
    [aPath addLineToPoint:CGPointMake(startingX-37, startingY+targetY)];
    [aPath addLineToPoint:CGPointMake(startingX-43, startingY)];
    [aPath addLineToPoint:CGPointMake(startingX, startingY)];
    [aPath closePath];
    CGContextAddPath(currentContext, aPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.strongColor.CGColor);
    CGContextFillPath(currentContext);
}


@end
