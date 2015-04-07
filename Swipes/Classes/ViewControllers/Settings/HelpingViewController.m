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
    kCancelTitle = [LOCALIZE_STRING(@"cancel") capitalizedString];
    kOpenTitle = [LOCALIZE_STRING(@"open") capitalizedString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [LOCALIZE_STRING(@"Help") uppercaseString];
}

- (void)recreateCellInfo
{
    NSString *emailString = @"User: Is trying out";
    if(kUserHandler.isLoggedIn){
        emailString = [kUserHandler emailOrFacebookString];
    }
    self.cellInfo = @[
                      @{kKeyTitle: LOCALIZE_STRING(@"Open Policies"),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onOpenPoliciesTouch))
                        },
                      @{kKeyTitle: LOCALIZE_STRING(@"Known Issues"),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onKnownIssuesTouch))
                        },
                      @{kKeyTitle: LOCALIZE_STRING(@"FAQ"),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onFaqTouch))
                        },
                      @{kKeyTitle: LOCALIZE_STRING(@"Get Started"),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onGetStartedTouch))
                        },
                      @{kKeyTitle: LOCALIZE_STRING(@"Walkthrough"),
                        kKeyCellType: @(kIntegrationCellTypeViewMore),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onWalkthroughTouch))
                        },
                      @{kKeyTitle: LOCALIZE_STRING(@"Contact Swipes"),
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
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Policies") andMessage:LOCALIZE_STRING(@"Read through our 'Privacy Policy' and 'Terms and Conditions'.") cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPoliciesURL]];
        }
    }];
}

- (void)onKnownIssuesTouch
{
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Known Issues") andMessage:LOCALIZE_STRING(@"You found a bug? Check out if we're already working on it.") cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kKnownIssuesURL]];
        }
    }];
}

- (void)onFaqTouch
{
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"FAQ") andMessage:LOCALIZE_STRING(@"Learn how to get most out of the different features in Swipes.") cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFaqURL]];
        }
    }];
}

- (void)onGetStartedTouch
{
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Get Started") andMessage:LOCALIZE_STRING(@"Learn how to get most out of Swipes.") cancel:kCancelTitle confirm:kOpenTitle block:^(BOOL succeeded, NSError *error) {
        
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
