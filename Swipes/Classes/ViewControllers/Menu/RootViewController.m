//
//  RootViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 25/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "RootViewController.h"
#import <Parse/Parse.h>
#import "FacebookCommunicator.h"

#import "ToDoListViewController.h"
#import "ScheduleViewController.h"
#import "TodayViewController.h"
#import "DoneViewController.h"
#import "UtilityClass.h"

#import "LoginViewController.h"
#import "SignupViewController.h"
#import <Parse/PFFacebookUtils.h>
#import "FacebookCommunicator.h"
#import "AnalyticsHandler.h"
#import "AppDelegate.h"
#import "RESideMenu.h"
#import "MenuViewController.h"
#import "KPBlurry.h"
#import "WalkthroughViewController.h"
#import "UIColor+Utilities.h"
#import "NotificationHandler.h"
#import "PlusAlertView.h"
#import "UpgradeViewController.h"
#import "KPParseCoreData.h"
#import "GAI.h"
#import "KPRepeatPicker.h"
#import "NSDate-Utilities.h"

@interface RootViewController () <UINavigationControllerDelegate,PFLogInViewControllerDelegate,WalkthroughDelegate,KPBlurryDelegate,UpgradeViewControllerDelegate>
@property (nonatomic,strong) RESideMenu *sideMenu;
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
#pragma mark - PFLogInViewControllerDelegate
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}
-(void)fetchDataFromFacebook{
    __block NSString *requestPath = @"me?fields=email,gender";
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [FBC addRequest:request write:NO permissions:nil block:^BOOL(FBReturnType status, id result, NSError *error) {
        PFUser *user = [PFUser currentUser];
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
        }
        return NO;
    }];
}
-(void)didLoginUser:(PFUser*)user{
    [[KPParseCoreData sharedInstance] seedObjects];
    NSString *wasSignup = user.isNew ? @"yes" : @"no";
    [MIXPANEL track:@"Logged in" properties:@{@"Is signup":wasSignup}];
    [MIXPANEL identify:user.objectId];
    NSString *action = user.isNew ? @"sign_up" : @"sign_in";
    [kGAnanlytics sendEventWithCategory:@"app_flow"
                        withAction:action
                         withLabel:nil
                         withValue:nil]; // First activity of new session.
    [ANALYTICS startSession];
    if([PFFacebookUtils isLinkedWithUser:user]){
        if(!user.email){
            [self fetchDataFromFacebook];
        }
    }
    [self changeToMenu:KPMenuHome animated:YES];
    
}
// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self didLoginUser:user];
}
// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in... %@",error);
}
-(void)walkthrough:(WalkthroughViewController *)walkthrough didFinishSuccesfully:(BOOL)successfully{
    [ANALYTICS popView];
    [walkthrough.view removeFromSuperview];
    [walkthrough removeFromParentViewController];
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
            self.lockSettings = NO;
            viewController = self.menuViewController;
            break;
    }
    self.currentMenu = menu;
    self.viewControllers = @[viewController];
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
    [[KPParseCoreData sharedInstance] cleanUp];
    [self resetRoot];
    
}
-(void)resetRoot{
    self.menuViewController = nil;
    [self setupAppearance];
    [self.sideMenu hide];
}
-(void)proWithMessage:(NSString*)message{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [PlusAlertView alertInView:window message:message block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self upgrade];
        }
    }];
}
-(void)upgrade{
    UpgradeViewController *viewController = [[UpgradeViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:viewController.view];
    [ANALYTICS pushView:@"Upgrade to Plus"];
}
-(void)walkthrough{
    WalkthroughViewController *viewController = [[WalkthroughViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:viewController.view];
    [ANALYTICS pushView:@"Walkthrough"];
}
-(void)closedUpgradeViewController:(UpgradeViewController *)viewController{
    [ANALYTICS popView];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}
-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    if(self.lockSettings) return;
    [self.sideMenu panGestureRecognized:sender];
}

-(void)openApp{
    if(self.lastClose && [[NSDate date] isLaterThanDate:[self.lastClose dateByAddingMinutes:5]]);
    else [[[self menuViewController] currentViewController] update];
    //[self resetRoot];
}
-(void)closeApp{
    self.lastClose = [NSDate date];
}
#pragma mark - Helping methods
#pragma mark - ViewController methods
-(void)setupAppearance{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    if(!sharedObject) sharedObject = self;
    if(![PFUser currentUser]) [self changeToMenu:KPMenuLogin animated:NO];
    else [self changeToMenu:KPMenuHome animated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
    
    BLURRY.delegate = self;
    self.sideMenu = kSideMenu;
    self.sideMenu.backgroundImage = [tbackground(TaskTableGradientBackground) image];
    self.sideMenu.hideStatusBarArea = [AppDelegate OSVersion] < 7;
    self.settingsViewController = [[MenuViewController alloc] init];
    self.sideMenu.revealView = self.settingsViewController.view;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    [self setupAppearance];
    NSLog(@"did setup appearance");
    
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
