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
#import <QuartzCore/QuartzCore.h>
#import "KPSubtitleButton.h"
#define kCloseButtonSize 44
#define kLogoTopMargin 35
#define kSubscribeButtonWidth 140
#define kSubscribeButtonHeight 72
#define kSubButtonSubHeight 35
#define kSubButtonBorderWidth 2
#define kSubButtonCornerRadius 6
#define kSubButtonFont KP_BOLD(32)
#define kSubButtonSubFont KP_BOLD(13)
#define kSubButtonTitleTopInset 20
#define kSubButtonY 125


#define kBeforePreferFont KP_BOLD(20)
#define kBeforeSwipesFreeFont KP_REGULAR(12)
#define kBeforePreferWidth 240  

#define kAfterViewWidth 270
#define kAfterFeedbackFont KP_EXTRABOLD(37)
#define kAfterFeedbackY 40
#define kAfterFeedbackHeight 80
#define kAfterPostedFont KP_REGULAR(18)
#define kAfterPostedY       200
#define kAfterPostedSpacing 5
#define kAfterPostedHeight 60

#define kAfterArrowButtonSize 50

@interface UpgradeViewController ()
@property (nonatomic) UILabel *introLabel;
@property (nonatomic) UIView *beforeView;
@property (nonatomic) UIView *afterView;
@property (nonatomic) BOOL hasPressed;
@end

