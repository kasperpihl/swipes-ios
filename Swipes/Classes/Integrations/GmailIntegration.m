//
//  GmailIntegration.m
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "GTLGmail.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GmailIntegration.h"

// instructions at https://code.google.com/p/google-api-objectivec-client/wiki/Introduction#Preparing_to_Use_the_Library
static NSString* const kClientID = @"336134475796-f7o2fbc288c2k3ud473nfp5bedstsi90.apps.googleusercontent.com";
static NSString* const kClientSecret = @"-O9A0oLCG7Ll_gMlyIq51QEZ ";

// where to we store gmail integration data
static NSString* const kKeychainKeyName = @"swipes_gmail_integration";

@interface GmailIntegration ()

@property (nonatomic, strong) GTMOAuth2Authentication* googleAuth;
@property (nonatomic, strong) NSString* swipesLabelId;

@end

@implementation GmailIntegration

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block
{
    NSError* error;
    
    GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch
                                         authForGoogleFromKeychainForName:kKeychainKeyName
                                         clientID:kClientID
                                         clientSecret:kClientSecret
                                         error:&error];
    if (error) {
        GTMOAuth2ViewControllerTouch* vc = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeGmailModify clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainKeyName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
            
            NSLog(@"Authenticated. Auth: %@, Error: %@", auth, error);
            if (nil == error) {
                _googleAuth = auth;
            }
            [viewController dismissViewControllerAnimated:YES completion:nil];
            block(error);
        }];
        
        [viewController presentViewController:vc animated:YES completion:nil];
    }
    else {
        _googleAuth = auth;
    }
    block(error);
}

- (void)logout
{
    
}


@end
