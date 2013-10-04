//
//  SectionHeaderExtraView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefLeftCutSize 0.75
#define kDefLeftPadding 4
#define kDefRightPadding 6
#define kDefTopPadding 2
#define kDefBottomPadding 1
#import "SectionHeaderView.h"
@interface SectionHeaderView ()
@property (nonatomic) UIColor *color;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@end
@implementation SectionHeaderView
-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.titleLabel.textColor = textColor;
}
-(id)initWithColor:(UIColor *)color font:(UIFont*)font title:(NSString*)title{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.color = color;
        self.backgroundColor = CLEAR;
        self.textColor = [UIColor whiteColor];
        CGSize textSize = sizeWithFont(title, font);
        CGFloat actualHeight = textSize.height+kDefTopPadding+kDefBottomPadding;
        CGFloat leftPadding = (actualHeight*kDefLeftCutSize) + kDefLeftPadding;
        CGFloat actualWidth = textSize.width + leftPadding + kDefRightPadding ;
        
        CGRectSetSize(self, actualWidth, actualHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        titleLabel.font = font;
        titleLabel.textColor = self.textColor;
        titleLabel.text = title;
        [titleLabel sizeToFit];
        titleLabel.backgroundColor = CLEAR;
        titleLabel.frame = CGRectSetPos(titleLabel.frame,leftPadding , kDefTopPadding);
        self.titleLabel = titleLabel;
        [self addSubview:self.titleLabel];
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIBezierPath *aPath = [UIBezierPath bezierPath];
 
    CGFloat leftCutPoint = self.bounds.size.height * kDefLeftCutSize;
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(self.bounds.size.width, 0)];
    // 86 x 16 74
    // Draw the lines.
    CGFloat startingY = 0;
    CGFloat targetY = self.bounds.size.height;
    CGFloat startingX = self.bounds.size.width;
    [aPath addLineToPoint:CGPointMake(startingX, startingY+targetY)];
    [aPath addLineToPoint:CGPointMake(leftCutPoint, startingY+targetY)];
    [aPath addLineToPoint:CGPointMake(0, startingY)];
    [aPath addLineToPoint:CGPointMake(startingX, startingY)];
    [aPath closePath];
    CGContextAddPath(currentContext, aPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.color.CGColor);
    CGContextFillPath(currentContext);
}
-(void)dealloc{
    self.titleLabel = nil;
}
@end
