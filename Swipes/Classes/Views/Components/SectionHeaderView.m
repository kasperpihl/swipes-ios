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

#define kDefaultLineSize LINE_SIZE;

#import "SectionHeaderView.h"
#import "UIView+Utilities.h"
#import <QuartzCore/QuartzCore.h>
/*  */

@interface _ProgressEndingView : UIView
@property (nonatomic, weak) SectionHeaderView *headerView;
@end

@interface _SectionHeaderViewText : UIView
-(id)initWithColor:(UIColor *)color font:(UIFont*)font title:(NSString*)title;
-(void)setText:(NSString*)text;
@property (nonatomic, weak) SectionHeaderView *headerView;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) UIColor *color;
@property (nonatomic) UIColor *fillColor;

@end

@interface SectionHeaderView ()

@property (nonatomic) _SectionHeaderViewText *sectionHeader;
@property (nonatomic) _ProgressEndingView *progressEndingView;
@property (nonatomic) UIView *progressView;

@end

@implementation SectionHeaderView

- (id)initWithColor:(UIColor *)color font:(UIFont *)font title:(NSString *)title width:(CGFloat)width {
    self = [super init];
    if (self) {
        self.lineThickness = kDefaultLineSize;
        CGRectSetSize(self, width, self.lineThickness);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = CLEAR;
        self.sectionHeader = [[_SectionHeaderViewText alloc] initWithColor:color font:font title:title];
        CGRectSetX(self.sectionHeader, CGRectGetWidth(self.frame) - CGRectGetWidth(self.sectionHeader.frame));
        self.sectionHeader.headerView = self;
        [self addSubview:self.sectionHeader];
        
        self.color = color;

        self.progressView = [[UIView alloc] initWithFrame:self.bounds];
        self.progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.progressView.backgroundColor = color;
        
        self.progressEndingView = [[_ProgressEndingView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.progressView.frame), 0, 12, self.progressView.frame.size.height)];
        self.progressEndingView.headerView = self;
        self.progressEndingView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin);
        self.progressEndingView.backgroundColor = CLEAR;
        [self.progressView addSubview:self.progressEndingView];
        CGRectSetWidth(self.progressView, 0);
        [self addSubview:self.progressView];
        
//        [self explainSubviews];
        
        self.layer.masksToBounds = NO;
    }
    return self;
}

-(void)setLineThickness:(CGFloat)lineThickness{
    _lineThickness = lineThickness;
    CGRectSetHeight(self, lineThickness);
    [self setNeedsDisplay];
}

-(void)setProgressPercentage:(CGFloat)progressPercentage
{
//    [self explainSubviews];
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat targetX = self.frame.size.width - CGRectGetWidth(self.sectionHeader.frame);
        CGRectSetWidth(self.progressView, targetX * progressPercentage);
    } completion:^(BOOL finished) {
//        [self explainSubviews];
    }];
    
    _progressPercentage = progressPercentage;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    //self.backgroundColor = color;
    self.progressView.backgroundColor = color;
    self.sectionHeader.color = color;
    [self setNeedsDisplay];
}
-(void)setFillColor:(UIColor *)fillColor{
    _fillColor = fillColor;
    self.sectionHeader.fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    self.sectionHeader.titleLabel.font = font;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    self.sectionHeader.titleLabel.textColor = textColor;
}

-(void)setTitle:(NSString *)title
{
    [self.sectionHeader setText:title];
    [self setNeedsDisplay];
}

