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
#import "KPSegmentedViewController.h"
#import "ToDoListViewController.h"
#import "ScheduleViewController.h"
#import "TodayViewController.h"
#import "DoneViewController.h"
#import "UtilityClass.h"
#import "MYIntroductionView.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import <Parse/PFFacebookUtils.h>
#import "FacebookCommunicator.h"
#import "AnalyticsHandler.h"

@interface RootViewController () <UINavigationControllerDelegate,MYIntroductionDelegate,PFLogInViewControllerDelegate>
@property (nonatomic,strong) KPSegmentedViewController *menuViewController;

@end

@implementation RootViewController
#pragma mark - Properties

-(KPSegmentedViewController *)menuViewController{
    if(!_menuViewController){
        ScheduleViewController *vc1 = [[ScheduleViewController alloc] init];
        
        TodayViewController *vc2 = [[TodayViewController alloc] init];
        DoneViewController *vc3 = [[DoneViewController alloc] init];
        vc1.view.autoresizingMask = vc2.view.autoresizingMask = vc3.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3] titles:@[@"Schedule",@"Today",@"Done"]];
        _menuViewController = menuViewController;
    }
    return _menuViewController;
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
            
            if(email) [user setObject:email forKey:@"email"];
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

-(void)walkthrough{
    //STEP 1 Construct Panels
    MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough1"] description:@"Welcome to your powerful Menu bar! Here everything has its place. Plan and focus on your tasks today, complete them or schedule them for later."];
    
    //You may also add in a title for each panel
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough2"] description:@"Double tap a task to enter the edit mode. Quickly change titles, assign tags, notes and reminders."];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough3"] description:@"Pull down the Menu bar. Type a name of a tag or simply chose it from the filter. Your result is there in a glimpse."];
    
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough4"] description:@"This is your favorite schedule! Simply swipe your tasks to the left and set them up for later. You will get reminded, when the time’s right."];
    
    MYIntroductionPanel *panel5 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough5"] description:@"Start swiping now. Plan your day and enjoy a productive flow!"];
    
    //STEP 2 Create IntroductionView
    
    /*A standard version*/
    //MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) headerImage:[UIImage imageNamed:@"SampleHeaderImage.png"] panels:@[panel, panel2]];
    
    
    /*A version with no header (ala "Path")*/
    //MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) panels:@[panel, panel2]];
    
    /*A more customized version*/
    MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) panels:@[panel, panel2, panel3, panel4, panel5]];
    [introductionView setBackgroundImage:[UtilityClass imageWithColor:LOGIN_BACKGROUND]];
    
    
    //Set delegate to self for callbacks (optional)
    introductionView.delegate = self;
    
    //STEP 3: Show introduction view
    [introductionView showInView:self.view];
}
#pragma mark - Helping methods
#pragma mark - ViewController methods
-(void)setupAppearance{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_bg"] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundImage:[UtilityClass navbarImage] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
    [self setupAppearance];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    if(!sharedObject) sharedObject = self;
    
    //[PFUser logOut];
    if(![PFUser currentUser]) [self changeToMenu:KPMenuLogin animated:NO];
    else [self changeToMenu:KPMenuHome animated:NO];
    //[self walkthrough];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}
@end
