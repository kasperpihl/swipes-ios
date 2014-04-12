//
//  WelcomeViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "UtilityClass.h"
#import "WalkthroughTitleView.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WelcomeViewController.h"


#define LOGO_Y valForScreen(40,40)
#define TITLE_Y valForScreen(122,140)

#define kMenuButtonY valForScreen(180,220)
#define kMenuButtonSize 60
#define kMenuButtonSideMargin 70

#define kActionButtonFont KP_REGULAR(20)
#define ACTION_BUTTON_WIDTH 240
#define ACTION_BUTTON_HEIGHT 44
#define ACTION_BUTTON_CORNER_RADIUS 3
#define kActionButtonBottomSpacing valForScreen(60,90)
#define kActionButtonBorderWidth 2

@interface WelcomeViewController ()
@property (nonatomic,strong) UIImageView *swipesLogo;
@property (nonatomic,strong) UIImageView *menuExplainer;
@property (nonatomic,strong) UIButton *tryButton;
@property (nonatomic,strong) WalkthroughTitleView *titleView;

/* The three menubuttons */
@property (nonatomic,strong) UIButton *scheduleButton;
@property (nonatomic,strong) UIButton *tasksButton;
@property (nonatomic,strong) UIButton *doneButton;
@end

@implementation WelcomeViewController
-(void)pressedTryButton:(UIButton*)sender{
    [ROOT_CONTROLLER tryoutapp];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kWalkthroughBackground;
    
    self.swipesLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_swipes_logo"]];
    self.swipesLogo.center = CGPointMake(self.view.center.x, self.swipesLogo.center.y+LOGO_Y);
    [self.view addSubview:self.swipesLogo];
    
    self.titleView = [[WalkthroughTitleView alloc] initWithFrame:CGRectMake(0, TITLE_Y, self.view.bounds.size.width, 0)];
    [self.titleView setTitle:@"Welcome to Swipes" subtitle:@"Here you find three areas where you can organize your tasks."];
    
    [self.view addSubview:self.titleView];
    
    self.scheduleButton = [self menuButtonWithImage:[UtilityClass imageWithName:@"schedule-highlighted" scaledToSize:CGSizeMake(22, 22)] color:tcolor(LaterColor)];
    CGRectSetCenterX(self.scheduleButton, kMenuButtonSideMargin);
    [self.view addSubview:self.scheduleButton];
    self.tasksButton = [self menuButtonWithImage:[UtilityClass imageWithName:@"today-highlighted" scaledToSize:CGSizeMake(22, 22)] color:tcolor(TasksColor)];
    CGRectSetCenterX(self.tasksButton, self.view.center.x);
    [self.view addSubview:self.tasksButton];
    self.doneButton = [self menuButtonWithImage:[UtilityClass imageWithName:@"done-highlighted" scaledToSize:CGSizeMake(22, 22)] color:tcolor(DoneColor)];
    CGRectSetCenterX(self.doneButton, self.view.bounds.size.width-kMenuButtonSideMargin);
    [self.view addSubview:self.doneButton];
    
    self.menuExplainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wt_menu_expain"]];
    CGRectSetCenter(self.menuExplainer, self.view.center.x, self.doneButton.center.y + 78);
    [self.view addSubview:self.menuExplainer];
    
    self.tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.tryButton.frame = CGRectMake((self.view.bounds.size.width-ACTION_BUTTON_WIDTH)/2, self.view.bounds.size.height-ACTION_BUTTON_HEIGHT-kActionButtonBottomSpacing, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
    self.tryButton.layer.cornerRadius = ACTION_BUTTON_CORNER_RADIUS;
    self.tryButton.layer.borderColor = tcolorF(BackgroundColor,ThemeDark).CGColor;
    self.tryButton.layer.borderWidth = 0;//kActionButtonBorderWidth;
    self.tryButton.backgroundColor = tcolor(DoneColor);
    self.tryButton.titleLabel.font = kActionButtonFont;
    [self.tryButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [self.tryButton setTitle:@"Try Swipes" forState:UIControlStateNormal];
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
    NSString *title = ([[NSUserDefaults standardUserDefaults] objectForKey:@"isTryingOutSwipes"]) ? @"Continue trying Swipes" : @"Try Swipes";
    NSLog(@"trybut:%@",self.tryButton);
    [self.tryButton setTitle:title forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
