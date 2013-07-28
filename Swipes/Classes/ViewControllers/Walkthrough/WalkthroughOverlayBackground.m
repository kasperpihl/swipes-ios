//
//  WalkthroughOverlayBackground.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 28/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import "WalkthroughOverlayBackground.h"
#import <QuartzCore/QuartzCore.h>
@interface WalkthroughOverlayBackground ()
@property (nonatomic) UIBezierPath *punchedOutPath;
@property (nonatomic) CGFloat height;
@property (nonatomic,strong) UIView *popupView;
@end
@implementation WalkthroughOverlayBackground
-(void)setLeft:(BOOL)left{
    CGFloat y = self.bounds.size.height - self.circleBottomLength - kCircleSize/2;
    if(left){
        self.punchedOutPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(kCircleSideCenterMargin - kCircleSize/2, y, kCircleSize, kCircleSize)];
        self.bottomColor = tcolor(StrongLaterColor);
        self.topColor = tcolor(LaterColor);
    }
    else{
        self.punchedOutPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.bounds.size.width - kCircleSideCenterMargin - kCircleSize/2, y, kCircleSize, kCircleSize)];
        self.bottomColor = tcolor(StrongDoneColor);
        self.topColor = tcolor(DoneColor);
    }
    [self setNeedsDisplay];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.height = frame.size.height;
        
        self.hidden = YES;
        self.popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-kBottomHeight)];
        self.popupView.backgroundColor = CLEAR;
        
        UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [continueButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
        [self.popupView addSubview:continueButton];
        
        [self addSubview:self.popupView];
    }
    return self;
}
-(void)show:(BOOL)show{
    if(!show){
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.height, self.frame.size.width, 0);
        self.hidden = NO;
    }
    else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.height, self.frame.size.width, self.height);
    }
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect topRect = CGRectMake(0, 0, rect.size.width, rect.size.height-kBottomHeight);
    [[self topColor] set];
    UIRectFill(topRect);
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    // Set the starting point of the shape.
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    [aPath moveToPoint:CGPointMake(kBottomExtraSide, height)];
    [aPath addLineToPoint:CGPointMake(width-kBottomExtraSide, height)];
    [aPath addLineToPoint:CGPointMake(width,height-kBottomHeight )];
    [aPath addLineToPoint:CGPointMake(0, height-kBottomHeight)];
    //[aPath addLineToPoint:CGPointMake(startingX, startingY)];
    [aPath closePath];
    CGContextAddPath(currentContext, aPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.bottomColor.CGColor);
    CGContextFillPath(currentContext);
    
    CGContextSetBlendMode(currentContext, kCGBlendModeDestinationOut);
    
    
    [[self punchedOutPath] fill];
    
    CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
}

@end
