//
//  UpgradeViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UpgradeViewController.h"
#import "UtilityClass.h"
#import "UIColor+Utilities.h"
#import "UIView+Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "KPSubtitleButton.h"
#import "AnalyticsHandler.h"
#import "PaymentHandler.h"
#define kCloseButtonSize 60
#define kLogoTopMargin 35
#define kSubscribeButtonWidth 120
#define kSubscribeButtonHeight 60
#define kSubButtonSubHeight 35
#define kSubButtonCornerRadius 6
#define kSubButtonFont KP_REGULAR(24)
#define kSubButtonSubFont KP_REGULAR(14)
#define kSubButtonTitleTopInset 18
#define kSubButtonY 630



@interface UpgradeViewController ()
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) KPSubtitleButton *monthlyButton;
@property (nonatomic) KPSubtitleButton *yearlyButton;
@property (nonatomic) BOOL hasPressed;
@end

@implementation UpgradeViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = tcolor(DoneColor);
    
    UIImageView *salesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgrade_full"]];
    salesImage.userInteractionEnabled = YES;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.scrollEnabled = YES;
    scrollView.bounces = NO;
    
    [scrollView addSubview:salesImage];
    
    UIButton *scrollToBottomButton = [[UIButton alloc] initWithFrame:CGRectMake(76, 59, 170, 49)];
    [scrollToBottomButton addTarget:self action:@selector(pressedScrollToBottom:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:scrollToBottomButton];
    
    
    
    CGFloat subButtonSpacing = ((scrollView.frame.size.width-(2*kSubscribeButtonWidth))/3);
    KPSubtitleButton *monthButton = [[KPSubtitleButton alloc] initWithFrame:CGRectMake(subButtonSpacing, kSubButtonY, kSubscribeButtonWidth, kSubscribeButtonHeight)];
    CGRectSetHeight(monthButton.subtitleLabel, kSubButtonSubHeight);
    [monthButton setBackgroundImage:[color(235, 96, 80, 1) image] forState:UIControlStateNormal];
    monthButton.layer.cornerRadius = kSubButtonCornerRadius;
    monthButton.titleLabel.font = kSubButtonFont;
    monthButton.subtitleLabel.font = kSubButtonSubFont;
    monthButton.titleEdgeInsets = UIEdgeInsetsMake(kSubButtonTitleTopInset, 0, 0, 0);
    monthButton.subtitleLabel.text = @"monthly";
    monthButton.layer.masksToBounds = YES;
    [monthButton addTarget:self action:@selector(pressedMonthButton:) forControlEvents:UIControlEventTouchUpInside];
    //[monthButton setTitle:@"$0.99" forState:UIControlStateNormal];
    self.monthlyButton = monthButton;
    
    KPSubtitleButton *yearButton = [[KPSubtitleButton alloc] initWithFrame:CGRectMake(2*subButtonSpacing + kSubscribeButtonWidth, kSubButtonY, kSubscribeButtonWidth, kSubscribeButtonHeight)];
    yearButton.subtitleLabel.text = @"yearly";
    CGRectSetHeight(yearButton.subtitleLabel, kSubButtonSubHeight);
    [yearButton setBackgroundImage:[color(235, 96, 80, 1) image] forState:UIControlStateNormal];
    yearButton.layer.cornerRadius = kSubButtonCornerRadius;
    yearButton.titleEdgeInsets = UIEdgeInsetsMake(kSubButtonTitleTopInset, 0, 0, 0);
    yearButton.layer.masksToBounds = YES;
    yearButton.titleLabel.font = kSubButtonFont;
    yearButton.subtitleLabel.font = kSubButtonSubFont;
    [yearButton addTarget:self action:@selector(pressedYearButton:) forControlEvents:UIControlEventTouchUpInside];
    self.yearlyButton = yearButton;
    //[yearButton setTitle:@"$9.99" forState:UIControlStateNormal];
    [salesImage addSubview:monthButton];
    [salesImage addSubview:yearButton];
    
    
    
    scrollView.contentSize = CGSizeMake(320, salesImage.frame.size.height);
    
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"round_cross_small"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.view.bounds.size.width-kCloseButtonSize, (OSVER >= 7 ? 20 : 0), kCloseButtonSize, kCloseButtonSize);
    [closeButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    [[PaymentHandler sharedInstance] requestProductsWithBlock:^(SKProduct *plusMonthly, SKProduct *plusYearly, NSError *error) {
        [self.monthlyButton setTitle:plusMonthly.localizedPrice forState:UIControlStateNormal];
        [self.yearlyButton setTitle:plusYearly.localizedPrice forState:UIControlStateNormal];
    }];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)pressedScrollToBottom:(UIButton*)sender{
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}
-(void)pressedMonthButton:(UIButton*)sender{
    [sender showIndicator:YES];
    [[PaymentHandler sharedInstance] requestPlusMonthlyBlock:^(BOOL succeeded, NSError *error) {
        [sender showIndicator:NO];
        if(succeeded) [ANALYTICS tagEvent:@"Upgraded" options:@{@"Subscription":@"Monthly",@"Package":@"Plus"}];
        [self handlePaymentSucceeded:succeeded error:error];
    }];
}
-(void)pressedYearButton:(UIButton*)sender{
    [sender showIndicator:YES];
    [[PaymentHandler sharedInstance] requestPlusYearlyBlock:^(BOOL succeeded, NSError *error) {
        [sender showIndicator:NO];
        if(succeeded)[ANALYTICS tagEvent:@"Upgraded" options:@{@"Subscription":@"Yearly",@"Package":@"Plus"}];
        [self handlePaymentSucceeded:succeeded error:error];
    }];
}
-(void)handlePaymentSucceeded:(BOOL)succeeded error:(NSError*)error{
    if(succeeded){
        [self.delegate closedUpgradeViewController:self];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You’ve joined the Swipes Plus community. We’re so happy to have you on board. Go to swipesapp.com/plus to get started." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }else {
        NSLog(@"didn't succeed payment");
        NSLog(@"err:%@",error);
    }
}
-(void)pressedCloseButton:(UIButton*)sender{
    [self.delegate closedUpgradeViewController:self];
}
-(void)dealloc{
    self.scrollView = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
