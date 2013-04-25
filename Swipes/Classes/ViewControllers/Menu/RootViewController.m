//
//  RootViewController2.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 25/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "RootViewController.h"
#import <Parse/Parse.h>
#import "FacebookCommunicator.h"
#import "KPSegmentedViewController.h"
#import "ToDoListTableViewController.h"



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
        ToDoListTableViewController *vc1 = [[ToDoListTableViewController alloc] initWithStyle:UITableViewStylePlain];
        vc1.state = @"schedule";
        ToDoListTableViewController *vc2 = [[ToDoListTableViewController alloc] initWithStyle:UITableViewStylePlain];
        vc2.state = @"today";
        ToDoListTableViewController *vc3 = [[ToDoListTableViewController alloc] initWithStyle:UITableViewStylePlain];
        vc3.state = @"done";
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3] titles:@[@"Schedule",@"Today",@"Done"]];
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
