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
//static NSString* const kClientID = @"336134475796-f7o2fbc288c2k3ud473nfp5bedstsi90.apps.googleusercontent.com";
//static NSString* const kClientSecret = @"-O9A0oLCG7Ll_gMlyIq51QEZ ";
static NSString* const kClientID = @"791921060265-b1d0c65g7spt9evnl2lug4g33cpbgfq6.apps.googleusercontent.com";
static NSString* const kClientSecret = @"mILogx6YkvKKoMo72YjT8Ksa";

// where to we store gmail integration data
static NSString* const kKeychainKeyName = @"swipes_gmail_integration";

static NSString* const kSwipesLabelName = @"Swipes";

@interface GmailIntegration ()

@property (nonatomic, strong) GTMOAuth2Authentication* googleAuth;
@property (nonatomic, strong) NSString* swipesLabelId;

@end

@implementation GmailIntegration

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _googleAuth = nil;
        NSError* error;
        GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch
                                         authForGoogleFromKeychainForName:kKeychainKeyName
                                         clientID:kClientID
                                         clientSecret:kClientSecret
                                         error:&error];
        if (!error) {
            _googleAuth = auth;
            [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                // TODO log error
                if (!error) {
                    [self listThreads:nil];
                }
            }];
        }
        
    }
    return self;
}
- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block
{
    NSError* error;
    GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch
                                         authForGoogleFromKeychainForName:kKeychainKeyName
                                         clientID:kClientID
                                         clientSecret:kClientSecret
                                         error:&error];
    if (error) {
        GTMOAuth2ViewControllerTouch* vc = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeGmailModify clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainKeyName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error)
        {
            [viewController dismissViewControllerAnimated:NO completion:nil];
            if (nil == error) {
                _googleAuth = auth;
                [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                    // TODO log error
                    if (!error) {
                        [self listThreads:nil];
                    }
                }];
            }
            block(error);
            DLog(@"Authenticated. Auth: %@, Error: %@", auth, error);
        }];
        
        [viewController presentViewController:vc animated:YES completion:nil];
    }
    else {
        _googleAuth = auth;
        block(error);
    }
}

- (BOOL)isAuthenticated
{
    return (_googleAuth != nil);
}

- (void)logout
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainKeyName];
    _googleAuth = nil;
}

- (void)createSwipesLabelIfNeededWithBlock:(ErrorBlock)block
{
    GTLQueryGmail* listLabels = [GTLQueryGmail queryForUsersLabelsList];
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listLabels completionHandler:^(GTLServiceTicket *ticket, GTLGmailListLabelsResponse* object, NSError *error) {
        DLog(@"queried - error: %@", error);
        if (error) {
            block(error);
        }
        else {
            BOOL hasSwipes = NO;
            if (object) {
                for (GTLGmailLabel* label in object.labels) {
                    DLog(@"label: %@", label);
                    if (NSOrderedSame == [label.name caseInsensitiveCompare:kSwipesLabelName]) {
                        _swipesLabelId = label.identifier;
                        //[self listMessages:@"after:2014/12/01"];
                        hasSwipes = YES;
                        break;
                    }
                }
            }
            if (hasSwipes) {
                block(nil);
            }
            else {
                GTLQueryGmail* createLabel = [GTLQueryGmail queryForUsersLabelsCreate];
                GTLGmailLabel* label = [[GTLGmailLabel alloc] init];
                label.name = kSwipesLabelName;
                label.labelListVisibility = @"labelShow";
                label.messageListVisibility = @"show";
                createLabel.label = label;
                GTLServiceGmail* serviceCreateLabel = [[GTLServiceGmail alloc] init];
                serviceCreateLabel.authorizer = _googleAuth;
                [serviceCreateLabel executeQuery:createLabel completionHandler:^(GTLServiceTicket *ticket, GTLGmailLabel* object, NSError *error) {
                    DLog(@"queried - error: %@", error);
                    if (nil == error) {
                        _swipesLabelId = object.identifier;
                        //[self listMessages:nil];
                    }
                    block(error);
                }];
            }
        }
    }];
}


- (void)listMessages:(NSString *)query
{
    GTLQueryGmail* listMessages = [GTLQueryGmail queryForUsersMessagesList];
    listMessages.labelIds = @[_swipesLabelId];
    listMessages.maxResults = 100;
    listMessages.q = query;
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listMessages completionHandler:^(GTLServiceTicket *ticket, GTLGmailListMessagesResponse* object, NSError *error) {
        if (error) {
            DLog(@"queried - error: %@", error);
        }
        else {
            for (GTLGmailMessage* message in object.messages) {
                DLog(@"message: %@", message);
                GTLQueryGmail* getMessage = [GTLQueryGmail queryForUsersMessagesGet];
                getMessage.identifier = message.identifier;
                GTLServiceGmail* serviceGetMessage = [[GTLServiceGmail alloc] init];
                serviceGetMessage.authorizer = _googleAuth;
                [serviceGetMessage executeQuery:getMessage completionHandler:^(GTLServiceTicket *ticket, GTLGmailMessage* object, NSError *error) {
                    DLog(@"queried - message:%@, error: %@", object, error);
                    if (nil == error) {
                        DLog(@"Message: %@", object.snippet);
                    }
                }];
            }
        }
    }];
}

- (void)listThreads:(NSString *)query
{
    GTLQueryGmail* listThreads = [GTLQueryGmail queryForUsersThreadsList];
    listThreads.labelIds = @[_swipesLabelId];
    listThreads.maxResults = 100;
    listThreads.q = query;
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listThreads completionHandler:^(GTLServiceTicket *ticket, GTLGmailListThreadsResponse* object, NSError *error) {
        if (error) {
            DLog(@"queried - error: %@", error);
        }
        else {
            for (GTLGmailThread* thread in object.threads) {
                DLog(@"thread: %@", thread);
                GTLQueryGmail* getThread = [GTLQueryGmail queryForUsersThreadsGet];
                getThread.identifier = thread.identifier;
                GTLServiceGmail* serviceGetThread = [[GTLServiceGmail alloc] init];
                serviceGetThread.authorizer = _googleAuth;
                [serviceGetThread executeQuery:getThread completionHandler:^(GTLServiceTicket *ticket, GTLGmailThread* thread, NSError *error) {
                    DLog(@"queried - thread:%@, error: %@", thread, error);
                    if (nil == error) {
                        GTLGmailMessage* message = thread.messages[0];
                        DLog(@"Thread: %@", message.snippet);
                    }
                }];
            }
        }
    }];
}


@end
