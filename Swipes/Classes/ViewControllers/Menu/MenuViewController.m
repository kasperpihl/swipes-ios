//
//  MenuViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "MenuViewController.h"
#import "RootViewController.h"
#import "KPToolbar.h"
#import "UtilityClass.h"
#import "KPAlert.h"
#import "KPBlurry.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MenuButton.h"
#import "SettingsHandler.h"
#import "SnoozesViewController.h"
#import "AnalyticsHandler.h"
#import "UserHandler.h"
#import "KPAccountAlert.h"
#import "UIView+Utilities.h"

#import "CoreSyncHandler.h"
#import "PlusAlertView.h"
#import "NotificationHandler.h"


#define kMenuButtonStartTag 4123
#define kLampOnColor tcolor(DoneColor)
#define kLampOffColor tcolor(BackgroundColor)

#define kSeperatorMargin 0
#define kGridMargin valForScreen(15,10)
#define kVerticalGridNumber 3
#define kHorizontalGridNumber 4
#define kGridButtonPadding 0

@interface MenuViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutletCollection(UIView) NSMutableArray *seperatorsH;
@property (nonatomic, strong) IBOutletCollection(UIView) NSMutableArray *seperatorsV;
@property (nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) NSMutableArray *viewControllers;
@property (nonatomic) MenuButton *schemeButton;
@property (nonatomic) UIView *gridView;
@property (nonatomic) UILabel *syncLabel;
@property (nonatomic) UIPanGestureRecognizer *menuPanning;

@end

@implementation MenuViewController

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
    if (self.viewControllers.count > 0) {
        [self popViewControllerAnimated:YES];
        return;
    }
    else {
        [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
    }
}

- (void)renderSubviews
{
    [self.backButton removeFromSuperview];
    
    for (UIView *view in self.menuButtons)
        [view removeFromSuperview];
    
    for (UIView *view in self.seperatorsH)
        [view removeFromSuperview];
    
    for (UIView *view in self.seperatorsV)
        [view removeFromSuperview];
    
    CGFloat numberOfButtons = kHorizontalGridNumber * kVerticalGridNumber;
    NSInteger numberOfRows = kHorizontalGridNumber;
    self.view.backgroundColor = tcolor(BackgroundColor);
    NSInteger startY = (OSVER >= 7)?20:0;
    CGSize s = self.view.frame.size;
    CGFloat backSpacing = 8.f;
    CGFloat buttonSize = 44.0f;
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(s.width - buttonSize - backSpacing, startY, buttonSize, buttonSize)];
    //UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-buttonSize-backSpacing,startY,buttonSize,buttonSize)];
    backButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    backButton.titleLabel.font = iconFont(23);
    [backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.transform = CGAffineTransformMakeRotation(M_PI);
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    
    
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0,startY,self.view.bounds.size.width-2*kGridMargin,self.view.bounds.size.height-startY)];
    
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 294, 392)];
    
    CGFloat gridWidth = self.gridView.bounds.size.width;
    CGFloat gridItemWidth = gridWidth / kVerticalGridNumber;
//    CGRectSetHeight(self.gridView, numberOfRows * gridItemWidth);
    
    CGFloat gridHeight = self.gridView.bounds.size.height;
    CGFloat numberOfGrids = gridHeight / gridItemWidth;
    
    self.seperatorsV = [NSMutableArray array];
    for (NSInteger i = 1; i < kVerticalGridNumber; i++) {
        UIView *verticalSeperatorView = [self seperatorWithSize:gridHeight - (kSeperatorMargin * 2) vertical:YES];
        verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, gridItemWidth * i, kSeperatorMargin);
        [self.gridView addSubview:verticalSeperatorView];
        [self.seperatorsV addObject:verticalSeperatorView];
    }
    
    self.seperatorsH = [NSMutableArray array];
    for (NSInteger i = 1; i < numberOfRows; i++) {
        UIView *horizontalSeperatorView = [self seperatorWithSize:gridWidth - (kSeperatorMargin * 2) vertical:NO];
        horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,kSeperatorMargin, gridHeight/numberOfGrids*i);
        [self.gridView addSubview:horizontalSeperatorView];
        [self.seperatorsH addObject:horizontalSeperatorView];
    }
    
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
    self.syncLabel.textColor = tcolor(TextColor);
    [self.gridView addSubview:self.syncLabel];
    [self updateSchemeButton];
    [self changedIsPlus];

}

