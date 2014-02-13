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
#import "RESideMenu.h"
#import "KPBlurry.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MenuButton.h"
#import "SettingsHandler.h"
#import "SnoozesViewController.h"
#import "AnalyticsHandler.h"
#import "UserHandler.h"

#import "KPParseCoreData.h"
#import "PlusAlertView.h"

#define kSettingsBlurColor retColor(gray(230, 0.5),gray(50, 0.4))
#define kMenuButtonStartTag 4123
#define kLampOnColor tcolor(DoneColor)
#define kLampOffColor tcolor(BackgroundColor)

#define kSeperatorMargin 0
#define kGridMargin valForScreen(15,10)
#define kVerticalGridNumber 3
#define kHorizontalGridNumber 4
#define kGridButtonPadding 0
@interface MenuViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic) IBOutletCollection(UIView) NSArray *seperators;
@property (nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) NSMutableArray *viewControllers;

@property (nonatomic) UIView *gridView;
@property (nonatomic) UILabel *syncLabel;
@property (nonatomic) UIPanGestureRecognizer *menuPanning;
@end

@implementation MenuViewController
-(NSMutableArray *)viewControllers{
    if(!_viewControllers) _viewControllers = [NSMutableArray array];
    return _viewControllers;
}
-(KPMenuButtons)buttonForTag:(NSInteger)tag{
    return tag - kMenuButtonStartTag;
}
-(NSInteger)tagForButton:(KPMenuButtons)button{
    return kMenuButtonStartTag + button;
}
-(void)pressedBack:(UIButton*)backButton{
    if(self.viewControllers.count > 0){
        [self popViewControllerAnimated:YES];
        return;
    }
    else [kSideMenu hide];
}
-(void)renderSubviews{
    [self.backButton removeFromSuperview];
    for(UIView *view in self.menuButtons)
        [view removeFromSuperview];
    for(UIView *view in self.seperators)
        [view removeFromSuperview];
    
    CGFloat numberOfButtons = kHorizontalGridNumber * kVerticalGridNumber;
    NSInteger numberOfRows = kHorizontalGridNumber;
    self.view.backgroundColor = tcolor(BackgroundColor);
    NSInteger startY = (OSVER >= 7)?20:0;
    CGFloat backSpacing = 8.f;
    CGFloat buttonSize = 44.0f;
    
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-buttonSize-backSpacing,startY,buttonSize,buttonSize)];
    [backButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.transform = CGAffineTransformMakeRotation(M_PI);
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    
    
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0,startY,self.view.bounds.size.width-2*kGridMargin,self.view.bounds.size.height-startY)];
    
    
    CGFloat gridWidth = self.gridView.bounds.size.width;
    CGFloat gridItemWidth = self.gridView.bounds.size.width/kVerticalGridNumber;
    CGRectSetHeight(self.gridView, numberOfRows*gridItemWidth);
    
    CGFloat gridHeight = self.gridView.bounds.size.height;
    CGFloat numberOfGrids = gridHeight / gridItemWidth;
    
    NSMutableArray *seperatorArray = [NSMutableArray array];
    
    for(NSInteger i = 1 ; i < kVerticalGridNumber ; i++){
        UIView *verticalSeperatorView = [self seperatorWithSize:gridHeight-(kSeperatorMargin*2) vertical:YES];
        verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, self.gridView.bounds.size.width/kVerticalGridNumber*i,kSeperatorMargin);
        [self.gridView addSubview:verticalSeperatorView];
        [seperatorArray addObject:verticalSeperatorView];
    }
    for(NSInteger i = 1 ; i < numberOfRows ; i++){
        UIView *horizontalSeperatorView = [self seperatorWithSize:gridWidth-(kSeperatorMargin*2) vertical:NO];
        horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,kSeperatorMargin, gridHeight/numberOfGrids*i);
        [self.gridView addSubview:horizontalSeperatorView];
        [seperatorArray addObject:horizontalSeperatorView];
    }
    self.seperators = [seperatorArray copy];
    UIButton *actualButton;
    NSMutableArray *menuButtons = [NSMutableArray array];
    for(NSInteger i = 1 ; i <= numberOfButtons ; i++){
        KPMenuButtons button = i;
        actualButton = [self buttonForMenuButton:button];
        [self.gridView addSubview:actualButton];
        [menuButtons addObject:actualButton];
    }
    self.menuButtons = [menuButtons copy];
    [self.view addSubview:self.gridView];
    self.gridView.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height)/2);
    self.syncLabel.frame = CGRectMake(0, CGRectGetMaxY(self.gridView.bounds)+ 10, self.gridView.frame.size.width, 20);
    self.syncLabel.textColor = tcolor(TextColor);
    [self.gridView addSubview:self.syncLabel];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.gridView.bounds)+ 10, self.gridView.frame.size.width, 20)];
    self.syncLabel.textAlignment = NSTextAlignmentCenter;
    self.syncLabel.backgroundColor = CLEAR;
    self.syncLabel.font = KP_REGULAR(16);
    [self updateSyncLabel];
    
    [self renderSubviews];
    
    self.menuPanning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];

    UIView *panningView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-kGridMargin, 0, kGridMargin, self.view.bounds.size.height)];
    [panningView addGestureRecognizer:self.menuPanning];
    [self.view addSubview:panningView];
    notify(@"changed isPlus", changedIsPlus);
    notify(@"updated sync",updateSyncLabel);
}
-(void)updateSyncLabel{
    NSDate *lastSync = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncLocalDate"];
    NSString *timeString = @"Never";
    if(lastSync){
        timeString = [UtilityClass readableTime:lastSync showTime:YES];
    }
    NSString *syncOrBackup = kUserHandler.isPlus ? @"sync" : @"backup";
    self.syncLabel.text = [NSString stringWithFormat:@"Last %@: %@",syncOrBackup,timeString];
}
-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    [kSideMenu panGestureRecognized:sender];
}
-(UIView*)seperatorWithSize:(CGFloat)size vertical:(BOOL)vertical{
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
            [self.backButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        }
        [UIView animateWithDuration:0.2 animations:^{
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                showingView.alpha = 1;
                
            }];
        }];
    }];
    [self.viewControllers removeLastObject];
}

