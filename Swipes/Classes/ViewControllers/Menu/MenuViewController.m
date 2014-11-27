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
#import "HelpingViewController.h"
#import "NotificationsViewController.h"
#import "IntegrationsViewController.h"
#import "SnoozesViewController.h"
#import "AnalyticsHandler.h"
#import "UserHandler.h"
#import "KPAccountAlert.h"
#import "UIView+Utilities.h"
#import "EvernoteIntegration.h"

#import "CoreSyncHandler.h"
#import "PlusAlertView.h"
#import "NotificationHandler.h"


#define kMenuButtonStartTag 4123
#define kLampOnColor tcolor(DoneColor)
#define kLampOffColor tcolor(BackgroundColor)

#define kSeperatorMargin 0
#define kGridMargin valForScreen(15,10)
#define kVerticalGridNumber 3
#define kHorizontalGridNumber 3
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

-(void)reset{
    [self popAllViewControllers];
    [self renderSubviews];
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
    self.view.backgroundColor = gray(224,1);//tcolor(BackgroundColor);
    NSInteger startY = (OSVER >= 7)?20:0;
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
    
    
    
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0,startY,self.view.bounds.size.width-2*kGridMargin,self.view.bounds.size.height-startY)];
    
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 294, 304)];
    
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
        //[self pressedBack:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

