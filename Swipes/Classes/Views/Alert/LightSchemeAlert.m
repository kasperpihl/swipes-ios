//
//  LightSchemeAlert.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "LightSchemeAlert.h"
#import "UIColor+Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "SlowHighlightIcon.h"
#import <Social/Social.h>
#import "RootViewController.h"
#import "AnalyticsHandler.h"

#define buttonImageSpacing 30
#define buttonHeight 38
#define buttonWidth 120
#define buttonSpacing 20

#define kShareButtonSize 40
#define kExtraHeight 30

@interface LightSchemeAlert ()
@property (nonatomic,copy) SuccessfulBlock block;
@property (nonatomic) NSString *sharingService;
@property (nonatomic) NSString *shareText;
@end
@implementation LightSchemeAlert
-(id)initWithDismissAction:(SuccessfulBlock)block{
    self = [self initWithFrame:CGRectZero];
    if(self){
        self.block = block;
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *unlockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light_scheme_unlocked"]];
        [self addSubview:unlockImage];
        
        UIButton *backgroundButton = [[UIButton alloc] initWithFrame:self.bounds];
        backgroundButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        [backgroundButton addTarget:self action:@selector(pressedDismiss) forControlEvents:UIControlEventTouchUpInside];
        backgroundButton.backgroundColor = CLEAR;
        [self addSubview:backgroundButton];
        
        CGFloat buttonY = CGRectGetMaxY(unlockImage.frame) + buttonImageSpacing;
        CGFloat buttonMiddle = CGRectGetMidX(unlockImage.frame);
        
        UIButton *activateButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonMiddle -buttonWidth/2, buttonY, buttonWidth, buttonHeight)];
        [activateButton setTitle:@"ACTIVATE" forState:UIControlStateNormal];
        activateButton.layer.cornerRadius = 4;
        activateButton.backgroundColor = tcolorF(TextColor,ThemeDark);
        [activateButton setBackgroundImage:[gray(230, 1) image] forState:UIControlStateHighlighted];
        activateButton.titleLabel.font = KP_REGULAR(16);
        [activateButton setTitleColor:tcolorF(BackgroundColor,ThemeDark) forState:UIControlStateNormal];
        activateButton.layer.masksToBounds = YES;
        [activateButton addTarget:self action:@selector(pressedActivate) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:activateButton];
        
        CGFloat shareButtonY = CGRectGetMaxY(activateButton.frame)+buttonImageSpacing;
        
        BOOL isFacebookAvailable = ([[UIDevice currentDevice].systemVersion floatValue] >= 6 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);
        BOOL isTwitterAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
        
        UIButton *facebookButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(buttonMiddle-buttonSpacing/2 - kShareButtonSize, shareButtonY, kShareButtonSize, kShareButtonSize)];
        [facebookButton setImage:[UIImage imageNamed:@"round_facebook_white"] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:@"round_facebook_white-high"] forState:UIControlStateHighlighted];
        [facebookButton addTarget:self action:@selector(pressedFacebook) forControlEvents:UIControlEventTouchUpInside];
        facebookButton.hidden = !isFacebookAvailable;
        [self addSubview:facebookButton];
        
        UIButton *twitterButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(buttonMiddle + buttonSpacing/2 , shareButtonY, kShareButtonSize, kShareButtonSize)];
        [twitterButton setImage:[UIImage imageNamed:@"round_twitter_white"] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:@"round_twitter_white-high"] forState:UIControlStateHighlighted];
        [twitterButton addTarget:self action:@selector(pressedTwitter) forControlEvents:UIControlEventTouchUpInside];
        twitterButton.hidden = !isTwitterAvailable;
        [self addSubview:twitterButton];
        
        self.frame = CGRectMake(0,0,CGRectGetMaxX(unlockImage.frame),CGRectGetMaxY(twitterButton.frame)+kExtraHeight);
    }
    return self;
}
-(void)shareForServiceType:(NSString*)serviceType{
    self.shareText = @"Sharing";
    
    NSString *realServiceType;
    
    if([serviceType isEqualToString:SLServiceTypeFacebook]){
        realServiceType = @"Facebook";
        self.shareText = @"Ready, Set, Go! For a #ProductiveDay with my Swipes App http://swipesapp.com/download";
    }
    else if([serviceType isEqualToString:SLServiceTypeTwitter]){
        self.shareText = @"Ready, Set, Go! For a #ProductiveDay with my @swipesapp http://swipesapp.com/download";
        realServiceType = @"Twitter";
    }
    SLComposeViewController *shareVC = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    shareVC.completionHandler = ^(SLComposeViewControllerResult result) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        switch(result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:{
                NSString *realServiceType;
                [dict setObject:self.shareText forKey:@"Share string"];
                if([self.sharingService isEqualToString:SLServiceTypeFacebook]) realServiceType = @"Facebook";
                else if([self.sharingService isEqualToString:SLServiceTypeTwitter]) realServiceType = @"Twitter";
                if(realServiceType) [dict setObject:realServiceType forKey:@"Service"];
                //[ANALYTICS tasgEvent:@"Sharing Successful" options:dict];
                break;
            }
        }
        [ROOT_CONTROLLER dismissViewControllerAnimated:YES completion:nil];
    };
    [shareVC addImage:[UIImage imageNamed:@"share_image_light_scheme.jpg"]];
    [shareVC setInitialText:self.shareText];
    [ROOT_CONTROLLER presentViewController:shareVC animated:YES completion:nil];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if(realServiceType) [dict setObject:realServiceType forKey:@"Service"];
    //[ANALYTICS tasgEvent:@"Sharing Opened" options:dict];
}
-(void)pressedFacebook{
    [self shareForServiceType:SLServiceTypeFacebook];
}
-(void)pressedTwitter{
    [self shareForServiceType:SLServiceTypeTwitter];
}
-(void)pressedActivate{
    if(self.block) self.block(YES,nil);
}
-(void)pressedDismiss{
    if(self.block) self.block(NO,nil);
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
