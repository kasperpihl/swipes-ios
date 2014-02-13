//
//  PlusAlertView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define DEFAULT_ALERTWIDTH 310
#define DEFAULT_TITLE_HEIGHT 70
#define kTextPadding 16
#define kMoreButtonHeight 44
#define kMoreButtonWidth 190
#define kMoreButtonFont KP_REGULAR(20)
#define kCrossButtonSize 44
#define kCrossButtonContentInset UIEdgeInsetsMake(0, 0, 0, 0)
#import "PlusAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Utilities.h"
@interface PlusAlertView ()
@property (nonatomic) UIButton *titleButton;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic,copy) SuccessfulBlock block;
@property (nonatomic) BOOL shouldRemove;
@end

@implementation PlusAlertView
+(void)alertInView:(UIView *)view message:(NSString *)message block:(SuccessfulBlock)block{
    PlusAlertView *alertView = [[PlusAlertView alloc] initWithFrame:view.bounds];
    alertView.block = block;
    alertView.messageLabel.text = message;
    alertView.shouldRemove = YES;
    [view addSubview:alertView];
}
+(PlusAlertView*)alertWithFrame:(CGRect)frame message:(NSString *)message block:(SuccessfulBlock)block{
    PlusAlertView *alertView = [[PlusAlertView alloc] initWithFrame:frame];
    alertView.block = block;
    alertView.messageLabel.text = message;
    return alertView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:self.bounds];
        [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        //self.frame = contentView.bounds;
        contentView.center = self.center;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        contentView.backgroundColor = tcolor(BackgroundColor);
        
        UIButton *crossButton = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width-kCrossButtonSize, 0, kCrossButtonSize, kCrossButtonSize)];
        [crossButton setImage:[UIImage imageNamed:timageStringBW(@"round_cross")] forState:UIControlStateNormal];
        [crossButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
        crossButton.imageEdgeInsets = kCrossButtonContentInset;
        [contentView addSubview:crossButton];
        
        UIImage *buttonImage = [UIImage imageNamed:@"upgrade_plus_logo"];
        UIButton *topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
        [topButton setImage:buttonImage forState:UIControlStateNormal];
        CGRectSetY(topButton, DEFAULT_TITLE_HEIGHT-topButton.frame.size.height);
        CGRectSetCenterX(topButton, contentView.frame.size.width/2);
        [topButton addTarget:self action:@selector(pressedPlus:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:topButton];
        
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextPadding, DEFAULT_TITLE_HEIGHT, contentView.frame.size.width-2*kTextPadding, 2*DEFAULT_TITLE_HEIGHT)];
        messageLabel.font = KP_REGULAR(18);
        messageLabel.textColor = tcolor(TextColor);
        messageLabel.numberOfLines = 0;
        messageLabel.backgroundColor = CLEAR;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:messageLabel];
        self.messageLabel = messageLabel;
        
        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMoreButtonWidth, kMoreButtonHeight)];
        [moreButton setBackgroundImage:[color(235, 96, 80, 1) image] forState:UIControlStateNormal];
        //[moreButton setBackgroundImage:[alpha(POPUP_BACKGROUND,0.5) image] forState:UIControlStateHighlighted];
        moreButton.layer.cornerRadius = 3;
        moreButton.layer.masksToBounds = YES;
        moreButton.titleLabel.font = kMoreButtonFont;
        [moreButton setTitle:@"LEARN MORE" forState:UIControlStateNormal];
        moreButton.center = CGPointMake(contentView.frame.size.width/2, contentView.frame.size.height-DEFAULT_TITLE_HEIGHT/2);
        CGRectSetY(moreButton, contentView.frame.size.height-DEFAULT_TITLE_HEIGHT-20);
        [moreButton addTarget:self action:@selector(pressedPlus:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:moreButton];
        
        [self addSubview:contentView];
    }
    return self;
}
-(void)pressedClose:(UIButton*)sender{
    if(self.block) self.block(NO,nil);
    if(self.shouldRemove) [self removeFromSuperview];
}
-(void)pressedPlus:(UIButton*)sender{
    if(self.block) self.block(YES,nil);
    if(self.shouldRemove) [self removeFromSuperview];
}
-(void)dealloc{
    self.messageLabel = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
