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

#import "KPOverlay.h"

#import "ToDoHandler.h"
#import "LocalyticsSession.h"
#import <MessageUI/MessageUI.h>

@interface RootViewController () <UINavigationControllerDelegate,PFLogInViewControllerDelegate,WalkthroughDelegate,KPBlurryDelegate,UpgradeViewControllerDelegate,MFMailComposeViewControllerDelegate>
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
        PFUser *user = kCurrent;
        if(error) {
            return NO;
        }
        else{
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            NSString *email = [userData objectForKey:@"email"];
            
            if(email){
                [user setObject:email forKey:@"email"];
                [[LocalyticsSession shared] setCustomerEmail:email];
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
    if(user.isNew) [[KPParseCoreData sharedInstance] seedObjects];
    NSString *wasSignup = user.isNew ? @"yes" : @"no";
    [MIXPANEL track:@"Logged in" properties:@{@"Is signup":wasSignup}];
    if(user.isNew) {
        [ANALYTICS tagEvent:@"Signed Up" options:@{}];
    }
    else{
        [ANALYTICS tagEvent:@"Logged In" options:@{}];
    }
    
    [MIXPANEL identify:user.objectId];
    [[LocalyticsSession shared] setCustomerId:user.objectId];
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
    else{
        [[LocalyticsSession shared] setCustomerEmail:user.email];
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
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)shareTasks{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:@"Tasks from Swipes"];
        
        NSString *message = @"Tasks from Swipes: \r\n\r\n";
        NSArray *tasks = [[self.menuViewController currentViewController] selectedItems];
        for(KPToDo *toDo in tasks){
            message = [message stringByAppendingFormat:@"◯ %@\r\n",toDo.title];
        }
        
        [mailCont setMessageBody:message isHTML:NO];
        [self presentViewController:mailCont animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail was not setup" message:@"You can send us feedback to support@swipesapp.com. Thanks" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)upgrade{
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
-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    if(self.lockSettings) return;
    [self.sideMenu panGestureRecognized:sender];
}

-(void)openApp{
    if(self.lastClose && [[NSDate date] isLaterThanDate:[self.lastClose dateByAddingMinutes:15]]){
        [OVERLAY popAllViewsAnimated:NO];
        [self resetRoot];
    }
    else if(self.lastClose) [[[self menuViewController] currentViewController] update];
}
-(void)closeApp{
    self.lastClose = [NSDate date];
}
#pragma mark - Helping methods
#pragma mark - ViewController methods
-(void)setupAppearance{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    if(!sharedObject) sharedObject = self;
    if(!kCurrent) [self changeToMenu:KPMenuLogin animated:NO];
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
