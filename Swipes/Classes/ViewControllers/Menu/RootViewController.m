//
//  RootViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 25/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "RootViewController.h"
#import "FacebookCommunicator.h"


#import "ScheduleViewController.h"
#import "TodayViewController.h"
#import "DoneViewController.h"

#import "LoginViewController.h"
#import "AnalyticsHandler.h"

#import "MenuViewController.h"
#import "KPBlurry.h"
#import "WalkthroughViewController.h"
#import "UIColor+Utilities.h"
#import "PlusAlertView.h"
#import "UpgradeViewController.h"
#import "CoreSyncHandler.h"

#import "SettingsHandler.h"
#import "KPOverlay.h"

#import "KPToDo.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>

#import "PaymentHandler.h"


#import "KPAlert.h"
#import "UtilityClass.h"
#import "HintHandler.h"
#import "MMDrawerVisualState.h"
#import "KPAccountAlert.h"
#import "UserHandler.h"
#import "ShareViewController.h"

@interface RootViewController () <UINavigationControllerDelegate,WalkthroughDelegate,KPBlurryDelegate,UpgradeViewControllerDelegate,MFMailComposeViewControllerDelegate,LoginViewControllerDelegate,SyncDelegate, HintHandlerDelegate>

@property (nonatomic,strong) MenuViewController *settingsViewController;

@property (nonatomic) NSDate *lastClose;
@property (nonatomic) KPMenu currentMenu;

@end

@implementation RootViewController
#pragma mark - Properties

-(KPSegmentedViewController *)menuViewController{
    if(!_menuViewController){
        ScheduleViewController *vc1 = [[ScheduleViewController alloc] init];
        TodayViewController *vc2 = [[TodayViewController alloc] init];
        DoneViewController *vc3 = [[DoneViewController alloc] init];
        vc1.view.autoresizingMask = vc2.view.autoresizingMask = vc3.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3]];
        _menuViewController = menuViewController;
    }
    return _menuViewController;
}

-(void)blurryWillShow:(KPBlurry *)blurry{
    self.lockSettings = YES;
}
-(void)blurryDidHide:(KPBlurry *)blurry{
    if(self.currentMenu != KPMenuLogin) self.lockSettings = NO;
}


-(void)fetchDataFromFacebook{
    __block NSString *requestPath = @"me?fields=email,gender";
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [FBC addRequest:request write:NO permissions:nil block:^BOOL(FBReturnType status, id result, NSError *error) {
        NSLog(@"fetched");
        PFUser *user = kCurrent;
        if(error) {
            return NO;
        }
        else{
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            NSString *email = [userData objectForKey:@"email"];
            
            if(email){
                [user setObject:email forKey:@"email"];
            }
            NSString *gender = [userData objectForKey:@"gender"];
            if(gender) [user setObject:gender forKey:@"gender"];
            [user saveEventually];
            if(email) [user setObject:email forKey:@"username"];
            [user saveEventually];
            [ANALYTICS updateIdentity];
        }
        return NO;
    }];
}
-(void)didLoginUser:(PFUser*)user{
    [self.settingsViewController renderSubviews];
    voidBlock block = ^{
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
        NSDictionary *options = @{@"Time since real install" : [NSString stringWithFormat:@"%li days",(long)[[NSDate date] daysAfterDate:[attrs fileCreationDate]]]};
        if(user.isNew) {
            [ANALYTICS tagEvent:@"Signed Up" options:options];
        }
        else{
            [ANALYTICS tagEvent:@"Logged In" options:options];
        }
        if ([PFFacebookUtils isLinkedWithUser:user]){
            if (!user.email){
                NSLog(@"fetching");
                [self fetchDataFromFacebook];
            }
        }
        else{
            
        }
        [ANALYTICS updateIdentity];
        [self changeToMenu:KPMenuHome animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logged in" object:self];
    };
    if([[NSUserDefaults standardUserDefaults] boolForKey:isTryingString]){
        [UTILITY confirmBoxWithTitle:@"Keep data" andMessage:@"Do you want to keep the data from the test period?" block:^(BOOL succeeded, NSError *error) {
            if(!succeeded) [KPCORE clearAndDeleteData];
            block();
        }];
    }
    else{
        if(user.isNew) [[CoreSyncHandler sharedInstance] seedObjectsSave:YES];
        block();
    }
    
}

// Sent to the delegate when a PFUser is logged in.
- (void)loginViewController:(LoginViewController *)logInController didLoginUser:(PFUser *)user
{
    [self didLoginUser:user];
}

-(void)walkthrough:(WalkthroughViewController *)walkthrough didFinishSuccesfully:(BOOL)successfully
{
    [ANALYTICS popView];
    [walkthrough removeFromParentViewController];
    [OVERLAY popViewAnimated:YES];
}

#pragma mark - Public API
-(void)changeToMenu:(KPMenu)menu animated:(BOOL)animated
{
    UIViewController *viewController;
    switch(menu) {
        case KPMenuLogin:{
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.delegate = self;
            self.lockSettings = YES;
            viewController = loginVC;
            break;
        }
        case KPMenuHome:
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(triggerWelcome) userInfo:nil repeats:NO];
            self.lockSettings = NO;
            viewController = self.menuViewController;
            break;
    }
    self.viewControllers = @[self.drawerViewController];
    self.currentMenu = menu;
    if(self.drawerViewController.openSide == MMDrawerSideLeft)
        [self.drawerViewController closeDrawerAnimated:YES completion:nil];
    
    //CGRectSetHeight(viewController.view,viewController.view.frame.size.height-100);
    //CGRectSetHeight(self.drawerViewController.view,viewController.view.frame.size.height-100);
    [self.drawerViewController setCenterViewController:viewController];
}

