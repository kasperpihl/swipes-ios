//
//  KPAccountAlert.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPAccountAlert.h"
#define DEFAULT_TITLE_HEIGHT 70
#define kMoreButtonFont KP_REGULAR(20)
#define kCrossButtonSize 44
#define kTextPadding 16
#define kMoreButtonHeight 44
#define kMoreButtonWidth 190


@interface KPAccountAlert ()
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic,copy) SuccessfulBlock block;
@property (nonatomic) BOOL shouldRemove;
@end
@implementation KPAccountAlert
+(void)alertInView:(UIView *)view message:(NSString *)message block:(SuccessfulBlock)block{
    KPAccountAlert *alertView = [[KPAccountAlert alloc] initWithFrame:view.bounds];
    alertView.block = block;
    alertView.messageLabel.text = message;
    alertView.shouldRemove = YES;
    [view addSubview:alertView];
}
+(KPAccountAlert*)alertWithFrame:(CGRect)frame message:(NSString *)message block:(SuccessfulBlock)block{
    KPAccountAlert *alertView = [[KPAccountAlert alloc] initWithFrame:frame];
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
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        [self setContentSize:CGSizeMake(300, 240)];
        UIButton *crossButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-kCrossButtonSize, 0, kCrossButtonSize, kCrossButtonSize)];
        crossButton.titleLabel.font = iconFont(23);
        [crossButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [crossButton setTitle:iconString(@"plusThick") forState:UIControlStateNormal];
        [crossButton setTitle:iconString(@"plusThick") forState:UIControlStateHighlighted];
        crossButton.transform = CGAffineTransformMakeRotation(M_PI/2/2);
        [crossButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
        //crossButton.imageEdgeInsets = kCrossButtonContentInset;
        [self.contentView addSubview:crossButton];
        
        UIButton *topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        topButton.titleLabel.font = iconFont(50);
        [topButton setTitle:iconString(@"settingsAccount") forState:UIControlStateNormal];
        [topButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        CGRectSetY(topButton, DEFAULT_TITLE_HEIGHT-topButton.frame.size.height);
        CGRectSetCenterX(topButton, self.contentView.frame.size.width/2);
        [topButton addTarget:self action:@selector(pressedAccount:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:topButton];
        
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextPadding, 50, self.contentView.frame.size.width-2*kTextPadding, 2*DEFAULT_TITLE_HEIGHT)];
        messageLabel.font = KP_REGULAR(18);
        messageLabel.textColor = tcolor(TextColor);
        messageLabel.numberOfLines = 0;
        messageLabel.backgroundColor = CLEAR;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:messageLabel];
        self.messageLabel = messageLabel;
        
        UIImage *buttonBackground = [[UIImage imageNamed:@"btn-plus-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMoreButtonWidth, kMoreButtonHeight)];
        [moreButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
        //[moreButton setBackgroundImage:[alpha(POPUP_BACKGROUND,0.5) image] forState:UIControlStateHighlighted];
        moreButton.layer.masksToBounds = YES;
        moreButton.titleLabel.font = kMoreButtonFont;
        [moreButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
        moreButton.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height-DEFAULT_TITLE_HEIGHT/2);
        CGRectSetY(moreButton, self.contentView.frame.size.height-DEFAULT_TITLE_HEIGHT);
        [moreButton addTarget:self action:@selector(pressedAccount:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:moreButton];
        
        [self addSubview:self.contentView];
    }
    return self;
}
-(void)pressedClose:(UIButton*)sender{
    if(self.shouldRemove)
        [self removeFromSuperview];
    if(self.block)
        self.block(NO,nil);
    
}
-(void)pressedAccount:(UIButton*)sender{
    if(self.shouldRemove)
        [self removeFromSuperview];
    if(self.block)
        self.block(YES,nil);
    
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
