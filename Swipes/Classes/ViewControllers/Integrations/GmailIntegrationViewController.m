//
//  GmailIntegrationViewController.m
//  Swipes
//
//  Created by demosten on 2/24/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "SettingsHandler.h"
#import "UtilityClass.h"
#import "KPToDo.h"
#import "KPAttachment.h"
#import "DejalActivityView.h"
#import "RootViewController.h"
#import "GmailIntegration.h"
#import "GmailDetailsIntegrationViewController.h"
#import "GmailHelperViewController.h"
#import "GmailIntegrationViewController.h"

@interface GmailIntegrationViewController () <GmailHelperDelegate>

@end

@implementation GmailIntegrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"GMAIL INTEGRATION";
    self.lightColor = kGmailColor;
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    if (kGmInt.isAuthenticated) {
        NSString* emailAddress = kGmInt.emailAddress;
        if (!emailAddress) {
            emailAddress = LOCALIZE_STRING(@"Loading data...");
            __weak GmailIntegrationViewController *weakSelf = self;
            [kGmInt emailAddressWithBlock:^(NSError *error) {
                NSString* newEmail = error ? LOCALIZE_STRING(@"Error loading data") : kGmInt.emailAddress;
                weakSelf.cellInfo[0][kKeyTitle] = newEmail;
                [self.table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:NO];
            }];
        }
        MailOpenType openType = [kGmInt mailOpenType];
        NSMutableArray* cellInfo = @[
                          @{kKeyTitle: emailAddress,
                            kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                            kKeyIcon: kGmInt.isUsingMailbox ? @"integrationMailbox" : @"integrationMail",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onEmailTouch))
                            }.mutableCopy,
                          @{kKeyCellType: @(kIntegrationCellTypeSection), kKeyTitle: LOCALIZE_STRING(@"OPEN EMAILS IN")},
                          @{kKeyTitle: @"Inbox",
                            kKeyCellType: @(kIntegrationCellTypeCheck),
                            kKeyIsOn: @(openType == MailOpenTypeInbox),
                            kKeyIcon: @"integrationMail",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onInboxTouch))
                            }.mutableCopy,
                          ].mutableCopy;
        if ([GlobalApp isMailboxInstalled]) {
            [cellInfo addObject:@{kKeyTitle: @"Mailbox",
                                  kKeyCellType: @(kIntegrationCellTypeCheck),
                                  kKeyIsOn: @(openType == MailOpenTypeMailbox),
                                  kKeyIcon: @"integrationMailbox",
                                  kKeyTouchSelector: NSStringFromSelector(@selector(onMailboxTouch))
                                  }.mutableCopy];
        }
        if ([GlobalApp isGoogleMailInstalled]) {
            [cellInfo addObject:@{kKeyTitle: @"Gmail",
                                  kKeyCellType: @(kIntegrationCellTypeCheck),
                                  kKeyIsOn: @(openType == MailOpenTypeGmail),
                                  kKeyIcon: @"integrationMail",
                                  kKeyTouchSelector: NSStringFromSelector(@selector(onGMailTouch))
                                  }.mutableCopy];
        }
        if ([GlobalApp isCloudMagicInstalled]) {
            [cellInfo addObject:@{kKeyTitle: @"Cloud Magic",
                                  kKeyCellType: @(kIntegrationCellTypeCheck),
                                  kKeyIsOn: @(openType == MailOpenTypeCloudMagic),
                                  kKeyIcon: @"integrationMail",
                                  kKeyTouchSelector: NSStringFromSelector(@selector(onCloudMagicTouch))
                                  }.mutableCopy];
        }
        [cellInfo addObject:@{kKeyCellType: @(kIntegrationCellTypeSeparator)}];
        self.cellInfo = cellInfo;
    }
    else {
        self.cellInfo = @[
                          @{kKeyTitle: LOCALIZE_STRING(@"Add new account"),
                            kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                            kKeyIcon: @"roundAdd",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onLinkGmailTouch))
                            }];
    }
    self.cellInfo = [self.cellInfo arrayByAddingObjectsFromArray:@[
                                                                   @{kKeyTitle: LOCALIZE_STRING(@"Learn more"),
                                                                     kKeyCellType: @(kIntegrationCellTypeViewMore),
                                                                     kKeyIcon: @"integrationActionLearn",
                                                                     kKeyTouchSelector: NSStringFromSelector(@selector(onLearnMoreTouch))
                                                                     },
                                                                   ]];
}

#pragma mark - UITableViewDataSource

#pragma mark - selectors

- (void)onEmailTouch
{
    if (kGmInt.emailAddress) {
        GmailDetailsIntegrationViewController* vc = [[GmailDetailsIntegrationViewController alloc] init];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

- (void)onLinkGmailTouch
{
    [self gmailAuthenticateUsingSelector:@selector(authenticatedGmail) withObject:nil];
}

- (void)onLearnMoreTouch
{
    [ANALYTICS pushView:@"Gmail Learn More"];
    GmailHelperViewController *helper = [[GmailHelperViewController alloc] init];
    helper.delegate = self;
    [self presentViewController:helper animated:YES completion:nil];
}

- (void)onInboxTouch
{
    [kSettings setValue:@(MailOpenTypeInbox) forSetting:IntegrationGmailOpenType];
    [self reload];
}

- (void)onMailboxTouch
{
    [kSettings setValue:@(MailOpenTypeMailbox) forSetting:IntegrationGmailOpenType];
    [self reload];
}

- (void)onGMailTouch
{
    [kSettings setValue:@(MailOpenTypeGmail) forSetting:IntegrationGmailOpenType];
    [self reload];
}

- (void)onCloudMagicTouch
{
    [kSettings setValue:@(MailOpenTypeCloudMagic) forSetting:IntegrationGmailOpenType];
    [self reload];
}

#pragma mark - Helpers

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

- (void)gmailAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    if(!kCurrent){
        [ROOT_CONTROLLER accountAlertWithMessage:@"To use Gmail with Swipes, please create a Swipes account" inViewController:self];
        return;
    }
    [DejalBezelActivityView activityViewForView:self.parentViewController.view withLabel:@"Authenticating.."];
    [kGmInt authenticateInViewController:self withBlock:^(NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        if (error || !kGmInt.isAuthenticated) {
            // TODO show message to the user
            //NSLog(@"Session authentication failed: %@", [error localizedDescription]);
        }
        else {
            [self performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
        }
    }];
}

- (void)authenticatedGmail
{
    [self reload];
}

- (void)endedGmailHelperSuccessfully:(BOOL)success
{
    [ANALYTICS popView];
    if (success && (!kGmInt.isAuthenticated)) {
        [self gmailAuthenticateUsingSelector:@selector(authenticatedEvernote) withObject:nil];
    }
}

@end
