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
@interface RootViewController () <UINavigationControllerDelegate>
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
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3] titles:@[@"Schedule",@"Today",@"Done"]];
        self.menuViewController = menuViewController;
        self.viewControllers = @[menuViewController];
    }
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
    if(!sharedObject) sharedObject = self;
    [self setupMenu];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}
@end
