//
//  MenuViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RootViewController.h"
#import "UtilityClass.h"
#import "KPAlert.h"
#import "KPBlurry.h"
#import "MenuButton.h"
#import "SettingsHandler.h"
#import "HelpingViewController.h"
#import "SettingsViewController.h"
#import "IntegrationsViewController.h"
#import "SnoozesViewController.h"
#import "AnalyticsHandler.h"
#import "UserHandler.h"
#import "UIView+Utilities.h"
#import "CoreSyncHandler.h"
#import "PlusAlertView.h"
#import "NotificationHandler.h"
#import "IntegrationTitleView.h"

#import "MenuViewController.h"

static CGFloat const kTopMargin = 60;

#define kMenuButtonStartTag 4123
#define kLampOnColor (kIntegrationGreenColor)
#define kLampOffColor tcolor(BackgroundColor)

#define kGridMargin valForScreen(15,10)
#define kVerticalGridNumber 3
#define kHorizontalGridNumber 2
#define kGridButtonPadding 0

@interface MenuViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *menuButtons;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) MenuButton *schemeButton;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UILabel *syncLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *menuPanning;
@property (nonatomic, strong) IntegrationTitleView* titleView;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleView = [[IntegrationTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTopMargin)];
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleView.title = [NSLocalizedString(@"Settings", nil) uppercaseString];
    [self.view addSubview:_titleView];
    
    self.syncLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.syncLabel.textAlignment = NSTextAlignmentCenter;
    self.syncLabel.backgroundColor = CLEAR;
    self.syncLabel.font = KP_REGULAR(13);
    [self updateSyncLabel];
    
    [self renderSubviews];
    
    self.menuPanning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    
    UIView *panningView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - kGridMargin, 0, kGridMargin, self.view.bounds.size.height)];
    [panningView addGestureRecognizer:self.menuPanning];
    [self.view addSubview:panningView];
    notify(@"changed isPlus", changedIsPlus);
    notify(@"updated sync",updateSyncLabel);
    notify(@"changed theme", changedTheme);
    
    UISwipeGestureRecognizer* gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:gesture];
}

-(NSMutableArray *)viewControllers
{
    if (!_viewControllers)
        _viewControllers = [NSMutableArray array];
    return _viewControllers;
}

-(KPMenuButtons)buttonForTag:(NSInteger)tag
{
    return tag - kMenuButtonStartTag;
}

-(NSInteger)tagForButton:(KPMenuButtons)button
{
    return kMenuButtonStartTag + button;
}

-(void)pressedBack:(UIButton*)backButton
{
    [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
}

-(void)reset{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self renderSubviews];
}

- (void)renderSubviews
{
    [self.backButton removeFromSuperview];
    
    for (UIView *view in self.menuButtons)
        [view removeFromSuperview];
    
    CGFloat numberOfButtons = kHorizontalGridNumber * kVerticalGridNumber;
    self.view.backgroundColor = gray(224,1);//tcolor(BackgroundColor);
    CGSize s = self.view.frame.size;
    CGFloat backSpacing = 8.f;
    CGFloat buttonSize = 50.0f;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(s.width - buttonSize - backSpacing, s.height-buttonSize, buttonSize, buttonSize)];
    //UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-buttonSize-backSpacing,startY,buttonSize,buttonSize)];
    backButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    backButton.titleLabel.font = iconFont(23);
    [backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.transform = CGAffineTransformMakeRotation(M_PI);
    self.backButton = backButton;
    
    //self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0,startY,self.view.bounds.size.width-2*kGridMargin,self.view.bounds.size.height-startY)];
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 318, 242)];
    
    CGFloat gridWidth = self.gridView.bounds.size.width;
    
    UIButton *actualButton;
    NSMutableArray *menuButtons = [NSMutableArray array];
    
    for (NSInteger i = 1; i <= numberOfButtons; i++) {
        KPMenuButtons button = i;
        actualButton = [self buttonForMenuButton:button];
        if (button == KPMenuButtonScheme)
            self.schemeButton = (MenuButton*)actualButton;
        [self.gridView addSubview:actualButton];
        [menuButtons addObject:actualButton];
    }
    
    self.menuButtons = [menuButtons copy];
    [self.view addSubview:self.gridView];
    
    self.gridView.center = CGPointMake(s.width / 2, s.height / 2 - valForScreen(0, 20));
    self.syncLabel.frame = CGRectMake(0, CGRectGetMaxY(self.gridView.bounds) + 10, gridWidth, 20);
    self.syncLabel.textColor = tcolor(SubTextColor);
    [self.gridView addSubview:self.syncLabel];
    [self updateSchemeButton];

    [self.view addSubview:backButton]; // shoud be on top of grid
}

