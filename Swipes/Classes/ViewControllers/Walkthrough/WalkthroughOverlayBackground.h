//
//  WalkthroughOverlayBackground.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 28/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kBottomHeight 38
#define kBottomExtraSide 20
#define kCircleSize 70
#define kBottomToCircleLength 70
#define kCircleSideCenterMargin (kBottomExtraSide + 40)
#define kCircleBottomOfBarToCenter 16

#import <UIKit/UIKit.h>

@interface WalkthroughOverlayBackground : UIView
@property (nonatomic) UIColor *bottomColor;
@property (nonatomic) UIColor *topColor;
@property CGFloat circleBottomLength;
-(void)show:(BOOL)show;
-(void)setLeft:(BOOL)left;
@end
