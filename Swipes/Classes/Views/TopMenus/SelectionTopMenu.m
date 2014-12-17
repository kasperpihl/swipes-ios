//
//  SelectionTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SelectionTopMenu.h"
#import "SlowHighlightIcon.h"
#import "AudioHandler.h"

@interface SelectionTopMenu ()

@end
@implementation SelectionTopMenu
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = CLEAR;
        CGFloat topY = 4;//kTopY;
        UIView *gradientBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, topY)];
        gradientBackground.backgroundColor = CLEAR;
        CAGradientLayer *agradient = [CAGradientLayer layer];
        agradient.frame = gradientBackground.bounds;
        gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        agradient.colors = @[(id)alpha(tcolor(TextColor),0.0f).CGColor,(id)alpha(tcolor(TextColor),0.2f).CGColor,(id)alpha(tcolor(TextColor),0.4f).CGColor];
        agradient.locations = @[@0.0,@0.5,@1.0];
        [gradientBackground.layer insertSublayer:agradient atIndex:0];
        [self addSubview:gradientBackground];
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, topY, self.frame.size.width, self.frame.size.height-topY)];
        background.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        background.backgroundColor = tcolor(BackgroundColor);
        [self addSubview:background];
        
        UIButton *allButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        allButton.frame = CGRectMake(0, topY, kSideButtonsWidth, frame.size.height-topY);
        allButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        allButton.titleLabel.font = KP_REGULAR(16);
        [allButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [allButton setTitleColor:alpha(tcolor(TextColor),0.5) forState:UIControlStateHighlighted];
        [allButton setTitle:LOCALIZE_STRING(@"All") forState:UIControlStateNormal];
        [allButton addTarget:self action:@selector(onAll:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allButton];
        self.allButton = allButton;
        
        UIButton *helpButton = [[UIButton alloc] initWithFrame:CGRectMake(kSideButtonsWidth, topY, frame.size.width-2*kSideButtonsWidth, frame.size.height-topY)];
        helpButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        helpButton.backgroundColor = CLEAR;
        helpButton.titleLabel.font = KP_REGULAR(16);
        [helpButton setTitle:[LOCALIZE_STRING(@"Select more") uppercaseString] forState:UIControlStateNormal];
        [helpButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(onHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:helpButton];
        self.helpButton = helpButton;
        
        UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, topY, kSideButtonsWidth, frame.size.height-topY);
        closeButton.backgroundColor = CLEAR;
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(23);
        [closeButton setTitle:iconString(@"plusThick") forState:UIControlStateNormal];
        closeButton.transform = CGAffineTransformMakeRotation(M_PI/2/2);
        [closeButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
    }
    return self;
}

#pragma mark IBActions
-(void)onAll:(UIButton*)allButton{
    [self.selectionDelegate didPressAllInSelectionTopMenu:self];
}
-(void)onClose:(UIButton*)closeButton{
    [self.selectionDelegate didPressCloseInSelectionTopMenu:self];
}
-(void)onHelpButton:(UIButton*)helpButton{
    [self.selectionDelegate didPressHelpLabelInSelectionTopMenu:self];
}


#pragma mark UIView
-(void)dealloc{
    self.allButton = nil;
    self.helpButton = nil;
    self.closeButton = nil;
}
@end