-(void)updateSchemeButton
{
    //BOOL isDarkTheme = (THEMER.currentTheme == ThemeDark);
    NSString *normalTitle = [self stringForMenuButton:KPMenuButtonScheme highlighted:YES];
    NSString *highlightTitle = [self stringForMenuButton:KPMenuButtonScheme highlighted:NO];
    [self.schemeButton.iconLabel setTitle:normalTitle forState:UIControlStateNormal];
    
    [self.schemeButton.iconLabel setTitle:highlightTitle forState:UIControlStateHighlighted];
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self pressedBack:nil];
    }
}

-(void)updateSyncLabel
{
    NSDate *lastSync = [USER_DEFAULTS objectForKey:@"lastSyncLocalDate"];
    NSString *timeString = [NSLocalizedString(@"never", nil) capitalizedString];
    if (lastSync) {
        timeString = [UtilityClass readableTime:lastSync showTime:YES];
    }
    self.syncLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last sync: %@", nil),timeString];
}

-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    //[kSideMenu panGestureRecognized:sender];
    if([sender translationInView:sender.view].x < -10){
        [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
    }
}

-(UIView*)seperatorWithSize:(CGFloat)size vertical:(BOOL)vertical
{
    CGFloat width = (vertical) ? SEPERATOR_WIDTH : size;
    CGFloat height = (vertical) ? size : SEPERATOR_WIDTH;
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    seperator.backgroundColor = tcolor(TextColor);
    return seperator;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)addModalTransition {
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.15;
    transition.type = kCATransitionFade;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
}

-(void)pressedMenuButton:(MenuButton*)sender{
    
    KPMenuButtons button = [self buttonForTag:sender.tag];
    switch (button) {
        case KPMenuButtonSettings:{
            SettingsViewController *vc = [[SettingsViewController alloc] init];
            [ANALYTICS pushView:@"Settings Menu"];
            [self addModalTransition];
            [self presentViewController:vc animated:NO completion:nil];
            break;
        }
        case KPMenuButtonHelp:{
            HelpingViewController *helpVC = [[HelpingViewController alloc] init];
            [ANALYTICS pushView:@"Help Menu"];
            //[self pushViewController:helpVC animated:YES];
            [self addModalTransition];
            [self presentViewController:helpVC animated:NO completion:nil];
            break;
        }
        case KPMenuButtonLogout:{
            if(!kUserHandler.isLoggedIn){
                [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
                return;
            }
            [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Log out", nil) andMessage:NSLocalizedString(@"Are you sure you want to log out of your account?", nil) block:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [ROOT_CONTROLLER logOut];
                    [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
                }
            }];
            break;
        }
        case KPMenuButtonSync:{
            if(!kUserHandler.isLoggedIn){
                [ROOT_CONTROLLER accountAlertWithMessage:nil];
                return;
            }
            CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rotate.byValue = @(M_PI * 2); // Change to - angle for counter clockwise rotation
            rotate.duration = 0.5;
            [sender.iconLabel.layer addAnimation:rotate forKey:@"myRotationAnimation"];
            
             // make sure Evernote caches are empty
            [KPCORE clearCache];
            [KPCORE synchronizeForce:YES async:YES];
            
            break;
        }
        case KPMenuButtonScheme:{
            [THEMER changeTheme];
            NSString *newTheme = ([THEMER currentTheme] == ThemeDark) ? @"Dark" : @"Light";
            [ANALYTICS trackEvent:@"Changed Theme" options:@{@"Theme":newTheme}];
            [ANALYTICS trackCategory:@"Settings" action:@"Changed Theme" label:newTheme value:nil];
            [ROOT_CONTROLLER resetRoot];
            
            break;
        }
        
        default:
            break;
    }
}

-(void)changedTheme{
    //[self renderSubviews];
}

