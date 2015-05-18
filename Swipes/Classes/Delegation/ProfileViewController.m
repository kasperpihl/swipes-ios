//
//  ProfileViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "UtilityClass.h"
//#import "DejalActivityView.h"
#import "IntegrationTextFieldCell.h"
#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LOCALIZE_STRING(@"PROFILE");
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    self.cellInfo = @[
                      @{kKeyCellType: @(kIntegrationCellTypeProfilePicture),
//                        kKeyIcon: @(YES),
//                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"NAME",
                        kKeyText: @"My Name",
                        kKeyPlaceholder: @"Enter your name",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"EMAIL",
                        kKeyText: @"user@host.com",
                        kKeyTextType: @(IntegrationTextFieldStyleEmail),
                        kKeyPlaceholder: @"Your email is mandatory",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"PHONE",
                        kKeyText: @"+359 88 7660834",
                        kKeyTextType: @(IntegrationTextFieldStylePhone),
                        kKeyPlaceholder: @"Your phone",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"COMPANY",
                        kKeyText: @"Swipes Inc.",
                        kKeyPlaceholder: @"Your company",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"POSITION",
                        kKeyText: @"Creative Creator",
                        kKeyPlaceholder: @"Your position in the company",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Sign out",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        },
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Change password",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        },
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Delete account",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        },
                      ];
}

#pragma mark - selectors

//- (void)onSyncWithEvernoteTouch
//{
//    kEnInt.enableSync = !kEnInt.enableSync;
//    self.cellInfo[0][kKeyIsOn] = @(kEnInt.enableSync);
//}
//
//- (void)onAutoImportTouch
//{
//    kEnInt.autoFindFromTag = !kEnInt.autoFindFromTag;
//    self.cellInfo[1][kKeyIsOn] = @(kEnInt.autoFindFromTag);
//}
//
//- (void)onFindPersonalTouch
//{
//    kEnInt.findInPersonalLinked = !kEnInt.findInPersonalLinked;
//    self.cellInfo[2][kKeyIsOn] = @(kEnInt.findInPersonalLinked);
//}
//
//- (void)onFindBusinessNotebooksTouch
//{
//    kEnInt.findInBusinessNotebooks = !kEnInt.findInBusinessNotebooks;
//    self.cellInfo[3][kKeyIsOn] = @(kEnInt.findInBusinessNotebooks);
//}
//
//- (void)onBusinessLearnMoreTouch
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://evernote.com/business/"]];
//}
//
//- (void)onImportNotesTouch
//{
//    [ANALYTICS pushView:@"Evernote Importer"];
//    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:YES completion:nil];
//}
//
//- (void)onLearnMoreTouch
//{
//    [ANALYTICS pushView:@"Evernote Learn More"];
//    EvernoteHelperViewController *helper = [[EvernoteHelperViewController alloc] init];
//    helper.delegate = self;
//    [self presentViewController:helper animated:YES completion:nil];
//}
//
//- (void)onSignOutTouch
//{
//    if (kEnInt.isAuthenticated){
//        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Unlink Evernote") andMessage:LOCALIZE_STRING(@"All tasks will be unlinked, are you sure?") block:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [kEnInt logout];
//                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
//                [KPToDo removeAllAttachmentsForAllToDosWithService:EVERNOTE_SERVICE inContext:context save:YES];
//                [self reload];
//            }
//        }];
//    }
//}
//
//- (void)onLinkEvernoteTouch
//{
//    [self evernoteAuthenticateUsingSelector:@selector(authenticatedEvernote) withObject:nil];
//}
//
#pragma mark - Helpers

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

@end
