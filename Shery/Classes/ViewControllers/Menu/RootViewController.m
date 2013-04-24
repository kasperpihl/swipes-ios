//
//  RootViewController.m
//  GoOut
//
//  Created by Kasper Pihl Tornøe on 24/08/12.
//
//

#import "RootViewController.h"
#import <Parse/Parse.h>
#import "FacebookCommunicator.h"
#import "KPSegmentedViewController.h"
#import "BacklogViewController.h"
#import "TodayViewController.h"
#import "DoneViewController.h"



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
        BacklogViewController *vc1 = [[BacklogViewController alloc] initWithStyle:UITableViewStylePlain];

        TodayViewController *vc2 = [[TodayViewController alloc] initWithStyle:UITableViewStylePlain];

        DoneViewController *vc3 = [[DoneViewController alloc] initWithStyle:UITableViewStylePlain];
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3] titles:@[@"Schedule",@"Today",@"Done"]];
        menuViewController.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.menuViewController = menuViewController;
        self.viewControllers = @[menuViewController];
    }
}

#pragma mark - Helping methods
#pragma mark - ViewController methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!sharedObject) sharedObject = self;
    [self setupMenu];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}
@end