-(NSString *)titleForMenuButton:(KPMenuButtons)button
{
    NSString *title;
    switch (button) {
        case KPMenuButtonSettings:
            title = NSLocalizedString(@"Options", nil);
            break;
        case KPMenuButtonHelp:
            title = NSLocalizedString(@"Help", nil);
            break;
        case KPMenuButtonSync:
            title = NSLocalizedString(@"Sync", nil);
            break;
        case KPMenuButtonLogout:
            title = (kUserHandler.isLoggedIn) ? NSLocalizedString(@"Logout", nil) : NSLocalizedString(@"Account", nil);
            break;
        case KPMenuButtonScheme:
            title = NSLocalizedString(@"Theme", nil);
            break;
    }
    return title;
}

-(NSString *)stringForMenuButton:(KPMenuButtons)button highlighted:(BOOL)highlighted
{
    NSString *imageString;
    switch (button) {
        case KPMenuButtonSettings:
            imageString = @"settings";
            break;
        case KPMenuButtonHelp:
            imageString = @"settingsFeedback";
            break;
        case KPMenuButtonSync:
            imageString = @"settingsSync";
            break;
        case KPMenuButtonLogout:
            imageString = (kUserHandler.isLoggedIn) ? @"settingsLogout" : @"settingsAccount";
            break;
        case KPMenuButtonScheme:
            imageString = @"settingsTheme";
            break;
    }
    if (highlighted)
        imageString = [imageString stringByAppendingString:@"Full"];

    return iconString(imageString);
}

- (CGRect) frameForButton:(KPMenuButtons)button
{
    CGFloat width = self.gridView.frame.size.width / kVerticalGridNumber - (2 * kGridButtonPadding);
    CGFloat x = ((button - 1) % kVerticalGridNumber) * self.gridView.frame.size.width / kVerticalGridNumber + kGridButtonPadding;
    CGFloat y = floor((button - 1) / kVerticalGridNumber) * self.gridView.frame.size.width / kVerticalGridNumber + kGridButtonPadding;
    return CGRectMake(x, y, width, width);
}

-(void)longPress:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Hard sync", nil) andMessage:NSLocalizedString(@"This will send all data and can take some time", nil) block:^(BOOL succeeded, NSError *error) {
            if(succeeded)
                [KPCORE hardSync];
        }];
    }
}

-(UIButton*)buttonForMenuButton:(KPMenuButtons)menuButton
{
    MenuButton *button = [[MenuButton alloc] initWithFrame:[self frameForButton:menuButton] title:[self titleForMenuButton:menuButton]];
    button.iconLabel.titleLabel.font = iconFont(41);
    [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateHighlighted];
    [button.iconLabel setTitle:[self stringForMenuButton:menuButton highlighted:NO] forState:UIControlStateNormal];
    [button.iconLabel setTitle:[self stringForMenuButton:menuButton highlighted:YES] forState:UIControlStateHighlighted];
    if(menuButton == KPMenuButtonSync){
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longPress];
    }
    button.tag = [self tagForButton:menuButton];
    [button addTarget:self action:@selector(pressedMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)repaint{
    self.syncLabel.textColor = tcolor(TextColor);
}

-(void)dealloc{
    clearNotify();
}

-(void)pressedTut{
    [ROOT_CONTROLLER walkthrough];
    //[THEMER changeTheme];
    //[ROOT_CONTROLLER resetRoot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
   
    CGFloat numberOfButtons = kHorizontalGridNumber * kVerticalGridNumber;
    self.view.backgroundColor = tcolor(BackgroundColor);
    
    CGFloat gridWidth = self.gridView.bounds.size.width;
    
    if (_menuButtons && (_menuButtons.count > numberOfButtons - 1)) {
        for (NSInteger i = 1; i <= numberOfButtons; i++) {
            ((UIButton *)_menuButtons[i - 1]).frame = [self frameForButton:i];
        }
    }
    
    CGSize s = self.view.frame.size;
    self.gridView.center = CGPointMake(s.width / 2, s.height / 2 - valForScreen(0, 20));
    self.syncLabel.frame = CGRectMake(0, CGRectGetMaxY(self.gridView.bounds) + 10, gridWidth, 20);
    
    CGFloat backSpacing = 8.f;
    CGFloat buttonSize = 44.0f;
    self.backButton.frame = CGRectMake(s.width - buttonSize - backSpacing, s.height-buttonSize-backSpacing, buttonSize, buttonSize);
}

@end