-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated{
    NSInteger level = self.viewControllers.count;
    
    [self addChildViewController:viewController];
    UIView *hidingView = (level == 0) ? self.gridView : [(UIViewController*)[self.viewControllers lastObject] view];
    [UIView animateWithDuration:0.1 animations:^{
        hidingView.alpha = 0;
        if(level == 0) [self.backButton setImage:[UIImage imageNamed:timageStringBW(@"round_cross")] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        viewController.view.alpha = 0;
        viewController.view.frame = self.view.bounds;
        CGRectSetHeight(viewController.view,viewController.view.bounds.size.height-44);
        CGRectSetY(viewController.view, 44);
        [self.view addSubview:viewController.view];
        [UIView animateWithDuration:0.2 animations:^{
        } completion:^(BOOL finished) {
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
            if(hasNotificationsOn){
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
            if(kUserHandler.isPlus){
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
            [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Settings"}];
            [ROOT_CONTROLLER upgrade];
            break;
        }
        case KPMenuButtonTerms:
        case KPMenuButtonPolicy:{
            NSString *title = (button == KPMenuButtonTerms) ? @"Terms of use" : @"Privacy Policy";
            NSString *message = (button == KPMenuButtonTerms) ? @"Do you want to open our\r\nterms of use?" : @"Do you want to open our\r\nprivacy policy?";
            NSString *url = (button == KPMenuButtonTerms) ? @"http://swipesapp.com/termsofuse.pdf" : @"http://swipesapp.com/privacypolicy.pdf";
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

            KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Log out" message:@"Are you sure you want to log out of your account?" block:^(BOOL succeeded, NSError *error) {
                [BLURRY dismissAnimated:YES];
                if(succeeded){
                    [ROOT_CONTROLLER logOut];
                }
            }];
            BLURRY.blurryTopColor = kSettingsBlurColor;
            [BLURRY showView:alert inViewController:self];
            break;
        }
        case KPMenuButtonSync:{
            if(!kUserHandler.isPlus){
                [ANALYTICS pushView:@"Sync plus popup"];
                [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Sync in Settings"}];
                PlusAlertView *alert = [PlusAlertView alertWithFrame:self.view.bounds message:@"Synchronization is a Swipes Plus feature. Keep your tasks in sync with an app for web and iPad." block:^(BOOL succeeded, NSError *error) {
                    [ANALYTICS popView];
                    [BLURRY dismissAnimated:YES];
                    if(succeeded){
                        [ROOT_CONTROLLER upgrade];
                    }
                }];
                BLURRY.blurryTopColor = kSettingsBlurColor;
                [BLURRY showView:alert inViewController:self];
            }
            else{
                CABasicAnimation *rotate =
                [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                rotate.byValue = @(M_PI*2); // Change to - angle for counter clockwise rotation
                rotate.duration = 1.0;
                
                [sender.iconImageView.layer addAnimation:rotate
                                        forKey:@"myRotationAnimation"];
                [KPCORE synchronizeForce:YES async:YES];
            }
            break;
        }
        case KPMenuButtonScheme:{
            [THEMER changeTheme];
            [ROOT_CONTROLLER resetRoot];
            [self renderSubviews];
            break;
        }
        default:
            break;
    }
}
-(void)changedIsPlus{
    UIButton *upgradeButton = (UIButton*)[self.gridView viewWithTag:[self tagForButton:KPMenuButtonUpgrade]];
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
        case KPMenuButtonTerms:
            title = @"Terms";
            break;
        case KPMenuButtonPolicy:
            title= @"Policy";
            break;
        case KPMenuButtonSync:
            title = @"Sync";
            break;
        case KPMenuButtonLogout:
            title = @"Logout";
            break;
        case KPMenuButtonScheme:
            title = @"Theme";
            break;
    }
    return title;
}
-(UIImage *)imageForMenuButton:(KPMenuButtons)button highlighted:(BOOL)highlighted{
    NSString *imageString;
    switch (button) {
        case KPMenuButtonNotifications:
            imageString = timageStringBW(@"menu_notifications");
            break;
        case KPMenuButtonLocation:
            imageString = timageStringBW(@"schedule_image_location");
            break;
        case KPMenuButtonWalkthrough:
            imageString = timageStringBW(@"menu_walkthrough");
            break;
        case KPMenuButtonFeedback:
            imageString = timageStringBW(@"menu_support");
            break;
        case KPMenuButtonSnoozes:
            imageString = timageStringBW(@"menu_snoozes");
            break;
        case KPMenuButtonUpgrade:
            imageString = @"menu_pro";
            break;
        case KPMenuButtonTerms:
        case KPMenuButtonPolicy:
            imageString = timageStringBW(@"menu_policy");
            break;
        case KPMenuButtonSync:
            imageString = timageStringBW(@"menu_sync");
            break;
        case KPMenuButtonLogout:
            imageString = timageStringBW(@"menu_logout");
            break;
        case KPMenuButtonScheme:
            imageString = timageStringBW(@"menu_support");
            break;
    }
    if(highlighted) imageString = [imageString stringByAppendingString:@"-high"];
    //if(button == KPMenuButtonUpgrade && highlighted) imageString = @"menu_pro";
    return [UIImage imageNamed:imageString];
}
-(CGRect)frameForButton:(KPMenuButtons)button{
    CGFloat width = self.gridView.frame.size.width/kVerticalGridNumber-(2*kGridButtonPadding);
    CGFloat x = ((button-1) % kVerticalGridNumber) * self.gridView.frame.size.width/kVerticalGridNumber + kGridButtonPadding;
    
    CGFloat y = floor((button-1) / kVerticalGridNumber) * self.gridView.frame.size.width/kVerticalGridNumber + kGridButtonPadding;
    return CGRectMake(x, y, width, width);
}

-(UIButton*)buttonForMenuButton:(KPMenuButtons)menuButton{
    MenuButton *button = [[MenuButton alloc] initWithFrame:[self frameForButton:menuButton] title:[self titleForMenuButton:menuButton] image:[self imageForMenuButton:menuButton highlighted:NO] highlightedImage:[self imageForMenuButton:menuButton highlighted:YES]];
    if(menuButton == KPMenuButtonNotifications || menuButton == KPMenuButtonLocation){
        BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
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

@end