-(void)updateSchemeButton
{
    //BOOL isDarkTheme = (THEMER.currentTheme == ThemeDark);
    NSString *normalTitle = [self stringForMenuButton:KPMenuButtonScheme highlighted:YES];
    NSString *highlightTitle = [self stringForMenuButton:KPMenuButtonScheme highlighted:NO];
    [self.schemeButton.iconLabel setTitle:normalTitle forState:UIControlStateNormal];
    
    [self.schemeButton.iconLabel setTitle:highlightTitle forState:UIControlStateHighlighted];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.syncLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.syncLabel.textAlignment = NSTextAlignmentCenter;
    self.syncLabel.backgroundColor = CLEAR;
    self.syncLabel.font = KP_REGULAR(16);
    [self updateSyncLabel];
    
    [self renderSubviews];
    
    self.menuPanning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];

    UIView *panningView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - kGridMargin, 0, kGridMargin, self.view.bounds.size.height)];
    [panningView addGestureRecognizer:self.menuPanning];
    [self.view addSubview:panningView];
    notify(@"changed isPlus", changedIsPlus);
    notify(@"updated sync",updateSyncLabel);
    notify(@"changed theme", changedTheme);
    
}

-(void)updateSyncLabel
{
    NSDate *lastSync = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncLocalDate"];
    NSString *timeString = @"Never";
    if (lastSync) {
        timeString = [UtilityClass readableTime:lastSync showTime:YES];
    }
    self.syncLabel.text = [NSString stringWithFormat:@"Last sync: %@",timeString];
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

-(void)popViewControllerAnimated:(BOOL)animated{
    NSInteger level = self.viewControllers.count;
    UIViewController *poppingViewController = [self.viewControllers lastObject];
    
    [poppingViewController removeFromParentViewController];
    
    UIView *showingView = (level == 1) ? self.gridView : [(UIViewController*)[self.viewControllers objectAtIndex:level-1] view];
    [UIView animateWithDuration:0.1 animations:^{
        poppingViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        showingView.alpha = 0;
        if(level == 1){
            [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
            [self.backButton setTitle:iconString(@"back") forState:UIControlStateHighlighted];
        }
        [UIView animateWithDuration:0.2 animations:^{
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                showingView.alpha = 1;
                
            }];
        }];
    }];
    [self.viewControllers removeLastObject];
    [self.view setNeedsLayout];
}

-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    NSInteger level = self.viewControllers.count;
    
    [self addChildViewController:viewController];
    UIView *hidingView = (level == 0) ? self.gridView : [(UIViewController*)[self.viewControllers lastObject] view];
    [UIView animateWithDuration:0.1 animations:^{
        hidingView.alpha = 0;
        if(level == 0){
            [self.backButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
            [self.backButton setTitle:iconString(@"roundCloseFull") forState:UIControlStateHighlighted];
        }
        } completion:^(BOOL finished) {
        viewController.view.alpha = 0;
        viewController.view.frame = self.view.bounds;
        CGRectSetHeight(viewController.view,viewController.view.bounds.size.height-44);
        CGRectSetY(viewController.view, 44);
        [self.view addSubview:viewController.view];
        [UIView animateWithDuration:0.2 animations:^{
        
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                viewController.view.alpha = 1;
            }];
        }];
    }];
    [self.viewControllers addObject:viewController];
}

