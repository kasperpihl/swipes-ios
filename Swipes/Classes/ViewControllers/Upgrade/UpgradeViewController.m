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
#import "SlowHighlightIcon.h"
#define kCloseButtonSize 44
#define kLogoTopMargin 35
#define kSubscribeButtonWidth 123
#define kSubscribeButtonHeight 60
#define kSubButtonSubHeight 35
#define kSubButtonCornerRadius 1
#define kSubButtonFont KP_REGULAR(19)
#define kSubButtonSubFont KP_REGULAR(14)
#define kSubButtonTitleTopInset 18
#define kSubButtonY 700
#define kRestoreSpacing 30


@interface UpgradeViewController ()
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) KPSubtitleButton *monthlyButton;
@property (nonatomic) KPSubtitleButton *yearlyButton;
@property (nonatomic) BOOL hasPressed;
@property (nonatomic) UIButton *restoreButton;
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
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [scrollView addSubview:salesImage];
    
    UIButton *scrollToBottomButton = [[UIButton alloc] initWithFrame:CGRectMake(76, 59, 170, 49)];
    [scrollToBottomButton addTarget:self action:@selector(pressedScrollToBottom:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:scrollToBottomButton];
    
    
    
    UIImage *buttonBackground = [[UIImage imageNamed:@"btn-plus-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    
    CGFloat subButtonSpacing = ((scrollView.frame.size.width-(2*kSubscribeButtonWidth))/3);
    KPSubtitleButton *monthButton = [[KPSubtitleButton alloc] initWithFrame:CGRectMake(subButtonSpacing, kSubButtonY, kSubscribeButtonWidth, kSubscribeButtonHeight)];
    CGRectSetHeight(monthButton.subtitleLabel, kSubButtonSubHeight);
    [monthButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    //monthButton.layer.cornerRadius = kSubButtonCornerRadius;
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
    [yearButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    //yearButton.layer.cornerRadius = kSubButtonCornerRadius;
    yearButton.titleEdgeInsets = UIEdgeInsetsMake(kSubButtonTitleTopInset, 0, 0, 0);
    yearButton.layer.masksToBounds = YES;
    yearButton.titleLabel.font = kSubButtonFont;
    yearButton.subtitleLabel.font = kSubButtonSubFont;
    [yearButton addTarget:self action:@selector(pressedYearButton:) forControlEvents:UIControlEventTouchUpInside];
    self.yearlyButton = yearButton;
    //[yearButton setTitle:@"$9.99" forState:UIControlStateNormal];
    
    self.restoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 38)];
    [self.restoreButton setTitle:@"Restore transactions" forState:UIControlStateNormal];
    self.restoreButton.layer.cornerRadius = kSubButtonCornerRadius;
    self.restoreButton.backgroundColor = tcolorF(TextColor,ThemeDark);
    [self.restoreButton setBackgroundImage:[gray(230, 1) image] forState:UIControlStateHighlighted];
    self.restoreButton.titleLabel.font = KP_REGULAR(16);
    [self.restoreButton setTitleColor:tcolorF(BackgroundColor,ThemeDark) forState:UIControlStateNormal];
    self.restoreButton.layer.masksToBounds = YES;
    [self.restoreButton addTarget:self action:@selector(pressedRestoreButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRectSetY(self.restoreButton, CGRectGetMaxY(self.yearlyButton.frame) + kRestoreSpacing);
    CGRectSetCenterX(self.restoreButton, salesImage.frame.size.width/2);
    
    [salesImage addSubview:monthButton];
    [salesImage addSubview:yearButton];
    [salesImage addSubview:self.restoreButton];
    
    
    scrollView.contentSize = CGSizeMake(320, salesImage.frame.size.height);
    
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;

    UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    closeButton.titleLabel.font = iconFont(23);
    [closeButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
    [closeButton setTitle:iconString(@"roundCloseFull") forState:UIControlStateHighlighted];
    closeButton.frame = CGRectMake(self.view.bounds.size.width-kCloseButtonSize, [GlobalApp statusBarHeight], kCloseButtonSize, kCloseButtonSize);
    [closeButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    [[PaymentHandler sharedInstance] requestProductsWithBlock:^(SKProduct *plusMonthly, SKProduct *plusYearly, NSError *error) {
        if(plusMonthly) [self.monthlyButton setTitle:plusMonthly.localizedPrice forState:UIControlStateNormal];
        if(plusYearly) [self.yearlyButton setTitle:plusYearly.localizedPrice forState:UIControlStateNormal];
    }];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.scrollView flashScrollIndicators];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self.scrollView selector:@selector(flashScrollIndicators) userInfo:nil repeats:NO];
    //[self.scrollView flashScrollIndicators];
}
-(void)pressedScrollToBottom:(UIButton*)sender{
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}
-(void)pressedMonthButton:(UIButton*)sender{
    if(self.hasPressed) return;
    self.hasPressed = YES;
    [sender showIndicator:YES];
    /*[[PaymentHandler sharedInstance] requestPlusMonthlyBlock:^(BOOL succeeded, NSError *error) {
        self.hasPressed = NO;
        [sender showIndicator:NO];
        if(succeeded) [ANALYTICS tasgEvent:@"Upgraded" options:@{@"Subscription":@"Monthly",@"Package":@"Plus"}];
        [self handlePaymentSucceeded:succeeded error:error];
    }];*/
}
-(void)pressedYearButton:(UIButton*)sender{
    if(self.hasPressed) return;
    self.hasPressed = YES;
    [sender showIndicator:YES];
    /*[[PaymentHandler sharedInstance] requestPlusYearlyBlock:^(BOOL succeeded, NSError *error) {
        self.hasPressed = NO;
        [sender showIndicator:NO];
        if(succeeded)[ANALYTICS tasgEvent:@"Upgraded" options:@{@"Subscription":@"Yearly",@"Package":@"Plus"}];
        [self handlePaymentSucceeded:succeeded error:error];
    }];*/
}
-(void)pressedRestoreButton:(UIButton*)sender{
    if(self.hasPressed) return;
    self.hasPressed = YES;
    [sender showIndicator:YES];
    [[PaymentHandler sharedInstance] restoreWithBlock:^(NSError *error) {
        self.hasPressed = NO;
        [sender showIndicator:NO];
        if(!error){
            [self.delegate closedUpgradeViewController:self];
            [UTILITY alertWithTitle:@"Purchase restored" andMessage:@"Your purchase has been restored. Welcome back!"];
        }
        else {
            [UTILITY alertWithTitle:@"An error occured" andMessage:@"No purchases could be restored. Contact support@swipesapp.com for help."];
        }
    }];
}
-(void)handlePaymentSucceeded:(BOOL)succeeded error:(NSError*)error{
    if(succeeded){
        [self.delegate closedUpgradeViewController:self];
        [UTILITY alertWithTitle:@"Congratulations!" andMessage:@"You’ve joined the Swipes Plus community. We’re so happy to have you on board. Go to swipesapp.com/plus to get started."];
    }else {
        [UTILITY alertWithTitle:@"An error occured" andMessage:@"Please try again, or contact support@swipesapp.com for help"];
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
