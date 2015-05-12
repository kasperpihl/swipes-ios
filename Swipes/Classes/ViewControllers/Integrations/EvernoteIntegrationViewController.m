//
//  EvernoteIntegrationViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "UtilityClass.h"
#import "DejalActivityView.h"
#import "KPToDo.h"
#import "KPAttachment.h"
#import "RootViewController.h"
#import "EvernoteHelperViewController.h"
#import "EvernoteImporterViewController.h"
#import "EvernoteIntegration.h"
#import "EvernoteIntegrationViewController.h"

@interface EvernoteIntegrationViewController () <EvernoteHelperDelegate>

@end

@implementation EvernoteIntegrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [LOCALIZE_STRING(@"EVERNOTE INTEGRATION") uppercaseString];
    self.lightColor = kEvernoteColor;
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    if (kEnInt.isAuthenticated) {
        NSDictionary* businessInfo;
        if (kEnInt.isBusinessUser) {
            businessInfo = @{kKeyTitle: LOCALIZE_STRING(@"Sync with Evernote Business"), kKeyCellType: @(kIntegrationCellTypeCheck), kKeyIsOn: @(kEnInt.findInBusinessNotebooks), kKeyTouchSelector: NSStringFromSelector(@selector(onFindBusinessNotebooksTouch))}.mutableCopy;
        }
        else {
            businessInfo = @{kKeyTitle: LOCALIZE_STRING(@"Learn more about Evernote Business"), kKeyCellType: @(kIntegrationCellTypeViewMore), kKeyTouchSelector: NSStringFromSelector(@selector(onBusinessLearnMoreTouch))};
        }
        
        self.cellInfo = @[
                          @{kKeyTitle: LOCALIZE_STRING(@"Sync with evernote on this device"),
                            kKeyCellType: @(kIntegrationCellTypeCheck),
                            kKeyIsOn: @(kEnInt.enableSync),
                            kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                            }.mutableCopy,
                          @{kKeyTitle: LOCALIZE_STRING(@"Auto import notes with \"swipes\" tag"),
                            kKeyCellType: @(kIntegrationCellTypeCheck),
                            kKeyIsOn: @(kEnInt.autoFindFromTag),
                            kKeyTouchSelector: NSStringFromSelector(@selector(onAutoImportTouch))}.mutableCopy,
                          @{kKeyTitle: LOCALIZE_STRING(@"Sync with personal linked notebooks"),
                            kKeyCellType: @(kIntegrationCellTypeCheck),
                            kKeyIsOn: @(kEnInt.findInPersonalLinked),
                            kKeyTouchSelector: NSStringFromSelector(@selector(onFindPersonalTouch))
                            }.mutableCopy,
                          businessInfo,
                          @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
                          @{kKeyTitle: LOCALIZE_STRING(@"Import notes"),
                            kKeyCellType: @(kIntegrationCellTypeViewMore),
                            kKeyIcon: @"integrationActionImporter",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onImportNotesTouch))
                            },
                          @{kKeyTitle: LOCALIZE_STRING(@"Learn more"),
                            kKeyCellType: @(kIntegrationCellTypeViewMore),
                            kKeyIcon: @"integrationActionLearn",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onLearnMoreTouch))
                            },
                          @{kKeyTitle: LOCALIZE_STRING(@"Unlink"),
                            kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                            kKeyIcon: @"settingsLogout",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onSignOutTouch))
                            },
                          ];
    }
    else {
        self.cellInfo = @[
                          @{kKeyTitle: LOCALIZE_STRING(@"Link account"),
                            kKeyCellType: @(kIntegrationCellTypeViewMore),
                            kKeyTouchSelector: NSStringFromSelector(@selector(onLinkEvernoteTouch))
                            },
                          @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
                          @{kKeyTitle: LOCALIZE_STRING(@"Learn more"),
                            kKeyCellType: @(kIntegrationCellTypeViewMore),
                            kKeyIcon: @"integrationActionLearn",
                            kKeyTouchSelector: NSStringFromSelector(@selector(onLearnMoreTouch))
                            },
                          ];
    }
}