-(void)pressedMenuButton:(MenuButton*)sender{
    
    KPMenuButtons button = [self buttonForTag:sender.tag];
    switch (button) {
        case KPMenuButtonNotifications:{
            
            BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
            UIColor *lampColor = hasNotificationsOn ? kLampOffColor : kLampOnColor;
            NSNumber *newSettingValue = hasNotificationsOn ? @NO : @YES;
            if (hasNotificationsOn) {
                KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Turn off notification" message:@"Are you sure you no longer want to receive alarms and reminders?" block:^(BOOL succeeded, NSError *error) {
                    [BLURRY dismissAnimated:YES];
                    if(succeeded){
                        [kSettings setValue:newSettingValue forSetting:SettingNotifications];
                        [sender setLampColor:lampColor];
                    }
                }];
                BLURRY.blurryTopColor = kSettingsBlurColor;
                [BLURRY showView:alert inViewController:self];
            }
            else{
                [kSettings setValue:newSettingValue forSetting:SettingNotifications];
                [sender setLampColor:lampColor];
            }
            
            break;
        }
        case KPMenuButtonLocation:{
            BOOL hasLocationOn = [(NSNumber*)[kSettings valueForSetting:SettingLocation] boolValue];
            if(!hasLocationOn && ![kUserHandler isPlus]){
                [ANALYTICS pushView:@"Location plus popup"];
                [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Location in Settings"}];
                PlusAlertView *alert = [PlusAlertView alertWithFrame:self.view.bounds message:@"Location reminders is a Swipes Plus feature. Get reminded at the right place and time." block:^(BOOL succeeded, NSError *error) {
                    [ANALYTICS popView];
                    [BLURRY dismissAnimated:!succeeded];
                    if(succeeded){
                        [ROOT_CONTROLLER upgrade];
                    }
                }];
                alert.shouldRemove = NO;
                BLURRY.blurryTopColor = kSettingsBlurColor;
                [BLURRY showView:alert inViewController:self];
            }
            else{
                UIColor *lampColor = hasLocationOn ? kLampOffColor : kLampOnColor;
                NSNumber *newSettingValue = hasLocationOn ? @NO : @YES;
                if(hasLocationOn){
                    KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Turn off location" message:@"Location reminders won't be working." block:^(BOOL succeeded, NSError *error) {
                        [BLURRY dismissAnimated:YES];
                        if(succeeded){
                            [NOTIHANDLER stopLocationServices];
                            [kSettings setValue:newSettingValue forSetting:SettingLocation];
                            [sender setLampColor:lampColor];
                        }
                    }];
                    BLURRY.blurryTopColor = kSettingsBlurColor;
                    [BLURRY showView:alert inViewController:self];
                }
                else{
                    StartLocationResult result = [NOTIHANDLER startLocationServices];
                    if(result == LocationStarted){
                        [kSettings setValue:newSettingValue forSetting:SettingLocation];
                        [sender setLampColor:lampColor];
                    }
                }
            }
            break;
        }
        case KPMenuButtonSnoozes:{
            SnoozesViewController *snoozeVC = [[SnoozesViewController alloc] init];
            [self pushViewController:snoozeVC animated:YES];
            break;
        }
        case KPMenuButtonWalkthrough:
            [ROOT_CONTROLLER walkthrough];
            break;
        case KPMenuButtonFeedback:{
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
                mailCont.mailComposeDelegate = self;
                [mailCont setToRecipients:@[@"support@swipesapp.com"]];
                [mailCont setSubject:@"Feedback for Swipes"];
                [mailCont setMessageBody:@"" isHTML:NO];
                [self presentViewController:mailCont animated:YES completion:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail was not setup" message:@"You can send us feedback to support@swipesapp.com. Thanks" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
        }
        case KPMenuButtonUpgrade:{
            if(!kUserHandler.isLoggedIn){
                KPAccountAlert *alert = [KPAccountAlert alertWithFrame:self.view.bounds message:@"Register for Swipes to safely back up your data and get Swipes Plus" block:^(BOOL succeeded, NSError *error) {
                    [BLURRY dismissAnimated:YES];
                    if(succeeded){
                        [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
                    }
                    
                }];
                BLURRY.blurryTopColor = kSettingsBlurColor;
                [BLURRY showView:alert inViewController:self];
                return;
            }
            else if(kUserHandler.isPlus){
                KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Manage subscription" message:@"Open App Store to manage your subscription?" block:^(BOOL succeeded, NSError *error) {
                    [BLURRY dismissAnimated:YES];
                    if(succeeded){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"]];
                    }
                }];
                BLURRY.blurryTopColor = kSettingsBlurColor;
                [BLURRY showView:alert inViewController:self];
                
                return;
            }
            else{
                [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Settings"}];
                [ROOT_CONTROLLER upgrade];
            }
            break;
        }
        case KPMenuButtonPolicies:{
            NSString *title = @"Policies";
            NSString *message = @"Do you want to open our\r\npolicies for Swipes?";
            NSString *url = @"http://swipesapp.com/policies.pdf";
            KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:title message:message block:^(BOOL succeeded, NSError *error) {
                [BLURRY dismissAnimated:YES];
                if(succeeded){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
                }
            }];
            BLURRY.blurryTopColor = kSettingsBlurColor;
            [BLURRY showView:alert inViewController:self];
            break;
        }
        case KPMenuButtonLogout:{
            if(!kUserHandler.isLoggedIn){
                [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
                return;
            }
            KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Log out" message:@"Are you sure you want to log out of your account?" block:^(BOOL succeeded, NSError *error) {
                [BLURRY dismissAnimated:YES];
                if(succeeded){
                    [ROOT_CONTROLLER logOut];
                    [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
                }
            }];
            BLURRY.blurryTopColor = kSettingsBlurColor;
            [BLURRY showView:alert inViewController:self];
            break;
        }
        case KPMenuButtonSync:{
            CABasicAnimation *rotate =
            [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rotate.byValue = @(M_PI*2); // Change to - angle for counter clockwise rotation
            rotate.duration = 0.5;
            
            [sender.iconLabel.layer addAnimation:rotate
                                          forKey:@"myRotationAnimation"];
            [KPCORE synchronizeForce:YES async:YES];
            break;
        }
        case KPMenuButtonScheme:{
            [THEMER changeTheme];
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

-(void)changedIsPlus{
    UIButton *upgradeButton = (UIButton*)[self.gridView viewWithTag:[self tagForButton:KPMenuButtonUpgrade]];
    UIButton *locationButton = (UIButton *)[self.gridView viewWithTag:[self tagForButton:KPMenuButtonLocation]];
    if(locationButton){
        locationButton.hidden = !kUserHandler.isPlus;
    }
    
    if(upgradeButton){
        [upgradeButton setTitle:[self titleForMenuButton:KPMenuButtonUpgrade] forState:UIControlStateNormal];
    }
}

-(NSString *)titleForMenuButton:(KPMenuButtons)button{
    NSString *title;
    switch (button) {
        case KPMenuButtonNotifications:
            title = @"Notifications";
            break;
        case KPMenuButtonLocation:
            title = @"Location";
            break;
        case KPMenuButtonWalkthrough:
            title = @"Walkthrough";
            break;
        case KPMenuButtonFeedback:
            title = @"Feedback";
            break;
        case KPMenuButtonSnoozes:
            title = @"Snoozes";
            break;
        case KPMenuButtonUpgrade:{
            title = (kUserHandler.isPlus) ? @"Manage" : @"Upgrade";
            break;
        }
        case KPMenuButtonPolicies:
            title= @"Policies";
            break;
        case KPMenuButtonSync:
            title = @"Sync";
            break;
        case KPMenuButtonLogout:
            title = (kUserHandler.isLoggedIn) ? @"Logout" : @"Account";
            break;
        case KPMenuButtonScheme:
            title = @"Theme";
            break;
    }
    return title;
}
-(NSString *)stringForMenuButton:(KPMenuButtons)button highlighted:(BOOL)highlighted{
    NSString *imageString;
    switch (button) {
        case KPMenuButtonNotifications:
            imageString = @"settingsNotification";
            break;
        case KPMenuButtonLocation:
            imageString = @"scheduleLocation";
            break;
        case KPMenuButtonWalkthrough:
            imageString = @"settingsWalkthrough";
            break;
        case KPMenuButtonFeedback:
            imageString = @"settingsFeedback";
            break;
        case KPMenuButtonSnoozes:
            imageString = @"later";
            break;
        case KPMenuButtonUpgrade:
            imageString = @"settingsPlusFull";
            break;
        case KPMenuButtonPolicies:
            imageString = @"settingsPolicy";
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
    if (button == KPMenuButtonUpgrade && highlighted)
        imageString = @"settingsPlus";
    return iconString(imageString);
}

- (CGRect) frameForButton:(KPMenuButtons)button
{
    CGFloat width = self.gridView.frame.size.width / kVerticalGridNumber - (2 * kGridButtonPadding);
    CGFloat x = ((button - 1) % kVerticalGridNumber) * self.gridView.frame.size.width / kVerticalGridNumber + kGridButtonPadding;
    CGFloat y = floor((button - 1) / kVerticalGridNumber) * self.gridView.frame.size.width / kVerticalGridNumber + kGridButtonPadding;
    return CGRectMake(x, y, width, width);
}
-(void)longPress:(UILongPressGestureRecognizer*)recognizer{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [UTILITY confirmBoxWithTitle:@"Hard sync" andMessage:@"This will send all data and can take some time" block:^(BOOL succeeded, NSError *error) {
            if(succeeded)
                [KPCORE hardSync];
        }];
    }
}

-(UIButton*)buttonForMenuButton:(KPMenuButtons)menuButton{
    MenuButton *button = [[MenuButton alloc] initWithFrame:[self frameForButton:menuButton] title:[self titleForMenuButton:menuButton]];
    button.iconLabel.titleLabel.font = iconFont(41);
    [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateHighlighted];
    [button.iconLabel setTitle:[self stringForMenuButton:menuButton highlighted:NO] forState:UIControlStateNormal];
    [button.iconLabel setTitle:[self stringForMenuButton:menuButton highlighted:YES] forState:UIControlStateHighlighted];
    if(menuButton == KPMenuButtonUpgrade){
        [button.iconLabel setTitleColor:tcolor(LaterColor) forState:UIControlStateNormal];
        [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateHighlighted];
    }
    if(menuButton == KPMenuButtonSync){
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longPress];
    }
    if(menuButton == KPMenuButtonNotifications || menuButton == KPMenuButtonLocation){
        KPSettings setting = (menuButton == KPMenuButtonNotifications) ? SettingNotifications : SettingLocation;
        BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:setting] boolValue];
        UIColor *lampColor = hasNotificationsOn ? kLampOnColor : kLampOffColor;
        [button setLampColor:lampColor];
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
//    if (!_forbidLayout)
//        [self renderSubviews];
//    [self.view explainSubviews];
    
    CGFloat numberOfButtons = kHorizontalGridNumber * kVerticalGridNumber;
    NSInteger numberOfRows = kHorizontalGridNumber;
    self.view.backgroundColor = tcolor(BackgroundColor);
    NSInteger startY = (OSVER >= 7) ? 20 : 0;
    
    CGFloat gridWidth = self.gridView.bounds.size.width;
    CGFloat gridItemWidth = gridWidth / kVerticalGridNumber;
    
    CGFloat gridHeight = self.gridView.bounds.size.height;
    CGFloat numberOfGrids = gridHeight / gridItemWidth;
    
    if (_seperatorsV && (_seperatorsV.count > kVerticalGridNumber - 2)) {
        for (NSInteger i = 1; i < kVerticalGridNumber; i++) {
            UIView *verticalSeperatorView = _seperatorsV[i - 1];
            verticalSeperatorView.frame = CGRectMake(gridItemWidth * i, kSeperatorMargin, SEPERATOR_WIDTH, gridHeight - (kSeperatorMargin * 2));
        }
    }
    
    if (_seperatorsH && (_seperatorsH.count > numberOfRows - 2)) {
        for (NSInteger i = 1; i < numberOfRows; i++) {
            UIView *horizontalSeperatorView = _seperatorsH[i - 1];
            horizontalSeperatorView.frame = CGRectMake(kSeperatorMargin, gridHeight/numberOfGrids*i, gridWidth - (kSeperatorMargin * 2), SEPERATOR_WIDTH);
        }
    }
    
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
    self.backButton.frame = CGRectMake(s.width - buttonSize - backSpacing, startY, buttonSize, buttonSize);
}

@end
