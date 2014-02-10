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
#define kDefTopPadding 1
#define kDefBottomPadding 3
#import "SectionHeaderView.h"

/*  */
@interface _SectionHeaderViewText : UIView
-(id)initWithColor:(UIColor *)color font:(UIFont*)font title:(NSString*)title;
-(void)setText:(NSString*)text;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) UIColor *color;
@property (nonatomic) UIColor *fillColor;

@end


@interface SectionHeaderView ()

@property (nonatomic) _SectionHeaderViewText *sectionHeader;
@end
@implementation SectionHeaderView
-(id)initWithColor:(UIColor *)color font:(UIFont *)font title:(NSString *)title{
    self = [super init];
    if (self) {
        CGRectSetSize(self, 320, LINE_SIZE);
        self.backgroundColor = color;
        self.sectionHeader = [[_SectionHeaderViewText alloc] initWithColor:color font:font title:title];
        CGRectSetX(self.sectionHeader, CGRectGetWidth(self.frame) - CGRectGetWidth(self.sectionHeader.frame));
        [self addSubview:self.sectionHeader];
        self.color = color;
        
    }
    return self;
}

-(void)setColor:(UIColor *)color{
    self.backgroundColor = color;
    self.sectionHeader.color = color;
    [self.sectionHeader setNeedsDisplay];
}
-(void)setFillColor:(UIColor *)fillColor{
    self.sectionHeader.fillColor = fillColor;
    [self.sectionHeader setNeedsDisplay];
}
-(void)setFont:(UIFont *)font{
    self.sectionHeader.titleLabel.font = font;
    [self.sectionHeader setNeedsDisplay];
}
-(void)setTextColor:(UIColor *)textColor{
    self.sectionHeader.titleLabel.textColor = textColor;
}
-(void)setTitle:(NSString *)title{
    [self.sectionHeader setText:title];
    [self.sectionHeader setNeedsDisplay];
}
@end

@implementation _SectionHeaderViewText
-(id)initWithColor:(UIColor *)color font:(UIFont*)font title:(NSString*)title{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.color = color;
        self.backgroundColor = CLEAR;
        self.fillColor = tcolor(BackgroundColor);
        
        
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        titleLabel.font = font;
        titleLabel.textColor = tcolor(TextColor);
        
        titleLabel.backgroundColor = CLEAR;
        
        self.titleLabel = titleLabel;
        [self addSubview:self.titleLabel];
        if(title) [self setText:title];
    }
    return self;
}
-(void)setText:(NSString*)text{
    self.titleLabel.text = text;
    [self.titleLabel sizeToFit];
    CGSize textSize = sizeWithFont(text, self.titleLabel.font);
    CGFloat actualHeight = textSize.height+kDefTopPadding+kDefBottomPadding;
    CGFloat leftPadding = (actualHeight*kDefLeftCutSize) + kDefLeftPadding;
    CGFloat actualWidth = textSize.width + leftPadding + kDefRightPadding;
    self.titleLabel.frame = CGRectSetPos(self.titleLabel.frame,leftPadding , kDefTopPadding);
    CGRectSetSize(self, ceilf(actualWidth), ceilf(actualHeight));
    CGRectSetX(self, 320-self.frame.size.width);
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
    UIColor *fillColor = self.fillColor;
    CGContextSetFillColorWithColor(currentContext,fillColor.CGColor);
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
