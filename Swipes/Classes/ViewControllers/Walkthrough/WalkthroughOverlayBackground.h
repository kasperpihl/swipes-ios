//
//  WalkthroughOverlayBackground.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 28/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kBottomHeight 20
#define kBottomExtraSide 20
#define kCircleSize 42
#define kBottomToCircleLength 70
#define kCircleSideCenterMargin (kBottomExtraSide + 83)
#define kCircleBottomOfBarToCenter 15
#define kPopupTopMargin 30
#define kPopupSideMargin 20
#define kPopupSubtitleSpacing 10

#define kPopupTitleFont KP_BOLD(24)
#define kPopupSubtitleFont KP_SEMIBOLD(16)

#import <UIKit/UIKit.h>
#define kPopupTextColor [UIColor whiteColor]
@interface WalkthroughOverlayBackground : UIView
@property (nonatomic) UIColor *bottomColor;
@property (nonatomic) UIColor *topColor;
@property CGFloat circleBottomLength;
@property (nonatomic,strong) UIView *popupView;
@property (nonatomic,copy) SuccessfulBlock block;
@property (nonatomic,strong) UIButton *continueButton;
-(void)show:(BOOL)show;
-(void)setLeft:(BOOL)left title:(NSString*)title subtitle:(NSString *)subtitle;
- (id)initWithFrame:(CGRect)frame block:(SuccessfulBlock)block;
@end
