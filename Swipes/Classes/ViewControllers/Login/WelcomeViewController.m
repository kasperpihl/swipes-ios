//
//  WelcomeViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "UtilityClass.h"
#import "UIColor+Utilities.h"
#import "SlowHighlightIcon.h"
#import "WalkthroughTitleView.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FBShimmeringView.h"
#import "WelcomeViewController.h"

#define launchImageName @"MASTER_000"
#define launchImageNumber 22//31

#define LOGO_Y valForScreen(40,40)
#define TITLE_Y valForScreen(122,140)

#define kMenuButtonY valForScreen(180,220)
#define kMenuButtonSize 60
#define kMenuButtonSideMargin 70

#define kActionButtonFont KP_SEMIBOLD(16)
#define ACTION_BUTTON_WIDTH 240
#define ACTION_BUTTON_HEIGHT 50
#define ACTION_BUTTON_CORNER_RADIUS 3
#define kActionButtonBottomSpacing valForScreen(120,180)
#define kActionButtonBorderWidth 1

@interface WelcomeViewController ()
@property (nonatomic,strong) UIImageView *backgroundImage;

@property (nonatomic,strong) UILabel *swipesLogo;
@property (nonatomic,strong) UIButton *tryButton;
@property (nonatomic,strong) UIButton *loginButton;
@property (nonatomic,strong) WalkthroughTitleView *titleView;

@end

@implementation WelcomeViewController
-(void)pressedTryButton:(UIButton*)sender{
    [ROOT_CONTROLLER tryoutapp];
}
-(void)pressedLogin:(UIButton*)sender{
    [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%i.jpg",launchImageName,0]]];
    [self.backgroundImage setFrame:self.view.bounds];
    NSMutableArray *animationImages = [NSMutableArray array];
    for(NSInteger i = 0 ; i < launchImageNumber ; i++){
        [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@%i.jpg",launchImageName,i]]];
    }
    NSArray *reversedImages = [[animationImages reverseObjectEnumerator] allObjects];
    [animationImages addObjectsFromArray:reversedImages];
    self.backgroundImage.animationImages = animationImages;
    [self.backgroundImage setAnimationDuration:4.5];
    [self.backgroundImage startAnimating];
    [self.view addSubview:self.backgroundImage];
    //self.view.backgroundColor = kWalkthroughBackground;
    
    
    /*UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = NSLocalizedString(@"Shimmer", nil);
    shimmeringView.contentView = loadingLabel;*/
    
    // Start shimmering.
    
    self.swipesLogo = iconLabel(@"logo", 60);
    [self.swipesLogo setTextColor:tcolorF(TextColor,ThemeDark)];
    self.swipesLogo.center = CGPointMake(self.view.center.x, self.swipesLogo.center.y+LOGO_Y);
    [self.view addSubview:self.swipesLogo];
    
    
    self.titleView = [[WalkthroughTitleView alloc] initWithFrame:CGRectMake(0, TITLE_Y, self.view.bounds.size.width, 0)];
    self.titleView.titleLabel.textColor = tcolorF(TextColor,ThemeDark);
    self.titleView.subtitleLabel.textColor = tcolorF(TextColor,ThemeDark);
    [self.titleView setTitle:@"Focus. Swipe. Achieve." subtitle:@"Task list made for High Achievers"];
    [self.view addSubview:self.titleView];

    
    //[self.view addSubview:self.titleView];
    
    color(24, 188, 241, 1);

    self.loginButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    self.loginButton.frame = CGRectMake((self.view.bounds.size.width-ACTION_BUTTON_WIDTH)/2, self.view.bounds.size.height-ACTION_BUTTON_HEIGHT-kActionButtonBottomSpacing, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
    self.loginButton.layer.cornerRadius = ACTION_BUTTON_CORNER_RADIUS;
    self.loginButton.layer.borderColor = color(24, 188, 241, 1).CGColor;
    self.loginButton.layer.borderWidth = kActionButtonBorderWidth;
    self.loginButton.backgroundColor = CLEAR;
    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.titleLabel.font = kActionButtonFont;
    [self.loginButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[color(24, 188, 241, 1) image] forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.loginButton addTarget:self action:@selector(pressedLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.loginButton];
    
    self.tryButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    self.tryButton.frame = CGRectMake((self.view.bounds.size.width-ACTION_BUTTON_WIDTH)/2, CGRectGetMaxY(self.loginButton.frame) + 30, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
    self.tryButton.layer.cornerRadius = ACTION_BUTTON_CORNER_RADIUS;
    self.tryButton.layer.borderColor = color(255, 190, 97, 1).CGColor;
    self.tryButton.layer.borderWidth = kActionButtonBorderWidth;
    self.tryButton.backgroundColor = CLEAR;
    self.tryButton.layer.masksToBounds = YES;
    self.tryButton.titleLabel.font = kActionButtonFont;
    [self.tryButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [self.tryButton setTitle:@"TRY OUT" forState:UIControlStateNormal];
    [self.tryButton setBackgroundImage:[color(255, 190, 97, 1) image] forState:UIControlStateHighlighted];
    [self.tryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.tryButton addTarget:self action:@selector(pressedTryButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tryButton];
    
}


-(UIButton*)menuButtonWithImage:(UIImage *)image color:(UIColor*)color{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, kMenuButtonY, kMenuButtonSize, kMenuButtonSize);
    button.layer.cornerRadius = kMenuButtonSize/2;
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
    //[button setBackgroundColor:color];
    button.showsTouchWhenHighlighted = NO;
    
    return button;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *title = ([[NSUserDefaults standardUserDefaults] objectForKey:@"isTryingOutSwipes"]) ? @"Continue trying Swipes" : @"TRY OUT";
    NSLog(@"trybut:%@",self.tryButton);
    [self.tryButton setTitle:title forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.backgroundImage stopAnimating];
    self.backgroundImage.animationImages = nil;
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
