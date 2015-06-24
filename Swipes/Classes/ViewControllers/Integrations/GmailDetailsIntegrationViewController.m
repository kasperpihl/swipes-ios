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
    [super viewDidLoad];
    self.title = kGmInt.emailAddress;
    [self recreateCellInfo];
}

- (void)recreateCellInfo
{
       self.cellInfo = @[
                         @{kKeyTitle: NSLocalizedString(@"I use Mailbox", nil),
                           kKeyCellType: @(kIntegrationCellTypeCheck),
                           kKeyIsOn: @(kGmInt.isUsingMailbox),
                           kKeyTouchSelector: NSStringFromSelector(@selector(onMailboxTouch))
                           }.mutableCopy,
                         @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
                         @{kKeyTitle: NSLocalizedString(@"Unlink", nil),
                           kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                           kKeyIcon: @"settingsLogout",
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
        [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Unlink Gmail", nil) andMessage:NSLocalizedString(@"All tasks will be unlinked, are you sure?", nil) block:^(BOOL succeeded, NSError *error) {
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