-(void)updateSyncLabel
{
    NSDate *lastSync = [USER_DEFAULTS objectForKey:@"lastSyncLocalDate"];
    NSString *timeString = [LOCALIZE_STRING(@"never") capitalizedString];
    if (lastSync) {
        timeString = [UtilityClass readableTime:lastSync showTime:YES];
    }
    self.syncLabel.text = [NSString stringWithFormat:LOCALIZE_STRING(@"Last sync: %@"),timeString];
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

-(void)popAllViewControllers{
    [ANALYTICS clearViews];
    NSInteger numberOfVCs = self.viewControllers.count;
    for( NSInteger i = 0 ; i < numberOfVCs ; i++){
        [self popViewControllerAnimated:NO];
    }
}

-(void)popViewControllerAnimated:(BOOL)animated{
    NSInteger level = self.viewControllers.count;
    UIViewController *poppingViewController = [self.viewControllers lastObject];
    [ANALYTICS popView];
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
    [poppingViewController removeFromParentViewController];
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
        }
        completion:^(BOOL finished) {
            viewController.view.alpha = 0;
            viewController.view.frame = self.view.bounds;
            CGFloat startY = 20;
            CGFloat bottomPadding = 44+8;
            CGRectSetHeight(viewController.view,viewController.view.bounds.size.height-startY-bottomPadding);
            CGRectSetY(viewController.view, 20);
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
            NotificationsViewController *notifVC = [[NotificationsViewController alloc] init];
            [ANALYTICS pushView:@"Notifications Menu"];
            [self pushViewController:notifVC animated:YES];
            break;
        }
        case KPMenuButtonLocation:{
            BOOL hasLocationOn = [(NSNumber*)[kSettings valueForSetting:SettingLocation] boolValue];
            if(!hasLocationOn && ![kUserHandler isPlus]){
                PlusAlertView *alert = [PlusAlertView alertWithFrame:self.view.bounds message:@"Location reminders is a Swipes Plus feature. Get reminded at the right place and time." block:^(BOOL succeeded, NSError *error) {
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
                    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Turn off location") andMessage:LOCALIZE_STRING(@"Location reminders won't be working.") block:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            [NOTIHANDLER stopLocationServices];
                            [kSettings setValue:newSettingValue forSetting:SettingLocation];
                            [sender setLampColor:lampColor];
                        }
                    }];
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
            [ANALYTICS pushView:@"Snoozes Menu"];
            [self pushViewController:snoozeVC animated:YES];
            break;
        }
        case KPMenuButtonIntegrations:{
            IntegrationsViewController *integrationVC = [[IntegrationsViewController alloc] init];
            [ANALYTICS pushView:@"Integrations  Menu"];
            [self pushViewController:integrationVC animated:YES];
            break;
        }
        case KPMenuButtonHelp:{
            HelpingViewController *helpVC = [[HelpingViewController alloc] init];
            [ANALYTICS pushView:@"Help Menu"];
            [self pushViewController:helpVC animated:YES];
            break;
        }
        case KPMenuButtonUpgrade:{
            if(kUserHandler.isPlus){
                [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Manage subscription") andMessage:LOCALIZE_STRING(@"Open App Store to manage your subscription?") block:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"]];
                    }
                }];
                return;
            }
            else{
                [ROOT_CONTROLLER upgrade];
            }
            break;
        }
        case KPMenuButtonLogout:{
            if(!kUserHandler.isLoggedIn){
                [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
                return;
            }
            [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Log out") andMessage:LOCALIZE_STRING(@"Are you sure you want to log out of your account?") block:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [ROOT_CONTROLLER logOut];
                    [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
                }
            }];
            break;
        }
        case KPMenuButtonSync:{
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

-(void)resetAndOpenIntegrations{
    [self popAllViewControllers];
    IntegrationsViewController *integrationVC = [[IntegrationsViewController alloc] init];
    [ANALYTICS pushView:@"Integrations Menu"];
    [self pushViewController:integrationVC animated:NO];
    [integrationVC openHelperForIntegration:kEvernoteIntegration];
    
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

-(NSString *)titleForMenuButton:(KPMenuButtons)button
{
    NSString *title;
    switch (button) {
        case KPMenuButtonNotifications:
            title = LOCALIZE_STRING(@"Notifications");
            break;
        case KPMenuButtonLocation:
            title = LOCALIZE_STRING(@"Location");
            break;
        case KPMenuButtonHelp:
            title = LOCALIZE_STRING(@"Help");
            break;
        case KPMenuButtonSnoozes:
            title = LOCALIZE_STRING(@"Snoozes");
            break;
        case KPMenuButtonUpgrade:{
            title = (kUserHandler.isPlus) ? LOCALIZE_STRING(@"Manage") : LOCALIZE_STRING(@"Upgrade");
            break;
        }
        case KPMenuButtonSync:
            title = LOCALIZE_STRING(@"Sync");
            break;
        case KPMenuButtonLogout:
            title = (kUserHandler.isLoggedIn) ? LOCALIZE_STRING(@"Logout") : LOCALIZE_STRING(@"Account");
            break;
        case KPMenuButtonScheme:
            title = LOCALIZE_STRING(@"Theme");
            break;
        case KPMenuButtonIntegrations:
            title = LOCALIZE_STRING(@"Integrations");
    }
    return title;
}

-(NSString *)stringForMenuButton:(KPMenuButtons)button highlighted:(BOOL)highlighted
{
    NSString *imageString;
    switch (button) {
        case KPMenuButtonNotifications:
            imageString = @"settingsNotification";
            break;
        case KPMenuButtonLocation:
            imageString = @"scheduleLocation";
            break;
        case KPMenuButtonHelp:
            imageString = @"settingsFeedback";
            break;
        case KPMenuButtonSnoozes:
            imageString = @"settingsSchedule";
            break;
        case KPMenuButtonUpgrade:
            imageString = @"settingsPlusFull";
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
        case KPMenuButtonIntegrations:
            imageString = @"settingsIntegrations";
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

-(void)longPress:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Hard sync") andMessage:LOCALIZE_STRING(@"This will send all data and can take some time") block:^(BOOL succeeded, NSError *error) {
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
    if(menuButton == KPMenuButtonUpgrade){
        [button.iconLabel setTitleColor:tcolor(LaterColor) forState:UIControlStateNormal];
        [button.iconLabel setTitleColor:tcolor(TextColor) forState:UIControlStateHighlighted];
    }
    if(menuButton == KPMenuButtonSync){
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longPress];
    }
    if(menuButton == KPMenuButtonLocation){
        KPSettings setting = SettingLocation;
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
   
    CGFloat numberOfButtons = kHorizontalGridNumber * kVerticalGridNumber;
    NSInteger numberOfRows = kHorizontalGridNumber;
    self.view.backgroundColor = tcolor(BackgroundColor);
    
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
    self.backButton.frame = CGRectMake(s.width - buttonSize - backSpacing, s.height-buttonSize-backSpacing, buttonSize, buttonSize);
}

@end
