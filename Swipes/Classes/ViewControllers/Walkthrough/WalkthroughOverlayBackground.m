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

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subtitleLabel;
@end
@implementation WalkthroughOverlayBackground
-(void)setLeft:(BOOL)left title:(NSString *)title subtitle:(NSString *)subtitle{
    CGFloat y = self.bounds.size.height - self.circleBottomLength - kCircleSize/2;
    CGRectSetSize(self.subtitleLabel, self.popupView.frame.size.width-2*kPopupSideMargin, self.popupView.frame.size.height - self.subtitleLabel.frame.origin.y);
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    [self.subtitleLabel sizeToFit];
    if(left){
        self.punchedOutPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(kCircleSideCenterMargin - kCircleSize/2, y, kCircleSize, kCircleSize)];
        self.bottomColor = tcolor(StrongLaterColor);
        self.topColor = tcolor(LaterColor);
        self.subtitleLabel.textAlignment = UITextAlignmentRight;
        self.titleLabel.textAlignment = UITextAlignmentRight;
        CGRectSetX(self.subtitleLabel, self.popupView.frame.size.width - self.subtitleLabel.frame.size.width - kPopupSideMargin);
        CGRectSetX(self.continueButton, self.popupView.frame.size.width - self.continueButton.frame.size.width - kPopupSideMargin);
    }
    else{
        self.punchedOutPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.bounds.size.width - kCircleSideCenterMargin - kCircleSize/2, y, kCircleSize, kCircleSize)];
        self.bottomColor = tcolor(StrongDoneColor);
        self.topColor = tcolor(DoneColor);
        CGRectSetX(self.subtitleLabel, kPopupSideMargin);
        self.subtitleLabel.textAlignment = UITextAlignmentLeft;
        self.titleLabel.textAlignment = UITextAlignmentLeft;
        CGRectSetX(self.continueButton, kPopupSideMargin);
    }
    [self setNeedsDisplay];
}
-(void)pressedContinueButton:(UIButton*)sender{
    if(self.block) self.block(YES,nil);
    self.block = nil;
}
- (id)initWithFrame:(CGRect)frame block:(SuccessfulBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        if(block) self.block = block;
        self.autoresizesSubviews = YES;
        self.backgroundColor=[UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.height = frame.size.height;
        
        self.hidden = YES;
        self.popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-kBottomHeight)];
        self.popupView.backgroundColor = CLEAR;
        self.popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.popupView.autoresizesSubviews = YES;
        self.popupView.alpha = 0;
        self.popupView.layer.masksToBounds = YES;
        CGFloat continueButtonMargin = 20;
        CGFloat continueButtonHeight = 35;
        CGFloat continueButtonWidth = 120;
        self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.continueButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
      //  self.continueButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.continueButton.frame = CGRectMake(continueButtonMargin, self.popupView.frame.size.height - continueButtonHeight - kPopupSideMargin, continueButtonWidth, continueButtonHeight);
        [self.continueButton addTarget:self action:@selector(pressedContinueButton:) forControlEvents:UIControlEventTouchUpInside];
        self.continueButton.layer.borderColor = kPopupTextColor.CGColor;
        self.continueButton.layer.borderWidth = 2;
        self.continueButton.layer.cornerRadius = 3;

        [self.popupView addSubview:self.continueButton];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPopupSideMargin, kPopupTopMargin, self.popupView.frame.size.width-2*kPopupSideMargin, 25)];
        self.titleLabel.backgroundColor = CLEAR;
        self.titleLabel.font = kPopupTitleFont;
        self.titleLabel.textColor = kPopupTextColor;
        [self.popupView addSubview:self.titleLabel];
        
        CGFloat subY = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kPopupSubtitleSpacing;
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPopupSideMargin, subY, self.popupView.frame.size.width-2*kPopupSideMargin, self.popupView.frame.size.height-subY)];
        self.subtitleLabel.font = kPopupSubtitleFont;
        self.subtitleLabel.backgroundColor = CLEAR;
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.textColor = kPopupTextColor;
        [self.popupView addSubview:self.subtitleLabel];
        
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
-(void)dealloc{
    self.popupView = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.continueButton = nil;
}
@end