static RootViewController *sharedObject;
+(RootViewController *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[RootViewController allocWithZone:NULL] init];
    }
    return sharedObject;
}

-(void)logOut
{
    [PFUser logOut];
    [[CoreSyncHandler sharedInstance] clearAndDeleteData];
    [kUserHandler didLogout];
    [kHints reset];
    [self resetRoot];

}

-(void)resetRoot
{
    self.menuViewController = nil;
    [self setupAppearance];
    [self.settingsViewController renderSubviews];
    //[self.sideMenu hide];
    
}

-(void)proWithMessage:(NSString*)message
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [PlusAlertView alertInView:window message:message block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self upgrade];
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    NSString *event = @"Share tasks failed";
    if (result == MFMailComposeResultSent)
        event = @"Share tasks sent";
    NSArray *tasks = [[self.menuViewController currentViewController] selectedItems];
    [ANALYTICS tagEvent:event options:@{@"Number of Tasks":@(tasks.count)}];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)shareTasks:(NSArray*)tasks{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:@"Tasks to complete"];
        
        NSString *message = @"Tasks: \r\n";
        for(KPToDo *toDo in tasks){
            message = [message stringByAppendingFormat:@"◯ %@\r\n",toDo.title];
        }
        message = [message stringByAppendingString:@"\r\nSent with my Swipes – Task list made for High Achievers\r\nFree iPhone app - http://swipesapp.com"];
        [mailCont setMessageBody:message isHTML:NO];
        [self presentViewController:mailCont animated:YES completion:nil];
        [ANALYTICS tagEvent:@"Share tasks" options:@{@"Number of Tasks":@(tasks.count)}];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail was not setup" message:@"You can send us feedback to support@swipesapp.com. Thanks" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        [ANALYTICS tagEvent:@"Mail not available" options:nil];
    }
}

