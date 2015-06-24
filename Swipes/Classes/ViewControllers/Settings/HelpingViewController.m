//
//  HelpViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/11/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "Intercom.h"
#import "RootViewController.h"
#import "UtilityClass.h"
#import "KPAlert.h"
#import "KPBlurry.h"
#import "HelpingViewController.h"
#import "UserHandler.h"

static NSString* const kGetStartedURL = @"http://support.swipesapp.com/hc/en-us/sections/200685992-Get-Started";
static NSString* const kFaqURL = @"http://support.swipesapp.com/hc/en-us/categories/200368652-FAQ";
static NSString* const kKnownIssuesURL = @"http://support.swipesapp.com/hc/en-us/sections/200659851-Known-Issues";
static NSString* const kPoliciesURL = @"http://swipesapp.com/policies.pdf";
static NSString* kCancelTitle;
static NSString* kOpenTitle;

@implementation HelpingViewController

+ (void)initialize
{
    kCancelTitle = [NSLocalizedString(@"cancel", nil) capitalizedString];
    kOpenTitle = [NSLocalizedString(@"open", nil) capitalizedString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSLocalizedString(@"Help", nil) uppercaseString];
}

- (void)recreateCellInfo
{
    NSString *emailString = @"User: Is trying out";
    if(kUserHandler.isLoggedIn){
        emailString = [kUserHandler emailOrFacebookString];
    }
    self.cellInfo = @[
                      @{kKeyTitle: NSLocalizedString(@"Open Policies", nil),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onOpenPoliciesTouch))
                        },
                      @{kKeyTitle: NSLocalizedString(@"Known Issues", nil),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onKnownIssuesTouch))
                        },
                      @{kKeyTitle: NSLocalizedString(@"FAQ", nil),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onFaqTouch))
                        },
                      @{kKeyTitle: NSLocalizedString(@"Get Started", nil),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onGetStartedTouch))
                        },
                      @{kKeyTitle: NSLocalizedString(@"Walkthrough", nil),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onWalkthroughTouch))
                        },
                      @{kKeyTitle: NSLocalizedString(@"Contact Swipes", nil),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onContactSwipesTouch))
                        },
                      @{kKeyTitle: emailString,
                        kKeyCellType: @(kIntegrationCellTypeNoAccessory)
                        }
                      ];
}

#pragma mark - selectors

- (void)onOpenPoliciesTouch
{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Policies", nil) andMessage:NSLocalizedString(@"Read through our 'Privacy Policy' and 'Terms and Conditions'.", nil) cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPoliciesURL]];
        }
    }];
}

- (void)onKnownIssuesTouch
{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Known Issues", nil) andMessage:NSLocalizedString(@"You found a bug? Check out if we're already working on it.", nil) cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kKnownIssuesURL]];
        }
    }];
}

- (void)onFaqTouch
{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"FAQ", nil) andMessage:NSLocalizedString(@"Learn how to get most out of the different features in Swipes.", nil) cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFaqURL]];
        }
    }];
}

- (void)onGetStartedTouch
{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Get Started", nil) andMessage:NSLocalizedString(@"Learn how to get most out of Swipes.", nil) cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kGetStartedURL]];
        }
    }];
}

- (void)onWalkthroughTouch
{
    [ROOT_CONTROLLER walkthrough];
}

- (void)onContactSwipesTouch
{
    [Intercom presentConversationList];
}

@end
