//
//  EvernoteViewerView.m
//  Swipes
//
//  Created by demosten on 1/20/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//


#import "GlobalApp.h"
#import "KPBlurry.h"
#import "EvernoteViewerView.h"

#define kButtonHeight 52

@interface EvernoteViewerView ()

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic,strong) UIButton* backButton;
@property (nonatomic,strong) UIButton* attachButton;

@end

@implementation EvernoteViewerView

- (id)initWithFrame:(CGRect)frame andGuid:(NSString *)guid
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tcolor(BackgroundColor);

        CGFloat top = [GlobalApp statusBarHeight];
        
        // prepare back button
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, top, kButtonHeight, kButtonHeight);
        [_backButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        // prepare attach button
        _attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _attachButton.frame = CGRectMake(kButtonHeight,top,kButtonHeight,kButtonHeight );
        [_attachButton setImage:[UIImage imageNamed:timageStringBW(@"attach_icon")] forState:UIControlStateNormal];
        [_attachButton addTarget:self action:@selector(pressedAttach:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_attachButton];
        
        // prepare webview
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, top+kButtonHeight, 320, frame.size.height - top - kButtonHeight)];
        [self addSubview:_webView];
    }
    return self;
}

-(void)pressedBack:(UIButton*)backButton
{
    [self.delegate onGetBack];
}

-(void)pressedAttach:(UIButton*)backButton
{
    [self.delegate onAttach];
}

-(void)dealloc
{
    [_webView removeFromSuperview];
    _webView = nil;
}

@end
