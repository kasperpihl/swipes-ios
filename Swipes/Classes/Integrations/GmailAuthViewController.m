//
//  GmailAuthViewController.m
//  Swipes
//
//  Created by demosten on 1/22/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "GmailAuthViewController.h"

@interface GmailAuthViewController ()

@end

@implementation GmailAuthViewController

// subclasses may override authNibName to specify a custom name
+ (NSString *)authNibName
{
    return @"GmailAuthViewController";
}

// subclasses may override authNibBundle to specify a custom bundle
+ (NSBundle *)authNibBundle
{
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNavigation
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:LOCALIZE_STRING(@"Cancel")
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(onCancel:)];
    
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)onCancel:(id)sender
{
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
