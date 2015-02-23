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

@interface EvernoteIntegrationViewController ()  <IntegrationProvider, UITableViewDelegate, UITableViewDataSource>

@end

@implementation EvernoteIntegrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self recreateCellInfo];
    
}

- (void)recreateCellInfo {
    
    NSDictionary* businessInfo;
    if (kEnInt.isBusinessUser) {
        businessInfo = @{kKeyTitle: LOCALIZE_STRING(@"Sync with Evernote Business"), kKeyCellType: @(kIntegrationCellTypeCheck), kKeyIsOn: @(kEnInt.findInBusinessNotebooks), kKeyTouchSelector: NSStringFromSelector(@selector(onFindBusinessNotebooksTouch))};
    }
    else {
        businessInfo = @{kKeyTitle: LOCALIZE_STRING(@"Learn more about Evernote Business"), kKeyCellType: @(kIntegrationCellTypeViewMore), kKeyTouchSelector: NSStringFromSelector(@selector(onBusinessLearnMoreTouch))};
    }
    
    self.cellInfo = @[
                  @{kKeyTitle: LOCALIZE_STRING(@"Sync with evernote on this device"),
                    kKeyCellType: @(kIntegrationCellTypeCheck),
                    kKeyIsOn: @(kEnInt.enableSync),
                    kKeyTouchSelector: NSStringFromSelector(@selector(onSincWithEvernoteTouch))
                    },
                  @{kKeyTitle: LOCALIZE_STRING(@"Auto import notes with \"swipes\" tag"),
                    kKeyCellType: @(kIntegrationCellTypeCheck),
                    kKeyIsOn: @(kEnInt.autoFindFromTag),
                    kKeyTouchSelector: NSStringFromSelector(@selector(onAutoImportTouch))},
                  @{kKeyTitle: LOCALIZE_STRING(@"Sync with personal linked notebooks"),
                    kKeyCellType: @(kIntegrationCellTypeCheck),
                    kKeyIsOn: @(kEnInt.findInPersonalLinked),
                    kKeyTouchSelector: NSStringFromSelector(@selector(onFindPersonalTouch))
                    },
                  businessInfo,
                  @{kKeyCellType: @(kIntegrationCellTypeSeparator)},
                  @{kKeyTitle: LOCALIZE_STRING(@"Import notes"),
                    kKeyCellType: @(kIntegrationCellTypeViewMore),
                    kKeyIcon: @"done", // TODO fix
                    kKeyTouchSelector: NSStringFromSelector(@selector(onImportNotesTouch))
                    },
                  @{kKeyTitle: LOCALIZE_STRING(@"Learn more"),
                    kKeyCellType: @(kIntegrationCellTypeViewMore),
                    kKeyIcon: @"today", // TODO fix
                    kKeyTouchSelector: NSStringFromSelector(@selector(onLearnMoreTouch))
                    },
                  @{kKeyTitle: LOCALIZE_STRING(@"Sign out"),
                    kKeyCellType: @(kIntegrationCellTypeNoAccessory),
                    kKeyIcon: @"roundClose",
                    kKeyTouchSelector: NSStringFromSelector(@selector(onSignOutTouch))
                    },
                  ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IntegrationProvider

- (NSString *)integrationTitle
{
    return @"EVERNOTE";
}

- (NSString *)integrationSubtitle
{
    // TODO return something meaningful
    return @" ";
}

- (NSString *)integrationIcon
{
    return iconString(@"integrationEvernote");
}

- (BOOL)integrationEnabled
{
    return kEnInt.isAuthenticated;
}

#pragma mark - UITableViewDataSource

#pragma mark - selectors

- (void)onSincWithEvernoteTouch {
    
}

- (void)onAutoImportTouch {
    
}

- (void)onFindPersonalTouch {
    
}

- (void)onFindBusinessNotebooksTouch {
    
}

- (void)onBusinessLearnMoreTouch {
    
}

- (void)onImportNotesTouch {
    
}

- (void)onLearnMoreTouch {
    
}

- (void)onSignOutTouch {
    
}

@end