-(void)accountAlertWithMessage:(NSString *)message{
    if( !message )
        message = @"Register for Swipes to safely back up your data and get Swipes Plus";
    KPAccountAlert *alert = [KPAccountAlert alertWithFrame:self.view.bounds message:message block:^(BOOL succeeded, NSError *error) {
        [BLURRY dismissAnimated:YES];
        if(succeeded){
            [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
        }
        
    }];
    BLURRY.blurryTopColor = kSettingsBlurColor;
    [BLURRY showView:alert inViewController:self];
}
-(void)feedback{
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
}
-(void)upgrade{
    if(!kUserHandler.isLoggedIn){
        [self accountAlertWithMessage:nil];
        return;
    }
    
    [UTILITY popupWithTitle:@"Can't upgrade to Swipes Plus" andMessage:@"We're remaking our Plus version. Please send us your suggestions while waiting." buttonTitles:@[@"Cancel",@"Send suggestions",@"Restore Purchases"] block:^(NSInteger number, NSError *error) {
        if( number == 1){
            [ROOT_CONTROLLER feedback];
        }
        else if(number == 2){
            [[PaymentHandler sharedInstance] restoreWithBlock:^(NSError *error) {
                if(!error){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase restored" message:@"Your purchase has been restored. Welcome back!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occured" message:@"No purchases could be restored. Contact support@swipesapp.com for help." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];
                }
            }];
        }
    }];
    return;
}

-(void)walkthrough
{
    WalkthroughViewController *viewController = [[WalkthroughViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    [OVERLAY pushView:viewController.view animated:YES];
    [ANALYTICS pushView:@"Walkthrough"];
}

-(void)closedUpgradeViewController:(UpgradeViewController *)viewController
{
    [ANALYTICS popView];
    [viewController removeFromParentViewController];
    [OVERLAY popViewAnimated:YES];
}

-(void)openApp
{
    [kSettings refreshGlobalSettingsForce:NO];
    if(self.lastClose && [[NSDate date] isLaterThanDate:[self.lastClose dateByAddingMinutes:15]]){
        [OVERLAY popAllViewsAnimated:NO];
        [self resetRoot];
    }
    else if(self.lastClose) {
        [[[self menuViewController] currentViewController] update];
        [[[self menuViewController] currentViewController] deselectAllRows:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"opened app" object:self];
}

-(void)closeApp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closing app" object:self];
    self.lastClose = [NSDate date];
}

#pragma mark - Helping methods
#pragma mark - ViewController methods

-(void)setupAppearance{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if(!sharedObject)
        sharedObject = self;
    
    self.viewControllers = @[self.drawerViewController];
    
    if(!kCurrent){
        if([[NSUserDefaults standardUserDefaults] objectForKey:isTryingString]){
            [self changeToMenu:KPMenuHome animated:NO];
        }
        else{
            [kHints turnHintsOn:YES];
            [self changeToMenu:KPMenuLogin animated:NO];
        }
    }
    else
        [self changeToMenu:KPMenuHome animated:NO];
}

-(void)openIntegrationsWithHelper{
    [self.settingsViewController resetAndOpenIntegrations];
    if(self.drawerViewController.openSide != MMDrawerSideLeft){
        [self.drawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }
    
}

-(void)triggerEvernoteEvent{
    if(self.currentMenu == KPMenuHome){
        [kHints triggerHint:HintEvernote];
    }
}

-(void)hintHandler:(HintHandler *)hintHandler triggeredHint:(Hints)hint{
    if(hint == HintEvernote){
        [UTILITY popupWithTitle:@"Evernote Integration" andMessage:@"We've made a powerful integration with Evernote!" buttonTitles:@[@"Not now", @"Learn more"] block:^(NSInteger number, NSError *error) {
            if( number == 1){
                [self openIntegrationsWithHelper];
            }
        }];
        
    }
}

-(void)syncHandler:(CoreSyncHandler *)handler status:(SyncStatus)status userInfo:(NSDictionary *)userInfo error:(NSError *)error{
    /*switch (status) {
        case SyncStatusStarted:
            [self.notification displayNotificationWithMessage:@"Synchronizing..." completion:nil];
            break;
        case SyncStatusProgress:
            break;
        case SyncStatusSuccess:
            [self.notification displayNotificationWithMessage:@"Sync completed" forDuration:1.5];
            break;
        case SyncStatusError:{
            
            [self.notification displayNotificationWithMessage:@"Error syncing" forDuration:3.5];
            break;
        }
        default:
            break;
    }*/
}

-(void)tryoutapp{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:isTryingString]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isTryingString];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [KPCORE seedObjectsSave:YES];
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
        NSDictionary *options = @{@"Time since real install" : [NSString stringWithFormat:@"%li days",(long)[[NSDate date] daysAfterDate:[attrs fileCreationDate]]]};
        [ANALYTICS tagEvent:@"Trying out app" options:options];
    }
    
    [self changeToMenu:KPMenuHome animated:YES];
    
}


-(void)triggerWelcome{
    [kHints triggerHint:HintWelcome];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
    KPCORE.delegate = self;
    notify(@"changed theme", changedTheme);
    kHints.delegate = self;
    
    BLURRY.delegate = self;
    self.settingsViewController = [[MenuViewController alloc] init];
    self.drawerViewController = [[MMDrawerController alloc] initWithCenterViewController:self.menuViewController leftDrawerViewController:self.settingsViewController];
    self.drawerViewController.maximumLeftDrawerWidth = self.view.bounds.size.width;

    [self.drawerViewController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        UIViewController * sideDrawerViewController;
        if(drawerSide == MMDrawerSideLeft){
            sideDrawerViewController = drawerController.leftDrawerViewController;
        }
        else if(drawerSide == MMDrawerSideRight){
            sideDrawerViewController = drawerController.rightDrawerViewController;
        }
        [sideDrawerViewController.view setAlpha:percentVisible];
    }];
    
    [self.drawerViewController setShowsShadow:NO];
    [self.drawerViewController setShouldStretchDrawer:YES];
    [self.drawerViewController setAnimationVelocity:self.drawerViewController.maximumLeftDrawerWidth * 3];
    [self pushViewController:self.drawerViewController animated:NO];
    
    
    [self setupAppearance];
    
}
-(void)changedTheme{
   // [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}

@end
