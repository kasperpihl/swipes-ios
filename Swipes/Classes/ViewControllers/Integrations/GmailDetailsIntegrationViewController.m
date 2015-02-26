//
//  GmailDetailsIntegrationViewController.m
//  Swipes
//
//  Created by demosten on 2/24/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "UtilityClass.h"
#import "KPToDo.h"
#import "KPAttachment.h"
#import "DejalActivityView.h"

#import "GmailIntegration.h"
#import "GmailDetailsIntegrationViewController.h"

@interface GmailDetailsIntegrationViewController ()

@end

@implementation GmailDetailsIntegrationViewController

- (void)viewDidLoad {
    self.title = kGmInt.emailAddress;
    self.lightColor = [UIColor clearColor];
    [self recreateCellInfo];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recreateCellInfo
{
       self.cellInfo = @[
                         @{kKeyTitle: LOCALIZE_STRING(@"I use Mailbox"),
                           kKeyCellType: @(kIntegrationCellTypeCheck),
                           kKeyIsOn: @(kGmInt.isUsingMailbox),
                           kKeyTouchSelector: NSStringFromSelector(@selector(onMailboxTouch))
                           }.mutableCopy,
                         @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
                         @{kKeyTitle: LOCALIZE_STRING(@"Unlink"),
                           kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                           kKeyIcon: @"roundClose",
                           kKeyTouchSelector: NSStringFromSelector(@selector(onSignOutTouch))
                           },
                          ];
}

- (void)onMailboxTouch
{
    kGmInt.isUsingMailbox = !kGmInt.isUsingMailbox;
    self.cellInfo[0][kKeyIsOn] = @(kGmInt.isUsingMailbox);
}

- (void)onSignOutTouch
{
    if (kGmInt.isAuthenticated) {
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Unlink Gmail") andMessage:LOCALIZE_STRING(@"All tasks will be unlinked, are you sure?") block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [kGmInt logout];
                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
                [KPToDo removeAllAttachmentsForAllToDosWithService:GMAIL_SERVICE inContext:context save:YES];
                [self goBack];
            }
        }];

    }
}

@end
