//
//  IntegrationsViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "EvernoteIntegration.h"
#import "GmailIntegration.h"
#import "EvernoteIntegrationViewController.h"
#import "GmailIntegrationViewController.h"
#import "IntegrationsViewController.h"

@interface IntegrationsViewController ()

@end

@implementation IntegrationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [LOCALIZE_STRING(@"Integrations") uppercaseString];
}

- (void)recreateCellInfo
{
    self.cellInfo = @[
                      @{kKeyTitle: kEnInt.integrationTitle,
                        kKeyCellType: @(kIntegrationCellTypeStatus),
                        kKeyIsOn: @(kEnInt.integrationEnabled),
                        kKeySubtitle: kEnInt.integrationSubtitle,
                        kKeyIcon: kEnInt.integrationIcon,
                        kKeyTouchSelector: NSStringFromSelector(@selector(onEvernoteTouch))
                        },
                      @{kKeyTitle: kGmInt.integrationTitle,
                        kKeyCellType: @(kIntegrationCellTypeStatus),
                        kKeyIsOn: @(kGmInt.integrationEnabled),
                        kKeySubtitle: kGmInt.integrationSubtitle,
                        kKeyIcon: kGmInt.integrationIcon,
                        kKeyTouchSelector: NSStringFromSelector(@selector(onGmailTouch))
                        },
                      ];
}

#pragma mark - selectors

- (void)onEvernoteTouch
{
    [self addModalTransition];
    EvernoteIntegrationViewController* vc = [[EvernoteIntegrationViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)onGmailTouch
{
    [self addModalTransition];
    GmailIntegrationViewController* vc = [[GmailIntegrationViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

@end
