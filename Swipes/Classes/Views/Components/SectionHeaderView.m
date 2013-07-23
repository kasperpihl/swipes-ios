//
//  SectionHeaderView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 20/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SectionHeaderView.h"
@interface SectionHeaderView ()
@property (nonatomic) UIColor *color;
@end

@implementation SectionHeaderView
-(id)initWithFrame:(CGRect)frame color:(UIColor*)color{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.color = color;
        self.backgroundColor = CLEAR;
    }
    return self;
}

#define trgb(num) (num/255.0)
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    const CGFloat *components2 = CGColorGetComponents(self.color.CGColor);
    CGFloat red = components2[0];
    CGFloat green = components2[1];
    CGFloat blue = components2[2];
    //CGFloat alpha = components[3];
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 0.85 };
    CGFloat components[8] = { trgb(44), trgb(50), trgb(59), 0.7,  // Start color
        red, green, blue, 0.0 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    // Drawing code
}


@end
