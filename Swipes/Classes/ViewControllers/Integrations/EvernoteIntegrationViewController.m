//
//  EvernoteIntegrationViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "EvernoteIntegration.h"
#import "IntegrationsViewController.h"
#import "EvernoteIntegrationViewController.h"

@interface EvernoteIntegrationViewController ()  <IntegrationProvider>

@end

@implementation EvernoteIntegrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)integrationTitle {
    return @"EVERNOTE";
}

- (NSString *)integrationSubtitle {
    // TODO return something meaningful
    return @" ";
}

- (NSString *)integrationIcon {
    return iconString(@"integrationEvernote");
}

- (BOOL)integrationEnabled {
    return kEnInt.isAuthenticated;
}

@end
