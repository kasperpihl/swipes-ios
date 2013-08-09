//
//  UpgradeViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UpgradeViewController.h"
#import "UtilityClass.h"
#define kCloseButtonSize 44
#define kLogoTopMargin 35

@interface UpgradeViewController ()
@property (nonatomic) UILabel *introLabel;
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
    scrollView.contentSize = CGSizeMake(320, salesImage.frame.size.height);
    [scrollView addSubview:salesImage];
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
-(void)pressedCloseButton:(UIButton*)sender{
    [self.delegate closedUpgradeViewController:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