@implementation UpgradeViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = tcolor(DoneColor);
    
    UIImageView *salesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgrade_full"]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.scrollEnabled = YES;
    scrollView.bounces = NO;
    
    [scrollView addSubview:salesImage];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, salesImage.frame.size.height, scrollView.frame.size.width, 250)];
    bottomView.backgroundColor = tcolor(StrongDoneColor);
    
    self.beforeView = [[UIView alloc] initWithFrame:bottomView.bounds];
    
    UILabel *preferLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.beforeView.frame.size.width-kBeforePreferWidth)/2, 0, kBeforePreferWidth, kSubButtonY)];
    preferLabel.backgroundColor = CLEAR;
    preferLabel.textAlignment = UITextAlignmentCenter;
    preferLabel.numberOfLines = 0;
    preferLabel.textColor = [UIColor whiteColor];
    preferLabel.font = kBeforePreferFont;
    preferLabel.text = @"Which subscription would you prefer?";
    [self.beforeView addSubview:preferLabel];
    
    CGFloat subButtonSpacing = ((bottomView.frame.size.width-(2*kSubscribeButtonWidth))/3);
    KPSubtitleButton *monthButton = [[KPSubtitleButton alloc] initWithFrame:CGRectMake(subButtonSpacing, kSubButtonY, kSubscribeButtonWidth, kSubscribeButtonHeight)];
    CGRectSetHeight(monthButton.subtitleLabel, kSubButtonSubHeight);
    [monthButton setBackgroundImage:[tcolor(StrongLaterColor) image] forState:UIControlStateNormal];
    monthButton.layer.cornerRadius = kSubButtonCornerRadius;
    monthButton.layer.borderWidth = kSubButtonBorderWidth;
    monthButton.titleLabel.font = kSubButtonFont;
    monthButton.subtitleLabel.font = kSubButtonSubFont;
    monthButton.layer.borderColor = [UIColor whiteColor].CGColor;
    monthButton.titleEdgeInsets = UIEdgeInsetsMake(kSubButtonTitleTopInset, 0, 0, 0);
    monthButton.subtitleLabel.text = @"per month";
    monthButton.layer.masksToBounds = YES;
    [monthButton addTarget:self action:@selector(pressedMonthButton:) forControlEvents:UIControlEventTouchUpInside];
    [monthButton setTitle:@"$0.99" forState:UIControlStateNormal];

    
    KPSubtitleButton *yearButton = [[KPSubtitleButton alloc] initWithFrame:CGRectMake(2*subButtonSpacing + kSubscribeButtonWidth, kSubButtonY, kSubscribeButtonWidth, kSubscribeButtonHeight)];
    yearButton.subtitleLabel.text = @"per year";
    CGRectSetHeight(yearButton.subtitleLabel, kSubButtonSubHeight);
    [yearButton setBackgroundImage:[tcolor(StrongLaterColor) image] forState:UIControlStateNormal];
    yearButton.layer.cornerRadius = kSubButtonCornerRadius;
    yearButton.titleEdgeInsets = UIEdgeInsetsMake(kSubButtonTitleTopInset, 0, 0, 0);
    yearButton.layer.masksToBounds = YES;
    yearButton.layer.borderWidth = kSubButtonBorderWidth;
    yearButton.titleLabel.font = kSubButtonFont;
    yearButton.subtitleLabel.font = kSubButtonSubFont;
    [yearButton addTarget:self action:@selector(pressedYearButton:) forControlEvents:UIControlEventTouchUpInside];
    yearButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [yearButton setTitle:@"$9.99" forState:UIControlStateNormal];
    [self.beforeView addSubview:monthButton];
    [self.beforeView addSubview:yearButton];
    
    CGFloat yForFree = CGRectGetMaxY(yearButton.frame);
    UILabel *swipesFreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yForFree, self.beforeView.frame.size.width, self.beforeView.frame.size.height-yForFree)];
    swipesFreeLabel.backgroundColor = CLEAR;
    swipesFreeLabel.textAlignment = UITextAlignmentCenter;
    swipesFreeLabel.font = kBeforeSwipesFreeFont;
    swipesFreeLabel.textColor = [UIColor whiteColor];
    swipesFreeLabel.text = @"Swipes Basic will be always free of charge.";
    [self.beforeView addSubview:swipesFreeLabel];
    
    [bottomView addSubview:self.beforeView];
    
    self.afterView = [[UIView alloc] initWithFrame:bottomView.bounds];
    UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake((bottomView.frame.size.width -kAfterViewWidth)/2, kAfterFeedbackY, kAfterViewWidth, kAfterFeedbackHeight)];
    feedbackLabel.backgroundColor = CLEAR;
    feedbackLabel.textAlignment = UITextAlignmentCenter;
    feedbackLabel.textColor = [UIColor whiteColor];
    feedbackLabel.font = kAfterFeedbackFont;
    feedbackLabel.text = @"Thanks for your feedback!";
    feedbackLabel.numberOfLines = 0;
    [self.afterView addSubview:feedbackLabel];
    self.afterView.hidden = YES;
    
    UILabel *postedLabel = [[UILabel alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-kAfterViewWidth)/2, CGRectGetMaxY(feedbackLabel.frame)+kAfterPostedSpacing, kAfterViewWidth, kAfterPostedHeight)];
    postedLabel.backgroundColor = CLEAR;
    postedLabel.textColor = [UIColor whiteColor];
    postedLabel.textAlignment = UITextAlignmentCenter;
    postedLabel.font =kAfterPostedFont;
    postedLabel.numberOfLines = 0;
    postedLabel.text = @"We will keep you posted with the upcoming update.";
    [self.afterView addSubview:postedLabel];
    
    UIButton *arrowBackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomView.frame.size.height-kAfterArrowButtonSize, kAfterArrowButtonSize, kAfterArrowButtonSize)];
    [arrowBackButton setImage:[UIImage imageNamed:@"menu_back"] forState:UIControlStateNormal];
    [arrowBackButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    arrowBackButton.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
    [self.afterView addSubview:arrowBackButton];
    
    
    
    [bottomView addSubview:self.afterView];
    
    [scrollView addSubview:bottomView];
    
    scrollView.contentSize = CGSizeMake(320, salesImage.frame.size.height+bottomView.frame.size.height);
    
    
    [self.view addSubview:scrollView];
    /*
    UIImageView *headerLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgrade_plus_logo"]];
	headerLogo.center = CGPointMake(self.view.center.x,kLogoTopMargin+headerLogo.frame.size.height/2);
    [self.view addSubview:headerLogo];
    */
    // Do any additional setup after loading the view.
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"upgrade_plus_button"] forState:UIControlStateNormal];
    //[closeButton setImage:[UtilityClass imageNamed:@"cross_button" withColor:gray(255, 1)] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.view.bounds.size.width-kCloseButtonSize, 0, kCloseButtonSize, kCloseButtonSize);
    [closeButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    
}
-(void)changeToAfterView{
    if(self.hasPressed) return;
    self.hasPressed = YES;
    self.afterView.hidden = NO;
    self.afterView.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        self.afterView.alpha = 1;
        self.beforeView.alpha = 0;
    } completion:^(BOOL finished) {
        self.beforeView.hidden = YES;
    }];
}
-(void)pressedMonthButton:(UIButton*)sender{
    
    [self changeToAfterView];
    
}
-(void)pressedYearButton:(UIButton*)sender{
    
    [self changeToAfterView];
}
-(void)pressedCloseButton:(UIButton*)sender{
    [self.delegate closedUpgradeViewController:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
