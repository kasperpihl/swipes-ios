//
//  SectionHeaderExtraView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefLeftCutSize 0.75
#define kDefLeftPadding 4
#define kDefRightPadding 7
#define kDefTopPadding 0
#define kDefBottomPadding 4
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
        self.textColor = tcolor(TextColor);
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
    [super drawRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGFloat leftCutPoint = self.bounds.size.height * kDefLeftCutSize;
    CGFloat targetY = self.bounds.size.height;
    CGFloat targetX = self.bounds.size.width;
    
    /* Color the background */
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(0, 0)];
    [aPath addLineToPoint:CGPointMake(targetX, 0)];
    [aPath addLineToPoint:CGPointMake(targetX, targetY)];
    [aPath addLineToPoint:CGPointMake(leftCutPoint, targetY)];
    [aPath addLineToPoint:CGPointMake(0, 0)];
    [aPath closePath];
    CGContextAddPath(currentContext, aPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,tbackground(BackgroundColor).CGColor);
    CGContextFillPath(currentContext);
    
    /* Draw the colored stroke */
    CGContextSetStrokeColorWithColor(currentContext,self.color.CGColor);
    
    
    CGContextMoveToPoint(currentContext, 0, 0);
    CGContextSetLineWidth(currentContext, LINE_SIZE);
    CGContextAddLineToPoint(currentContext, leftCutPoint, targetY);
    CGContextStrokePath(currentContext);
    
    CGContextMoveToPoint(currentContext, leftCutPoint, targetY);
    //CGContextSetStrokeColorWithColor(currentContext,self.color.CGColor);
    CGContextSetLineWidth(currentContext, LINE_SIZE*2);
    CGContextAddLineToPoint(currentContext, targetX, targetY);
    CGContextStrokePath(currentContext);
}

-(void)dealloc{
    self.titleLabel = nil;
}
@end