-(void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.sectionHeader setNeedsDisplay];
    [self.progressEndingView setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRectSetX(self.sectionHeader, CGRectGetWidth(self.frame) - CGRectGetWidth(self.sectionHeader.frame));
    CGFloat targetX = self.frame.size.width - CGRectGetWidth(self.sectionHeader.frame);
    CGRectSetWidth(self.progressView, targetX * _progressPercentage);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGFloat targetX = self.bounds.size.width - CGRectGetWidth(self.sectionHeader.frame);
    
    /* Draw the colored stroke */
    CGContextSetStrokeColorWithColor(currentContext,self.color.CGColor);
    
    
    CGContextMoveToPoint(currentContext, 0, 0);
    CGContextSetLineWidth(currentContext, self.lineThickness * 2);
    CGContextAddLineToPoint(currentContext, targetX, 0);
    CGContextStrokePath(currentContext);
    
    if (self.progress) {
        CGFloat progressY = self.bounds.size.height;
        CGFloat extraCut = progressY * kDefLeftCutSize;
        CGFloat extraX = targetX + extraCut;
        
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:CGPointMake(0, self.lineThickness)];
        [aPath addLineToPoint:CGPointMake(targetX, self.lineThickness)];
        [aPath addLineToPoint:CGPointMake(extraX, progressY)];
        [aPath addLineToPoint:CGPointMake(0, progressY)];
        [aPath closePath];
        CGContextAddPath(currentContext, aPath.CGPath);
        UIColor *fillColor = self.fillColor;
        CGContextSetFillColorWithColor(currentContext,fillColor.CGColor);
        CGContextFillPath(currentContext);
        
        
        
        CGContextSetStrokeColorWithColor(currentContext,self.color.CGColor);
        CGContextMoveToPoint(currentContext, 0, progressY);
        CGContextSetLineWidth(currentContext, self.lineThickness*2);
        CGContextAddLineToPoint(currentContext, extraX, progressY);
        CGContextStrokePath(currentContext);
        
    }
}


@end

@implementation _ProgressEndingView

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGFloat targetY = self.bounds.size.height;
    CGFloat leftCutPoint = self.bounds.size.height * kDefLeftCutSize;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(0, 0)];
    [aPath addLineToPoint:CGPointMake(leftCutPoint, targetY)];
    [aPath addLineToPoint:CGPointMake(0, targetY)];
    [aPath addLineToPoint:CGPointMake(0, 0)];
    [aPath closePath];
    CGContextAddPath(currentContext, aPath.CGPath);
    UIColor *fillColor = self.headerView.color;
    CGContextSetFillColorWithColor(currentContext,fillColor.CGColor);
    CGContextFillPath(currentContext);
    //CGRectSetWidth(self, leftCutPoint);
}

@end

@implementation _SectionHeaderViewText

- (id)initWithColor:(UIColor *)color font:(UIFont*)font title:(NSString*)title {
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

- (void)setText:(NSString*)text {
    self.titleLabel.text = text;
    [self.titleLabel sizeToFit];
    CGSize textSize = sizeWithFont(text, self.titleLabel.font);
    CGFloat actualHeight = textSize.height + kDefTopPadding+kDefBottomPadding;
    CGFloat leftPadding = (actualHeight * kDefLeftCutSize) + kDefLeftPadding;
    CGFloat actualWidth = textSize.width + leftPadding + kDefRightPadding;
    self.titleLabel.frame = CGRectSetPos(self.titleLabel.frame,leftPadding, kDefTopPadding);
    CGRectSetSize(self, ceilf(actualWidth), ceilf(actualHeight));
    CGRectSetX(self, [self superview].bounds.size.width-self.frame.size.width);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGFloat leftCutPoint = self.bounds.size.height * kDefLeftCutSize;
    CGFloat targetY = self.bounds.size.height;
    CGFloat targetX = self.bounds.size.width;
    
    /* Color the background */
    if(self.fillColor){
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
    }
    /* Draw the colored stroke */
    CGContextSetStrokeColorWithColor(currentContext,self.color.CGColor);
    
    
    CGContextMoveToPoint(currentContext, 0, 0);
    CGContextSetLineWidth(currentContext, self.headerView.lineThickness);
    CGContextAddLineToPoint(currentContext, leftCutPoint, targetY);
    CGContextStrokePath(currentContext);
    
    CGContextMoveToPoint(currentContext, leftCutPoint, targetY);
    //CGContextSetStrokeColorWithColor(currentContext,self.color.CGColor);
    CGContextSetLineWidth(currentContext, self.headerView.lineThickness*2);
    CGContextAddLineToPoint(currentContext, targetX, targetY);
    CGContextStrokePath(currentContext);
}

-(void)dealloc{
    self.titleLabel = nil;
}

@end
