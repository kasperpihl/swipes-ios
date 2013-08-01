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
@interface RootViewController () <UINavigationControllerDelegate,PFLogInViewControllerDelegate,WalkthroughDelegate,KPBlurryDelegate>
@property (nonatomic,strong) RESideMenu *sideMenu;
@property (nonatomic,strong) MenuViewController *settingsViewController;

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
    NSLog(@"did show");
    self.lockSettings = YES;
    
}
-(void)blurryDidHide:(KPBlurry *)blurry{
    self.lockSettings = NO;
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
                [MIXPANEL.people set:@"$email" to:email];
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
    NSString *wasSignup = user.isNew ? @"yes" : @"no";
    [MIXPANEL track:@"Logged in" properties:@{@"Is signup":wasSignup}];
    [MIXPANEL identify:user.objectId];
    [ANALYTICS startSession];
    if([PFFacebookUtils isLinkedWithUser:user]){
        if(!user.email){
            [self fetchDataFromFacebook];
        }
    }
    else{
        [MIXPANEL.people set:@"$email" to:user.username];
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
            
            viewController = loginVC;
            break;
        }
        case KPMenuHome:
            viewController = self.menuViewController;
            break;
    }
    self.viewControllers = @[viewController];
}
static RootViewController *sharedObject;
+(RootViewController *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[RootViewController allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)resetRoot{
    self.menuViewController = nil;
    [self setupAppearance];
    [self.sideMenu hide];
    
    
}
-(void)walkthrough{
    WalkthroughViewController *viewController = [[WalkthroughViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:viewController.view];
    
}
-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    if(self.lockSettings) return;
    [self.sideMenu panGestureRecognized:sender];
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
    self.sideMenu = [[RESideMenu alloc] init];
    self.sideMenu.hideStatusBarArea = [AppDelegate OSVersion] < 7;
    self.settingsViewController = [[MenuViewController alloc] init];
    self.sideMenu.revealView = self.settingsViewController.view;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [self setupAppearance];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}
@end
