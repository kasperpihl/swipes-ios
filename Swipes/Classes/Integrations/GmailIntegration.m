//
//  GmailIntegration.m
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "UtilityClass.h"
#import "KPAttachment.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GmailAuthViewController.h"
#import "GmailIntegration.h"

// instructions at https://code.google.com/p/google-api-objectivec-client/wiki/Introduction#Preparing_to_Use_the_Library
static NSString* const kClientID = @"336134475796-mqcavkepb80idm0qdacd2fhkf573r4cd.apps.googleusercontent.com";
static NSString* const kClientSecret = @"5heB-MAD5Qm-y1miBVic03cE";

// where to we store gmail integration data
static NSString* const kKeychainKeyName = @"swipes_gmail_integration";

static NSString* const kSwipesLabelName = @"[Mailbox]/Swipes"; // label name
static NSUInteger const kMaxResults = 200; // how many results to retrieve

// json keys
static NSString* const kKeyJson = @"json:";
static NSString* const kKeyJsonEmail = @"email";
static NSString* const kKeyJsonThreadId = @"threadid";

@interface GmailIntegration ()

@property (nonatomic, strong) GTMOAuth2Authentication* googleAuth;
@property (nonatomic, strong) NSString* swipesLabelId;
@property (nonatomic, strong) NSString* emailAddress;

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
        _emailAddress = nil;
        NSError* error;
        GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch
                                         authForGoogleFromKeychainForName:kKeychainKeyName
                                         clientID:kClientID
                                         clientSecret:kClientSecret
                                         error:&error];
        if (!error) {
            _googleAuth = auth;
            [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                [UtilityClass sendError:error type:@"gmail:cannot create swipes label"];
            }];
            [self emailAddressWithBlock:^(NSError *error) {
                [UtilityClass sendError:error type:@"gmail:cannot get user email address"];
            }];
        }
        
    }
    return self;
}

- (NSString *)threadIdToNSString:(NSString *)threadId
{
    if ((nil == threadId) || (nil == _emailAddress))
        return nil;

    NSMutableDictionary* jsonDict = [NSMutableDictionary dictionary];
    [jsonDict setObject:_emailAddress forKey:kKeyJsonEmail];
    [jsonDict setObject:threadId forKey:kKeyJsonThreadId];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (error) {
        [UtilityClass sendError:error type:@"gmail:threadIdToNSString error"];
        return nil;
    }
    return [kKeyJson stringByAppendingString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (NSString *)NSStringToThreadId:(NSString *)string
{
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[[string substringFromIndex:kKeyJson.length] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        [UtilityClass sendError:error type:@"gmail:NSStringToThreadId error"];
        return nil;
    }
    return jsonDict[kKeyJsonThreadId];
}

- (BOOL)hasNoteWithThreadId:(NSString *)threadId
{
    NSArray* allAttachments = [KPAttachment allIdentifiersForService:GMAIL_SERVICE sync:YES context:nil];
    for (NSString* attachmentString in allAttachments) {
        NSString* tempThreadId = [self NSStringToThreadId:attachmentString];
        if (tempThreadId && [tempThreadId isEqualToString:threadId]) {
            return YES;
        }
    }
    return NO;
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
        GmailAuthViewController* vc = [GmailAuthViewController controllerWithScope:kGTLAuthScopeGmailModify clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainKeyName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error)
        {
            [viewController dismissViewControllerAnimated:NO completion:nil];
            if (nil == error) {
                _googleAuth = auth;
                [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                    // TODO log error
                }];
            }
            block(error);
            DLog(@"Authenticated. Auth: %@, Error: %@", auth, error);
        }];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [viewController presentViewController:nav animated:YES completion:nil];
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
    _swipesLabelId = nil;
    _emailAddress = nil;
}

- (void)createSwipesLabelIfNeededWithBlock:(ErrorBlock)block
{
    if (_swipesLabelId) {
        block(nil);
        return;
    }
    
    GTLQueryGmail* listLabels = [GTLQueryGmail queryForUsersLabelsList];
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listLabels completionHandler:^(GTLServiceTicket *ticket, GTLGmailListLabelsResponse* object, NSError *error) {
        //DLog(@"queried - error: %@", error);
        if (error) {
            block(error);
        }
        else {
            BOOL hasSwipes = NO;
            if (object) {
                for (GTLGmailLabel* label in object.labels) {
                    //DLog(@"label: %@", label);
                    if (NSOrderedSame == [label.name caseInsensitiveCompare:kSwipesLabelName]) {
                        _swipesLabelId = label.identifier;
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
                    //DLog(@"queried - error: %@", error);
                    if (nil == error) {
                        _swipesLabelId = object.identifier;
                    }
                    block(error);
                }];
            }
        }
    }];
}

- (void)emailAddressWithBlock:(ErrorBlock)block
{
    // maybe we need a flag that we are currently doing this?
    if (_emailAddress) {
        block(nil);
        return;
    }
    
    GTLQueryGmail* getProfile = [GTLQueryGmail queryForUsersGetProfile];
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:getProfile completionHandler:^(GTLServiceTicket *ticket, GTLGmailProfile* profile, NSError *error) {
        if (!error) {
            _emailAddress = profile.emailAddress;
        }
        block(error);
    }];
}

- (void)doListThreads:(NSString *)query withBlock:(ThreadListBlock)block
{
    GTLQueryGmail* listThreads = [GTLQueryGmail queryForUsersThreadsList];
    listThreads.labelIds = @[_swipesLabelId];
    listThreads.maxResults = kMaxResults;
    listThreads.q = query;
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listThreads completionHandler:^(GTLServiceTicket *ticket, GTLGmailListThreadsResponse* object, NSError *error) {
        block(nil == object ? nil : object.threads, error);
    }];
}

- (void)getThread:(NSString *)threadId withBlock:(ThreadGetBlock)block
{
    GTLQueryGmail* getThread = [GTLQueryGmail queryForUsersThreadsGet];
    getThread.identifier = threadId;
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:getThread completionHandler:^(GTLServiceTicket *ticket, GTLGmailThread* thread, NSError *error) {
        //DLog(@"queried - thread:%@, error: %@", thread, error);
        block(thread, error);
    }];
}

- (void)listThreads:(NSString *)query withBlock:(ThreadListBlock)block
{
    if (nil == _googleAuth) {
        block(nil, [[NSError alloc] initWithDomain:@"Gmail not authenticated" code:701 userInfo:nil]);
    }
    
    [self emailAddressWithBlock:^(NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                if (error) {
                    block(nil, error);
                }
                else {
                    [self doListThreads:query withBlock:block];
                }
            }];
        }
    }];
}

- (void)removeSwipesLabelFromThread:(NSString *)threadId withBlock:(ErrorBlock)block
{
    GTLQueryGmail* modifyThread = [GTLQueryGmail queryForUsersThreadsModify];
    modifyThread.identifier = threadId;
    modifyThread.removeLabelIds = @[_swipesLabelId];
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:modifyThread completionHandler:^(GTLServiceTicket *ticket, GTLGmailThread* thread, NSError *error) {
        //DLog(@"queried - thread:%@, error: %@", thread, error);
        block(error);
    }];
}

@end
