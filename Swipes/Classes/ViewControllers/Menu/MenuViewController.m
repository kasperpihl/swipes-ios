//
//  MenuViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "MenuViewController.h"
#import "RootViewController.h"
#import "ThemeHandler.h"
@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    NSLog(@"initialized");
	// Do any additional setup after loading the view.
    UIButton *logOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logOutButton setTitle:@"Logout" forState:UIControlStateNormal];
    logOutButton.frame = CGRectMake(0, self.view.frame.size.height-44, 300, 44);
    [logOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:logOutButton];
    
    UIButton *tutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tutorialButton setTitle:@"Walkthrough" forState:UIControlStateNormal];
    [tutorialButton addTarget:self action:@selector(pressedTut) forControlEvents:UIControlEventTouchUpInside];
    tutorialButton.frame = CGRectMake(0, 10, 300, 44);
    [self.view addSubview:tutorialButton];
}
-(void)pressedTut{
    [ROOT_CONTROLLER walkthrough];
    //[THEMER changeTheme];
    //[ROOT_CONTROLLER resetRoot];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