#pragma mark - selectors

- (void)onSyncWithEvernoteTouch
{
    kEnInt.enableSync = !kEnInt.enableSync;
    self.cellInfo[0][kKeyIsOn] = @(kEnInt.enableSync);
}

- (void)onAutoImportTouch
{
    kEnInt.autoFindFromTag = !kEnInt.autoFindFromTag;
    self.cellInfo[1][kKeyIsOn] = @(kEnInt.autoFindFromTag);
}

- (void)onFindPersonalTouch
{
    kEnInt.findInPersonalLinked = !kEnInt.findInPersonalLinked;
    self.cellInfo[2][kKeyIsOn] = @(kEnInt.findInPersonalLinked);
}

- (void)onFindBusinessNotebooksTouch
{
    kEnInt.findInBusinessNotebooks = !kEnInt.findInBusinessNotebooks;
    self.cellInfo[3][kKeyIsOn] = @(kEnInt.findInBusinessNotebooks);
}

- (void)onBusinessLearnMoreTouch
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://evernote.com/business/"]];
}

- (void)onImportNotesTouch
{
    [ANALYTICS pushView:@"Evernote Importer"];
    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:YES completion:nil];
}

- (void)onLearnMoreTouch
{
    [ANALYTICS pushView:@"Evernote Learn More"];
    EvernoteHelperViewController *helper = [[EvernoteHelperViewController alloc] init];
    helper.delegate = self;
    [self presentViewController:helper animated:YES completion:nil];
}

- (void)onSignOutTouch
{
    if (kEnInt.isAuthenticated){
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Unlink Evernote") andMessage:LOCALIZE_STRING(@"All tasks will be unlinked, are you sure?") block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [kEnInt logout];
                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
                [KPToDo removeAllAttachmentsForAllToDosWithService:EVERNOTE_SERVICE inContext:context save:YES];
                [self reload];
            }
        }];
    }
}

- (void)onLinkEvernoteTouch
{
    [self evernoteAuthenticateUsingSelector:@selector(authenticatedEvernote) withObject:nil];
}

#pragma mark - Helpers

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

- (void)evernoteAuthenticateUsingSelector:(SEL)selector withObject:(id)object
{
    if (kEnInt.isAuthenticationInProgress)
        return;
    if(!kCurrent){
        [ROOT_CONTROLLER accountAlertWithMessage:@"To use Evernote with Swipes, please create a Swipes account" inViewController:self];
        return;
    }
    [DejalBezelActivityView activityViewForView:self.parentViewController.view withLabel:LOCALIZE_STRING(@"Opening Evernote...")];
    [kEnInt authenticateEvernoteInViewController:self withBlock:^(NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        if (error || !kEnInt.isAuthenticated) {
            // TODO show message to the user
            //NSLog(@"Session authentication failed: %@", [error localizedDescription]);
        }
        else {
            [self performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
        }
    }];
}

-(void)showEvernoteImporterAnimated:(BOOL)animated
{
    [ANALYTICS pushView:@"Evernote Importer"];
    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:animated completion:nil];
}

-(void)authenticatedEvernote
{
    [UTILITY alertWithTitle:LOCALIZE_STRING(@"Get started") andMessage:LOCALIZE_STRING(@"Import a few notes right away.") buttonTitles:@[LOCALIZE_STRING(@"Not now"),LOCALIZE_STRING(@"Choose notes")] block:^(NSInteger number, NSError *error) {
        if (number == 1){
            [self showEvernoteImporterAnimated:YES];
        }
    }];
    [self reload];
}

-(void)endedEvernoteHelperSuccessfully:(BOOL)success{
    [ANALYTICS popView];
    if (success && (!kEnInt.isAuthenticated) && (!kEnInt.isAuthenticationInProgress)) {
        [self evernoteAuthenticateUsingSelector:@selector(authenticatedEvernote) withObject:nil];
    }
}


@end
