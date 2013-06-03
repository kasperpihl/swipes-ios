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
@interface RootViewController () <UINavigationControllerDelegate,MYIntroductionDelegate>
@property (nonatomic,strong) KPSegmentedViewController *menuViewController;

@end

@implementation RootViewController
#pragma mark - Properties


#pragma mark - Public API
static RootViewController *sharedObject;
+(RootViewController *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[RootViewController allocWithZone:NULL] init];
    }
    return sharedObject;
}

-(void)setupMenu{
    if(!self.menuViewController){
        [self setNavigationBarHidden:YES];
        ScheduleViewController *vc1 = [[ScheduleViewController alloc] init];
        
        TodayViewController *vc2 = [[TodayViewController alloc] init];
        DoneViewController *vc3 = [[DoneViewController alloc] init];
        vc1.view.autoresizingMask = vc2.view.autoresizingMask = vc3.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3] titles:@[@"Schedule",@"Today",@"Done"]];
        self.menuViewController = menuViewController;
        self.viewControllers = @[menuViewController];
    }
}
-(void)walkthrough{
    //STEP 1 Construct Panels
    MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough1"] description:@""];
    
    //You may also add in a title for each panel
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough1"] description:@""];
    
    //STEP 2 Create IntroductionView
    
    /*A standard version*/
    //MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) headerImage:[UIImage imageNamed:@"SampleHeaderImage.png"] panels:@[panel, panel2]];
    
    
    /*A version with no header (ala "Path")*/
    //MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) panels:@[panel, panel2]];
    
    /*A more customized version*/
    MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) panels:@[panel, panel2]];
    [introductionView setBackgroundImage:[UtilityClass imageWithColor:color(58,67,79,1)]];
    
    
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
    [self setupAppearance];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    if(!sharedObject) sharedObject = self;
    //[self walkthrough];
    [self setupMenu];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}
@end
