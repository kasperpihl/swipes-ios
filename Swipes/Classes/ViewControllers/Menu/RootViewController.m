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

#import "KPAlert.h"

#import "MMDrawerVisualState.h"

#import "ShareViewController.h"

@interface RootViewController () <UINavigationControllerDelegate,WalkthroughDelegate,KPBlurryDelegate,UpgradeViewControllerDelegate,MFMailComposeViewControllerDelegate,LoginViewControllerDelegate>

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

-(void)didLoginUser:(PFUser*)user
{
    if (user.isNew)
        [[KPParseCoreData sharedInstance] seedObjectsSave:YES];
    if (user.isNew) {
        [ANALYTICS tagEvent:@"Signed Up" options:@{}];
    }
    else {
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
            self.lockSettings = NO;
            viewController = self.menuViewController;
            break;
    }
    self.currentMenu = menu;
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
    [[KPParseCoreData sharedInstance] logOutAndDeleteData];
    [self resetRoot];
    
}

-(void)resetRoot
{
    self.menuViewController = nil;
    [self setupAppearance];
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

-(void)upgrade
{
    UpgradeViewController *viewController = [[UpgradeViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    [OVERLAY pushView:viewController.view animated:YES];
    [ANALYTICS tagEvent:@"Upgrade to Plus" options:nil];
    [ANALYTICS pushView:@"Upgrade to Plus"];
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
-(void)setupAppearance
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (!sharedObject)
        sharedObject = self;
    if (!kCurrent)
        [self changeToMenu:KPMenuLogin animated:NO];
    else
        [self changeToMenu:KPMenuHome animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
    
    notify(@"changed theme", changedTheme);
    
    
    BLURRY.delegate = self;
    self.settingsViewController = [[MenuViewController alloc] init];
    self.drawerViewController = [[MMDrawerController alloc] initWithCenterViewController:self.menuViewController leftDrawerViewController:self.settingsViewController];
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
    self.viewControllers = @[self.drawerViewController];
    
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
