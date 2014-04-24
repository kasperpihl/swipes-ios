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
#import "KPParseCoreData.h"

#import "SettingsHandler.h"
#import "KPOverlay.h"

#import "KPToDo.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>

#import "CWStatusBarNotification.h"


#import "KPAlert.h"
#import "UtilityClass.h"
#import "HintHandler.h"
#import "MMDrawerVisualState.h"
#import "KPAccountAlert.h"
#import "UserHandler.h"
#import "ShareViewController.h"

@interface RootViewController () <UINavigationControllerDelegate,WalkthroughDelegate,KPBlurryDelegate,UpgradeViewControllerDelegate,MFMailComposeViewControllerDelegate,LoginViewControllerDelegate,SyncDelegate>

@property (nonatomic,strong) MenuViewController *settingsViewController;

@property (nonatomic) NSDate *lastClose;
@property (nonatomic) KPMenu currentMenu;
@property (nonatomic) CWStatusBarNotification *notification;
@end

@implementation RootViewController
#pragma mark - Properties

-(KPSegmentedViewController *)menuViewController{
    if(!_menuViewController){
        ScheduleViewController *vc1 = [[ScheduleViewController alloc] init];
        TodayViewController *vc2 = [[TodayViewController alloc] init];
        DoneViewController *vc3 = [[DoneViewController alloc] init];
        vc1.view.autoresizingMask = vc2.view.autoresizingMask = vc3.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
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
        if(user.isNew) {
            [ANALYTICS tagEvent:@"Signed Up" options:@{}];
        }
        else{
            [ANALYTICS tagEvent:@"Logged In" options:@{}];
        }
        if([PFFacebookUtils isLinkedWithUser:user]){
            if(!user.email){
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
        if(user.isNew) [[KPParseCoreData sharedInstance] seedObjectsSave:YES];
        block();
    }
    
}
// Sent to the delegate when a PFUser is logged in.
- (void)loginViewController:(LoginViewController *)logInController didLoginUser:(PFUser *)user {
    [self didLoginUser:user];
}
-(void)walkthrough:(WalkthroughViewController *)walkthrough didFinishSuccesfully:(BOOL)successfully{
    [ANALYTICS popView];
    [walkthrough removeFromParentViewController];
    [OVERLAY popViewAnimated:YES];
}
#pragma mark - Public API
-(void)changeToMenu:(KPMenu)menu animated:(BOOL)animated{
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
            [NSTimer scheduledTimerWithTimeInterval:1.4 target:self selector:@selector(triggerWelcome) userInfo:nil repeats:NO];
            self.lockSettings = NO;
            viewController = self.menuViewController;
            break;
    }
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
-(void)logOut{
    [PFUser logOut];
    [[KPParseCoreData sharedInstance] clearAndDeleteData];
    [self resetRoot];
    //[self.drawerViewController closeDrawerAnimated:YES completion:nil];
    
}
-(void)resetRoot{
    self.menuViewController = nil;
    [self setupAppearance];
    [self.settingsViewController renderSubviews];
    //[self.sideMenu hide];
    
}
-(void)proWithMessage:(NSString*)message{
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
    if(result == MFMailComposeResultSent) event = @"Share tasks sent";
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
-(void)accountAlert{
    KPAccountAlert *alert = [KPAccountAlert alertWithFrame:self.view.bounds message:@"Register for Swipes to safely back up your data and get Swipes Plus" block:^(BOOL succeeded, NSError *error) {
        [BLURRY dismissAnimated:YES];
        if(succeeded){
            [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
        }
        
    }];
    BLURRY.blurryTopColor = kSettingsBlurColor;
    [BLURRY showView:alert inViewController:self];
}
-(void)upgrade{
    if(!kUserHandler.isLoggedIn){
        [self accountAlert];
        return;
    }
    UpgradeViewController *viewController = [[UpgradeViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    [OVERLAY pushView:viewController.view animated:YES];
    [ANALYTICS tagEvent:@"Upgrade to Plus" options:nil];
    [ANALYTICS pushView:@"Upgrade to Plus"];
}
-(void)walkthrough{
    WalkthroughViewController *viewController = [[WalkthroughViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    [OVERLAY pushView:viewController.view animated:YES];
    [ANALYTICS pushView:@"Walkthrough"];
}
-(void)closedUpgradeViewController:(UpgradeViewController *)viewController{
    [ANALYTICS popView];
    [viewController removeFromParentViewController];
    [OVERLAY popViewAnimated:YES];
}
-(void)openApp{
    [kSettings refreshGlobalSettingsForce:NO];
    if(self.lastClose && [[NSDate date] isLaterThanDate:[self.lastClose dateByAddingMinutes:15]]){
        [OVERLAY popAllViewsAnimated:NO];
        [self resetRoot];
    }
    else if(self.lastClose){
        [[[self menuViewController] currentViewController] update];
        [[[self menuViewController] currentViewController] deselectAllRows:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"opened app" object:self];
}
-(void)closeApp{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closing app" object:self];
    self.lastClose = [NSDate date];
}
#pragma mark - Helping methods
#pragma mark - ViewController methods
-(void)setupAppearance{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    if(!sharedObject)
        sharedObject = self;
    
    if(!kCurrent){
        if([[NSUserDefaults standardUserDefaults] objectForKey:isTryingString]){
            [self changeToMenu:KPMenuHome animated:NO];
        }
        else{
            [self changeToMenu:KPMenuLogin animated:NO];
        }
    }
    else
        [self changeToMenu:KPMenuLogin animated:NO];
    
}

-(void)syncHandler:(KPParseCoreData *)handler status:(SyncStatus)status userInfo:(NSDictionary *)userInfo error:(NSError *)error{
    if(OSVER < 7) return;
    NSLog(@"delegate");
    if(!self.notification){
        self.notification = [CWStatusBarNotification new];
        self.notification.notificationTappedBlock = nil;
        self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    }
    self.notification.notificationLabelBackgroundColor = tcolor(BackgroundColor);
    self.notification.notificationLabelTextColor = tcolor(TextColor);
    switch (status) {
        case SyncStatusStarted:
            [self.notification displayNotificationWithMessage:@"Synchronizing..." completion:nil];
            NSLog(@"send status");
            break;
        case SyncStatusProgress:
            break;
        case SyncStatusSuccess:
            [self.notification displayNotificationWithMessage:@"Sync completed" forDuration:1.5];
            break;
        case SyncStatusError:
            [self.notification displayNotificationWithMessage:@"Error syncing" forDuration:3];
            break;
        default:
            break;
    }
}

-(void)tryoutapp{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:isTryingString]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isTryingString];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [KPCORE seedObjectsSave:YES];
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
    
    
    BLURRY.delegate = self;
    self.settingsViewController = [[MenuViewController alloc] init];

    self.drawerViewController = [[MMDrawerController alloc] init];
    [self.drawerViewController setCenterViewController:self.menuViewController];
    [self.drawerViewController setLeftDrawerViewController:self.settingsViewController];
    
#warning Stanimir I used 320 here :D sorry
    [self.drawerViewController setMaximumLeftDrawerWidth:320];
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
    [self.drawerViewController setAnimationVelocity:1240];
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
