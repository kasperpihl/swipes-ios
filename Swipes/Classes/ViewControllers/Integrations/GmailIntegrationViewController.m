//
//  GmailIntegrationViewController.m
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
#import "GmailIntegrationViewController.h"

@interface GmailIntegrationViewController ()

@end

@implementation GmailIntegrationViewController

- (void)viewDidLoad
{
    self.title = @"GMAIL INTEGRATION";
    self.lightColor = [UIColor redColor];
    [self recreateCellInfo];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recreateCellInfo
{
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
        self.cellInfo = @[
                          @{kKeyTitle: emailAddress,
                            kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                            kKeyIcon: @"editMail",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onEmailTouch))
                            }.mutableCopy,
                          @{kKeyCellType: @(kIntegrationCellTypeSeparator)}
                          ];
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
                                                                     kKeyIcon: @"today", // TODO fix
                                                                     kKeyTouchSelector: NSStringFromSelector(@selector(onLearnMoreTouch))
                                                                     },
                                                                   ]];
}

#pragma mark - IntegrationProvider

- (NSString *)integrationTitle
{
    return @"GMAIL";
}

- (NSString *)integrationSubtitle
{
    // TODO return something meaningful
    return @" ";
}

- (NSString *)integrationIcon
{
    return iconString(@"integrationGmail");
}

- (BOOL)integrationEnabled
{
    return kGmInt.isAuthenticated;
}

#pragma mark - UITableViewDataSource

#pragma mark - selectors

- (void)onEmailTouch
{
}

- (void)onLearnMoreTouch
{
    [ANALYTICS pushView:@"Gmail Learn More"];
//    EvernoteHelperViewController *helper = [[EvernoteHelperViewController alloc] init];
//    helper.delegate = self;
//    [self presentViewController:helper animated:YES completion:nil];
}

//- (void)onSignOutTouch
//{
//    if (kGmInt.isAuthenticated) {
//        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Unlink Gmail") andMessage:LOCALIZE_STRING(@"All tasks will be unlinked, are you sure?") block:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [kGmInt logout];
//                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
//                [KPToDo removeAllAttachmentsForAllToDosWithService:GMAIL_SERVICE inContext:context save:YES];
//                [self reload];
//            }
//        }];
//        
//    }
//}

- (void)onLinkGmailTouch
{
    [self gmailAuthenticateUsingSelector:@selector(authenticatedGmail) withObject:nil];
}

#pragma mark - Helpers

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

- (void)gmailAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
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

-(void)authenticatedGmail
{
    [self reload];
}


@end
